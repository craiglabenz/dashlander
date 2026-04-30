import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParticleExhaust extends PositionComponent {
  late Vector2 velocity;
  double life = 1.0;
  final Random _rnd = Random();
  late Color color;
  final double startRadius;

  ParticleExhaust({
    required Vector2 position,
    required double emissionAngle,
    required Vector2 shipVelocity,
    Color? color,
    this.startRadius = 3.0,
  }) : super(position: position, anchor: Anchor.center) {
    // Add random spread to velocity based on angle
    velocity = Vector2(
      shipVelocity.x + sin(emissionAngle) * 100 + (_rnd.nextDouble() - 0.5) * 50,
      shipVelocity.y - cos(emissionAngle) * 100 + (_rnd.nextDouble() - 0.5) * 50,
    );
    this.color = color ?? (_rnd.nextBool() ? const Color(0xFFFFAA00) : const Color(0xFFFF00FF));
  }

  ParticleExhaust.explosion({required Vector2 position}) : startRadius = 6.0, super(position: position, anchor: Anchor.center) {
    velocity = Vector2((_rnd.nextDouble() - 0.5) * 200, (_rnd.nextDouble() - 0.5) * 200);
    color = _rnd.nextBool() ? const Color(0xFFFF00FF) : const Color(0xFF00FFFF);
    life = 1.0 + _rnd.nextDouble(); // longer life for explosion
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    life -= dt * 2.0; // Decay
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final glowPaint = Paint()
      ..color = color.withOpacity(life.clamp(0.0, 1.0))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, startRadius * life.clamp(0.0, 1.0));
    
    canvas.drawCircle(Offset.zero, startRadius * life.clamp(0.0, 1.0), glowPaint);
    canvas.drawCircle(Offset.zero, (startRadius / 2) * life.clamp(0.0, 1.0), Paint()..color = Colors.white.withOpacity(life.clamp(0.0, 1.0)));
  }
}
