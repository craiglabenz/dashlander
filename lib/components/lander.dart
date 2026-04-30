import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'particles.dart';

class Lander extends PositionComponent with KeyboardHandler {
  final SandboxConfig config;
  final Telemetry telemetry;
  final ExhaustParticleSystem exhaustSystem;
  
  bool isThrusting = false;
  bool keysLeft = false;
  bool keysRight = false;
  bool keysUp = false;

  final Paint neonPink = Paint()
    ..color = const Color(0xFFFF00FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    
  final Paint neonCyan = Paint()
    ..color = const Color(0xFF00FFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);
    
  final Paint fillDark = Paint()
    ..color = const Color(0xFF111111)
    ..style = PaintingStyle.fill;

  Lander({
    required Vector2 position,
    required this.config,
    required this.telemetry,
    required this.exhaustSystem,
  }) : super(position: position, size: Vector2(24, 32), anchor: Anchor.center);

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    keysLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA);
    keysRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD);
    keysUp = keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW);
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Controls
    if (keysLeft) angle -= 2.5 * dt; // rotation speed approx 0.05 per frame
    if (keysRight) angle += 2.5 * dt;

    isThrusting = keysUp && (telemetry.fuel > 0 || config.infiniteFuel);

    double ax = 0;
    double ay = config.gravity * dt; // gravity is applied per second. Wait, if gravity is m/s^2, then velocity += gravity * dt.

    if (isThrusting) {
      if (!config.infiniteFuel) {
        telemetry.fuel -= 15 * dt; // 15kg per second
        if (telemetry.fuel < 0) telemetry.fuel = 0;
      }
      
      // Variable mass thermodynamics simulation (simplified)
      // Base acceleration increases as fuel decreases (lighter ship)
      double massFactor = 1.0 + (telemetry.fuel / telemetry.maxFuel);
      double effectiveThrust = config.thrustPower / massFactor;
      
      // Thrust is applied in the direction the ship is facing
      // angle 0 is facing up
      ax = math.sin(angle) * effectiveThrust * dt;
      ay -= math.cos(angle) * effectiveThrust * dt;
      
      // Spawn exhaust particles
      final offset = 16.0;
      final px = position.x - math.sin(angle) * offset;
      final py = position.y + math.cos(angle) * offset;
      exhaustSystem.spawn(Vector2(px, py), angle, telemetry.vx, telemetry.vy);
    }

    // Velocity update
    telemetry.vx += ax;
    telemetry.vy += ay;
    
    // Position update (framerate independent, scaled to 60fps baseline)
    position.x += telemetry.vx * (dt * 60);
    position.y += telemetry.vy * (dt * 60);

    // G-Force calculation
    // ax and (ay - gravity) are the forces felt by the pilot, converted to Gs.
    if (dt > 0) {
      double feltAx = ax / dt;
      double feltAy = (ay / dt) - config.gravity;
      double currentG = math.sqrt(feltAx * feltAx + feltAy * feltAy) / 9.8;
      telemetry.gForce = currentG;
      if (currentG > telemetry.maxG) telemetry.maxG = currentG;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw Ship Hull
    Path hull = Path()
      ..moveTo(size.x / 2, 0) // Nose
      ..lineTo(size.x / 2 + 10, size.y / 2 + 8) // Right wing
      ..lineTo(size.x / 2 + 6, size.y / 2 + 12) // Right engine
      ..lineTo(size.x / 2 - 6, size.y / 2 + 12) // Left engine
      ..lineTo(size.x / 2 - 10, size.y / 2 + 8) // Left wing
      ..close();
      
    canvas.drawPath(hull, fillDark);
    canvas.drawPath(hull, neonPink);
    
    // Draw Landing Legs
    Path legs = Path()
      ..moveTo(size.x / 2 - 8, size.y / 2 + 8)
      ..lineTo(size.x / 2 - 14, size.y / 2 + 18)
      ..lineTo(size.x / 2 - 18, size.y / 2 + 18)
      ..moveTo(size.x / 2 + 8, size.y / 2 + 8)
      ..lineTo(size.x / 2 + 14, size.y / 2 + 18)
      ..lineTo(size.x / 2 + 18, size.y / 2 + 18);
      
    canvas.drawPath(legs, neonCyan);
    
    // Cockpit
    canvas.drawCircle(Offset(size.x / 2, size.y / 2 - 2), 4, fillDark);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2 - 2), 4, neonCyan..style = PaintingStyle.fill);
  }
}
