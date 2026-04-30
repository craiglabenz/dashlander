import 'dart:math';
import 'package:flame/components.dart';
import 'lander_state.dart';

class PhysicsEngine {
  // Lunar gravity is approx 1.625 m/s^2
  final Vector2 gravity = Vector2(0, 1.625);
  final double standardGravity = 9.80665; // For specific impulse calculation

  // Sandbox parameters
  bool infiniteFuel = false;
  double gravityScale = 1.0;
  double thrustScale = 1.0;

  void update(LanderState state, double dt, double throttle, double steeringTorque) {
    if (state.isCrashed || state.isLanded) return;

    // 1. Calculate Fuel Consumption
    double thrustMagnitude = 0.0;
    if (state.isThrusting && (state.fuelMass > 0 || infiniteFuel)) {
      thrustMagnitude = state.engineMaxThrust * throttle * thrustScale;
      
      if (!infiniteFuel) {
        // dm/dt = - (T * F_max) / (I_sp * g0)
        double massFlowRate = thrustMagnitude / (state.specificImpulse * standardGravity);
        state.fuelMass -= massFlowRate * dt;
        if (state.fuelMass < 0) state.fuelMass = 0;
      }
    } else {
      state.isThrusting = false; // Out of fuel or throttle off
    }

    // 2. Accumulate Forces
    Vector2 netForce = gravity * state.totalMass * gravityScale;

    if (state.isThrusting) {
      // In Flame, Y down is positive. Angle 0 = pointing UP.
      // So thrust points UP, accelerating ship UP (negative Y).
      Vector2 thrustVector = Vector2(
        sin(state.angle) * thrustMagnitude,
        -cos(state.angle) * thrustMagnitude,
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
    Vector2 feltAcceleration = state.isThrusting ? (netForce - (gravity * state.totalMass * gravityScale)) / state.totalMass : Vector2.zero();
    double currentG = feltAcceleration.length / standardGravity;
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

    bool isUpright = tilt < 15.0; // lenient for gameplay, historically 6 degrees
    bool isSlowV = state.velocity.y < 2.0; // m/s
    bool isSlowH = state.velocity.x.abs() < 1.0; // m/s

    if (isUpright && isSlowV && isSlowH) {
      state.isLanded = true;
    } else {
      state.isCrashed = true;
    }
  }
}
