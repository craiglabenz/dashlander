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

      // Calculate the shortest distance from the ship's center to this line segment.
      double dist = _pointLineDistance(state.position, p1, p2);

      // If the ship's bounding circle overlaps the line segment, a collision has occurred.
      if (dist < shipRadius) {
        if (terrain.padIndices.contains(i)) {
          // The ship touched a designated landing pad. We must validate the physics of the touch.
          physicsEngine.validateLanding(state);
          if (state.isLanded) {
            landed = true; // Safe landing!
          } else {
            crashed = true; // Too fast, too tilted, etc.
          }
        } else {
          // The ship touched raw, jagged lunar terrain. Instant explosion.
          crashed = true;
        }
      }
    }

    // Spherical out-of-bounds check:
    // We measure the absolute distance from the ship to the center of the moon (0,0).
    // If it flies higher than an arbitrary outer boundary (+3000), it is lost in deep space.
    // If it glitches completely through the solid crust (-1000), it has fatally clipped the world.
    final double distance = state.position.length;
    if (distance > PhysicsConstants.moonRadius + 3000 || distance < PhysicsConstants.moonRadius - 1000) {
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

  /// Calculates the shortest distance from a point `p` to a line segment spanning `a` to `b`.
  /// Uses vector projection to find the closest point on the line segment.
  double _pointLineDistance(Vector2 p, Vector2 a, Vector2 b) {
    // Vector from a to b (the line segment itself)
    final ab = b - a;
    // Vector from a to p (the point in question)
    final ap = p - a;
    
    // Project ap onto ab to find the parameterized distance 't' along the line.
    // 't' represents the fraction of the way from 'a' to 'b'.
    double t = ap.dot(ab) / ab.length2;
    
    // Clamp 't' between 0.0 and 1.0 to ensure the closest point actually lies 
    // ON the line segment, rather than on the infinite line extending past a or b.
    t = t.clamp(0.0, 1.0);
    
    // Find the exact closest point on the clamped segment.
    final nearest = a + ab * t;
    
    // Return the Euclidean distance from the point to that nearest spot.
    return (p - nearest).length;
  }

  void _createExplosion(DashlanderGame game, Vector2 pos) {
    for (int i = 0; i < 50; i++) {
      game.world.add(ParticleExhaust.explosion(position: pos));
    }
  }
}
