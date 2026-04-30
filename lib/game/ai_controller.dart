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
      targetDistanceThreshold = 15.0 + Random(seed).nextDouble() * 30.0, // 15 to 45
      descentSpeedMultiplier = 0.8 + Random(seed).nextDouble() * 0.6; // 0.8x to 1.4x

  double update(LanderState state, double dt, LevelData level) {
    if (state.isCrashed || state.isLanded) return 0.0;

    // 1. Find nearest pad
    Vector2? targetPad;
    for (int padIndex in level.padIndices) {
      if (padIndex < level.terrainPoints.length - 1) {
        final p1 = level.terrainPoints[padIndex];
        final p2 = level.terrainPoints[padIndex + 1];
        final center = (p1 + p2) / 2;
        
        if (targetPad == null || (center.x - state.position.x).abs() < (targetPad.x - state.position.x).abs()) {
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
    
    // If we are far away, lean towards it, but limit horizontal speed
    if (dx > targetDistanceThreshold) {
      if (state.velocity.x < maxHorizontalSpeed) {
        desiredAngle = maxTiltAngle; // Lean right to move right
      } else if (state.velocity.x > maxHorizontalSpeed + 10) {
        desiredAngle = -maxTiltAngle * 0.8; // Too fast, lean left to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else if (dx < -targetDistanceThreshold) {
      if (state.velocity.x > -maxHorizontalSpeed) {
        desiredAngle = -maxTiltAngle; // Lean left to move left
      } else if (state.velocity.x < -maxHorizontalSpeed - 10) {
        desiredAngle = maxTiltAngle * 0.8; // Too fast, lean right to brake
      } else {
        desiredAngle = 0.0; // Cruise
      }
    } else {
      // Close to pad, slow down horizontal speed
      if (state.velocity.x > 5) {
        desiredAngle = -maxTiltAngle * 0.8; // Lean left to slow down
      } else if (state.velocity.x < -5) {
        desiredAngle = maxTiltAngle * 0.8; // Lean right to slow down
      } else {
        desiredAngle = 0.0; // Upright
      }
    }

    // 3. Throttle logic (Vertical)
    // Desired descent speed based on height
    double desiredVy;
    if (dy > 300) {
      desiredVy = 40.0 * descentSpeedMultiplier;
    } else if (dy > 100) {
      desiredVy = 20.0 * descentSpeedMultiplier;
    } else {
      desiredVy = 1.0; // Slow down for final landing
    }

    // Apply thrust if falling too fast
    if (state.velocity.y > desiredVy) {
      state.isThrusting = true;
    } else {
      state.isThrusting = false;
    }

    // 4. Steering (PD-like Controller)
    double angleDiff = state.angle - desiredAngle;
    
    // Normalize angle difference to [-pi, pi]
    while (angleDiff > pi) angleDiff -= 2 * pi;
    while (angleDiff < -pi) angleDiff += 2 * pi;

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
