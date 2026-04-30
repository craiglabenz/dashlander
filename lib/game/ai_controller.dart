import 'package:flame/components.dart';
import '../physics/lander_state.dart';
import 'game_state.dart';
import 'dart:math';

class GhostAIController {
  final double maxHorizontalSpeed;
  final double maxTiltAngle;
  final double targetDistanceThreshold;
  final double descentSpeedMultiplier;

  GhostAIController({required int seed})
    : maxHorizontalSpeed = 20.0 + Random(seed).nextDouble() * 25.0, // 20 to 45
      maxTiltAngle = 0.3 + Random(seed).nextDouble() * 0.4, // 0.3 to 0.7
      targetDistanceThreshold =
          60.0 + Random(seed).nextDouble() * 60.0, // 60 to 120
      descentSpeedMultiplier =
          0.8 + Random(seed).nextDouble() * 0.6; // 0.8x to 1.4x

  double update(LanderState state, double dt, LevelData level) {
    if (state.isCrashed || state.isLanded) return 0.0;

    // 1. Find nearest pad
    Vector2? targetPad;
    for (int padIndex in level.padIndices) {
      if (padIndex < level.terrainPoints.length - 1) {
        final p1 = level.terrainPoints[padIndex];
        final p2 = level.terrainPoints[padIndex + 1];
        final center = (p1 + p2) / 2;

        if (targetPad == null ||
            (center.x - state.position.x).abs() <
                (targetPad.x - state.position.x).abs()) {
          targetPad = center;
        }
      }
    }

    if (targetPad == null) return 0.0;

    // 2. Navigation logic
    double dx = targetPad.x - state.position.x;
    double dy = targetPad.y - state.position.y;

    // Determine desired angle based on horizontal distance
    double desiredAngle = 0.0;

    // Braking logic scale based on speed
    if (dx > targetDistanceThreshold) {
      if (state.velocity.x < maxHorizontalSpeed) {
        desiredAngle = maxTiltAngle; // Lean right to move right
      } else if (state.velocity.x > maxHorizontalSpeed + 5) {
        desiredAngle = -maxTiltAngle * 0.8; // Too fast, lean left to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else if (dx < -targetDistanceThreshold) {
      if (state.velocity.x > -maxHorizontalSpeed) {
        desiredAngle = -maxTiltAngle; // Lean left to move left
      } else if (state.velocity.x < -maxHorizontalSpeed - 5) {
        desiredAngle = maxTiltAngle * 0.8; // Too fast, lean right to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else {
      // Close to pad, aggressively slow down horizontal speed
      if (state.velocity.x > 2) {
        desiredAngle = -maxTiltAngle; // Lean left to slow down
      } else if (state.velocity.x < -2) {
        desiredAngle = maxTiltAngle; // Lean right to slow down
      } else {
        desiredAngle = 0.0; // Upright
      }
    }

    // 3. Throttle logic (Vertical)
    double desiredVy;

    if (dx.abs() > 100) {
      // Far from pad: maintain a high safe altitude to clear terrain
      double safeY = targetPad.y - 300;
      if (state.position.y > safeY) {
        desiredVy = -15.0; // Climb
      } else {
        desiredVy = 5.0; // Slowly descend or maintain
      }
    } else if (dx.abs() > 40) {
      // Approaching pad horizontally
      if (dy > 150) {
        desiredVy = 20.0 * descentSpeedMultiplier;
      } else {
        desiredVy = 5.0; // Don't drop too fast while not fully centered
      }
    } else {
      // Over the pad: final descent
      if (dy > 80) {
        desiredVy = 15.0 * descentSpeedMultiplier;
      } else if (dy > 30) {
        desiredVy = 5.0 * descentSpeedMultiplier;
      } else {
        desiredVy = 1.0; // Touchdown speed
      }
    }

    // Apply thrust if falling faster than desired
    if (state.velocity.y > desiredVy) {
      state.isThrusting = true;
    } else {
      state.isThrusting = false;
    }

    // 4. Steering (PD-like Controller)
    double angleDiff = state.angle - desiredAngle;

    // Normalize angle difference to [-pi, pi]
    while (angleDiff > pi) {
      angleDiff -= 2 * pi;
    }
    while (angleDiff < -pi) {
      angleDiff += 2 * pi;
    }

    // Predict where the angle will be based on current angular velocity
    double predictedAngleDiff = angleDiff + state.angularVelocity * 1.5;

    double steeringTorque = 0.0;
    if (predictedAngleDiff > 0.05) {
      steeringTorque = -25000.0; // Rotate left to correct
    } else if (predictedAngleDiff < -0.05) {
      steeringTorque = 25000.0; // Rotate right to correct
    }

    return steeringTorque;
  }
}
