import 'package:flame/components.dart';
import '../physics/lander_state.dart';
import '../physics/constants.dart';
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

  /// Computes the AI steering torque for this frame based on the level geometry and ship state.
  /// 
  /// This AI acts as a PD-controller to safely guide the ghost ship to a landing pad.
  /// Because the moon is spherical, it first maps the ship's current position and 
  /// all landing pads into an "unwrapped" radial coordinate system where arc-length 
  /// distance serves as the X-axis and altitude from the moon's center serves as the Y-axis.
  double update(LanderState state, double dt, LevelData level) {
    if (state.isCrashed || state.isLanded) return 0.0;

    // Calculate the ship's current angle relative to the center of the moon.
    // We use atan2(x, -y) because Flame's -Y axis is UP. 
    // This gives an angle of 0 when the ship is perfectly at the "top" of the moon.
    double shipTheta = atan2(state.position.x, -state.position.y);
    
    // Helper to keep angles cleanly within [-pi, pi] to avoid math wrap-around bugs
    double normalizeAngle(double a) {
      while (a > pi) {
        a -= 2 * pi;
      }
      while (a < -pi) {
        a += 2 * pi;
      }
      return a;
    }

    // 1. Find the geographically nearest landing pad.
    // Instead of using Cartesian distance (which would cut THROUGH the moon),
    // we use angular distance across the curved surface.
    Vector2? targetPad;
    for (int padIndex in level.padIndices) {
      if (padIndex < level.terrainPoints.length - 1) {
        final p1 = level.terrainPoints[padIndex];
        final p2 = level.terrainPoints[padIndex + 1];
        // The pad's true physical position is precisely the midpoint of its two vertices
        final center = (p1 + p2) / 2;

        if (targetPad == null) {
          targetPad = center;
        } else {
          // Compare the absolute angular differences.
          // Because we use normalizeAngle, crossing the pi/-pi boundary at the "bottom" 
          // of the moon is handled gracefully.
          double distCurrent = normalizeAngle(atan2(center.x, -center.y) - shipTheta).abs();
          double distBest = normalizeAngle(atan2(targetPad.x, -targetPad.y) - shipTheta).abs();
          if (distCurrent < distBest) {
            targetPad = center;
          }
        }
      }
    }

    if (targetPad == null) return 0.0;

    // 2. Unwrapped Navigation Coordinates
    // Here we translate the spherical reality into linear variables (dx, dy, vx, vy)
    // so the rest of the original flat-world AI logic can function without modification.

    double targetTheta = atan2(targetPad.x, -targetPad.y);
    
    // dx is the physical arc-length distance across the surface.
    // Formula: arcLength = angle_difference * radius
    double dx = normalizeAngle(targetTheta - shipTheta) * PhysicsConstants.moonRadius;
    
    // dy is relative altitude. 
    // We compare the raw lengths (radii) of the ship and pad vectors from (0,0).
    // Positive dy means the ship is higher than the pad.
    double dy = state.position.length - targetPad.length;

    // We compute the surface normal (outward facing) and tangent (sideways facing).
    Vector2 surfaceNormal = state.position.normalized();
    Vector2 surfaceTangent = Vector2(-surfaceNormal.y, surfaceNormal.x);
    
    // We project the ship's absolute velocity onto these axes to find out how fast 
    // it is sliding sideways (vx) and falling downwards (vy).
    double vx = state.velocity.dot(surfaceTangent);
    double vy = -state.velocity.dot(surfaceNormal); // negated so positive means falling

    // We also need the ship's angle relative to the curved surface, not the absolute screen.
    double shipAngleRel = normalizeAngle(state.angle - shipTheta);

    // Determine desired angle based on horizontal distance
    double desiredAngle = 0.0;

    // Braking logic scale based on speed
    if (dx > targetDistanceThreshold) {
      if (vx < maxHorizontalSpeed) {
        desiredAngle = maxTiltAngle; // Lean right to move right
      } else if (vx > maxHorizontalSpeed + 5) {
        desiredAngle = -maxTiltAngle * 0.8; // Too fast, lean left to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else if (dx < -targetDistanceThreshold) {
      if (vx > -maxHorizontalSpeed) {
        desiredAngle = -maxTiltAngle; // Lean left to move left
      } else if (vx < -maxHorizontalSpeed - 5) {
        desiredAngle = maxTiltAngle * 0.8; // Too fast, lean right to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else {
      // Close to pad, aggressively slow down horizontal speed
      if (vx > 2) {
        desiredAngle = -maxTiltAngle; // Lean left to slow down
      } else if (vx < -2) {
        desiredAngle = maxTiltAngle; // Lean right to slow down
      } else {
        desiredAngle = 0.0; // Upright
      }
    }

    // 3. Throttle logic (Vertical)
    double desiredVy;

    if (dx.abs() > 100) {
      // Far from pad: maintain a high safe altitude to clear terrain
      if (dy < 300) {
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
    if (vy > desiredVy) {
      state.isThrusting = true;
    } else {
      state.isThrusting = false;
    }

    // 4. Steering (PD-like Controller)
    double angleDiff = normalizeAngle(shipAngleRel - desiredAngle);

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
