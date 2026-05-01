import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import '../components/ship.dart';
import '../components/particle_exhaust.dart';
import '../../physics/physics_engine.dart';
import '../../physics/constants.dart';
import '../dashlander_game.dart';

class ShipCollisionBehavior extends Behavior<ShipComponent> {
  final PhysicsEngine physicsEngine;

  ShipCollisionBehavior({required this.physicsEngine});

  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    if (state.isCrashed || state.isLanded) return;

    final game = parent.findParent<DashlanderGame>();
    if (game == null) return;
    final terrain = game.terrain;

    final shipRadius = PhysicsConstants.shipRadius;
    bool crashed = false;
    bool landed = false;

    for (int i = 0; i < terrain.points.length - 1; i++) {
      final p1 = terrain.points[i];
      final p2 = terrain.points[i + 1];

      double dist = _pointLineDistance(state.position, p1, p2);

      if (dist < shipRadius) {
        if (terrain.padIndices.contains(i)) {
          physicsEngine.validateLanding(state);
          if (state.isLanded) {
            landed = true;
          } else {
            crashed = true;
          }
        } else {
          crashed = true;
        }
      }
    }

    final minX = terrain.points.first.x;
    final maxX = terrain.points.last.x;
    if (state.position.x < minX || state.position.x > maxX || state.position.y < -2000) {
      crashed = true;
    }

    if (crashed || landed) {
      if (crashed) {
        state.isCrashed = true;
        _createExplosion(game, state.position);
        parent.isVisible = false;
      } else {
        state.isLanded = true;
      }
      
      if (!parent.isGhost) {
        game.triggerGameOver(landed);
      }
    }
  }

  double _pointLineDistance(Vector2 p, Vector2 a, Vector2 b) {
    final ab = b - a;
    final ap = p - a;
    double t = ap.dot(ab) / ab.length2;
    t = t.clamp(0.0, 1.0);
    final nearest = a + ab * t;
    return (p - nearest).length;
  }

  void _createExplosion(DashlanderGame game, Vector2 pos) {
    for (int i = 0; i < 50; i++) {
      game.add(ParticleExhaust.explosion(position: pos));
    }
  }
}
