import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../models/models.dart';
import '../components/lander.dart';
import '../components/terrain.dart';
import '../components/particles.dart';
import '../components/parallax_background.dart';

class DashlanderGame extends FlameGame with HasKeyboardHandlerComponents {
  final LevelData level;
  final SandboxConfig sandboxConfig;
  final void Function(GameResult) onGameOver;
  final void Function(Telemetry) onTelemetryUpdate;

  late Lander lander;
  late Terrain terrain;
  late ExhaustParticleSystem exhaustSystem;
  late Telemetry telemetry;
  
  GameStatus state = GameStatus.running;

  DashlanderGame({
    required this.level,
    required this.sandboxConfig,
    required this.onGameOver,
    required this.onTelemetryUpdate,
  });

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    telemetry = Telemetry(
      fuel: sandboxConfig.infiniteFuel ? 9999 : level.fuel,
      maxFuel: sandboxConfig.infiniteFuel ? 9999 : level.fuel,
    );

    // Add Parallax Stars
    // Since ParallaxBackground renders statically relative to canvas, we can add it to viewport 
    // or just rely on the camera translation. We'll add it as a normal component.
    add(ParallaxBackground());

    // Add Terrain
    terrain = Terrain(points: level.terrain);
    world.add(terrain);

    // Add Particle System
    exhaustSystem = ExhaustParticleSystem();
    world.add(exhaustSystem);

    // Add Lander
    lander = Lander(
      position: level.startPos.clone(),
      config: sandboxConfig,
      telemetry: telemetry,
      exhaustSystem: exhaustSystem,
    );
    // Give a slight initial push like the prototype
    telemetry.vx = 2.0; 
    world.add(lander);

    // Camera follow
    camera.follow(lander, snap: true);
  }

  @override
  void update(double dt) {
    if (state != GameStatus.running) return;
    
    super.update(dt);
    
    // Parallax update (rudimentary based on camera position)
    // We can shift stars manually or just let them stay static for now.

    onTelemetryUpdate(telemetry);
    
    checkCollisions();
  }

  void checkCollisions() {
    const double radius = 14.0;
    bool crashed = false;
    bool landed = false;

    for (int i = 0; i < level.terrain.length - 1; i++) {
      var p1 = level.terrain[i];
      var p2 = level.terrain[i + 1];
      
      double dist = _pointLineDistance(lander.position.x, lander.position.y, p1.x, p1.y, p2.x, p2.y);
      
      if (dist < radius) {
        if (p1.isPad && p2.isPad) {
          // Landing checks
          double angleDeg = (lander.angle * 180 / math.pi).abs() % 360;
          bool isUpright = angleDeg < 15 || angleDeg > 345;
          bool isSlowV = telemetry.vy < 1.5;
          bool isSlowH = telemetry.vx.abs() < 0.8;
          
          if (isUpright && isSlowV && isSlowH) {
            landed = true;
          } else {
            crashed = true;
          }
        } else {
          crashed = true;
        }
      }
    }

    if (crashed || landed) {
      state = landed ? GameStatus.win : GameStatus.crashed;
      
      if (crashed) {
        exhaustSystem.explode(lander.position);
        lander.removeFromParent(); // hide lander
      } else {
        lander.isThrusting = false; // stop exhaust
      }

      int score = 0;
      if (landed) {
        double fuelScore = telemetry.fuel * 2;
        double velocityPenalty = (telemetry.vy + telemetry.vx.abs()) * 100;
        score = math.max(0, (10000 + fuelScore - velocityPenalty - (telemetry.maxG * 50)).floor());
      }
      
      // Delay before showing game over to allow explosion to be seen
      Future.delayed(const Duration(seconds: 1), () {
        onGameOver(GameResult(status: state, score: score, telemetry: telemetry));
      });
    }
  }

  double _pointLineDistance(double px, double py, double x1, double y1, double x2, double y2) {
    double a = px - x1;
    double b = py - y1;
    double c = x2 - x1;
    double d = y2 - y1;

    double dot = a * c + b * d;
    double lenSq = c * c + d * d;
    double param = -1;
    
    if (lenSq != 0) {
      param = dot / lenSq;
    }

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * c;
      yy = y1 + param * d;
    }

    double dx = px - xx;
    double dy = py - yy;
    
    return math.sqrt(dx * dx + dy * dy);
  }
}
