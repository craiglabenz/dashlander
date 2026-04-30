import 'dart:math';
import 'package:flame/components.dart';
import 'constants.dart';
import 'lander_state.dart';

class PhysicsEngine {
  // Lunar gravity is approx 1.625 m/s^2
  final Vector2 gravity = Vector2(0, PhysicsConstants.lunarGravity);

  // Sandbox parameters
  bool infiniteFuel = false;
  double gravityScale = 1.0;
  double thrustScale = 1.0;

  void update(
    LanderState state,
    double dt,
    double throttle,
    double steeringTorque,
  ) {
    if (state.isCrashed || state.isLanded) return;

    // 1. Calculate Fuel Consumption
    double mainThrustMagnitude = 0.0;
    double rcsThrustMagnitude = 0.0;

    // Check if we have fuel
    bool hasFuel = state.fuelMass > 0 || infiniteFuel;

    if (state.isThrusting && hasFuel) {
      mainThrustMagnitude = state.engineMaxThrust * throttle * thrustScale;
    } else {
      state.isThrusting = false; // Out of fuel or throttle off
    }

    if (steeringTorque != 0.0 && hasFuel) {
      // Approximate RCS thrust by dividing torque by an assumed lever arm (e.g. 10 meters)
      // and applying the thrust scale.
      rcsThrustMagnitude =
          (steeringTorque.abs() / PhysicsConstants.rcsLeverArm) * thrustScale;
    } else {
      steeringTorque = 0.0; // No fuel for RCS
    }

    if (!infiniteFuel && (mainThrustMagnitude > 0 || rcsThrustMagnitude > 0)) {
      // dm/dt = - (T * F_max) / (I_sp * g0)
      double totalThrust = mainThrustMagnitude + rcsThrustMagnitude;
      double massFlowRate =
          totalThrust /
          (state.specificImpulse * PhysicsConstants.standardGravity);
      state.fuelMass -= massFlowRate * dt;
      if (state.fuelMass < 0) state.fuelMass = 0;
    }

    // 2. Accumulate Forces
    Vector2 netForce = gravity * state.totalMass * gravityScale;

    if (state.isThrusting) {
      // In Flame, Y down is positive. Angle 0 = pointing UP.
      // So thrust points UP, accelerating ship UP (negative Y).
      Vector2 thrustVector = Vector2(
        sin(state.angle) * mainThrustMagnitude,
        -cos(state.angle) * mainThrustMagnitude,
      );
      netForce += thrustVector;
    }

    // 3. Accumulate Torques
    // Simple 2D rotational physics
    double netTorque = steeringTorque;
    double angularAcceleration = netTorque / state.baseInertia;

    // 4. Semi-Implicit Euler Integration
    // Translational Update
    Vector2 acceleration = netForce / state.totalMass;

    // G-Force Calculation (magnitude of non-gravitational acceleration)
    Vector2 feltAcceleration =
        state.isThrusting
            ? (netForce - (gravity * state.totalMass * gravityScale)) /
                state.totalMass
            : Vector2.zero();
    double currentG =
        feltAcceleration.length / PhysicsConstants.standardGravity;
    if (currentG > state.maxGForce) {
      state.maxGForce = currentG;
    }

    state.velocity += acceleration * dt;
    state.position += state.velocity * dt;

    // Rotational Update
    state.angularVelocity += angularAcceleration * dt;
    state.angle += state.angularVelocity * dt;
  }

  // Helper for landing validation
  void validateLanding(LanderState state) {
    // Convert angle to degrees and normalize between 0 and 360
    double angleDeg = (state.angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;
    // Normalized difference from 0 (upright)
    double tilt = min(angleDeg, 360 - angleDeg);

    bool isUpright =
        tilt <
        PhysicsConstants
            .maxLandingTiltDegrees; // lenient for gameplay, historically 6 degrees
    bool isSlowV =
        state.velocity.y < PhysicsConstants.maxLandingVelocityY; // m/s
    bool isSlowH =
        state.velocity.x.abs() < PhysicsConstants.maxLandingVelocityX; // m/s

    if (isUpright && isSlowV && isSlowH) {
      state.isLanded = true;
    } else {
      state.isCrashed = true;
    }
  }
}
