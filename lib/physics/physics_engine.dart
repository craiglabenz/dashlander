import 'dart:math';
import 'package:flame/components.dart';
import 'constants.dart';
import 'lander_state.dart';
import '../game/models/score_breakdown.dart';

class PhysicsEngine {
  /// The absolute magnitude of lunar gravity in m/s^2.
  /// On the real moon, this is approximately 1.625 m/s^2.
  /// Because we operate on a spherical moon, this force is always applied
  /// pointing toward the coordinate origin (0, 0).
  // Lunar gravity magnitude
  final double lunarGravity = PhysicsConstants.lunarGravity;

  // Sandbox parameters for tweaking physics live in the UI
  bool infiniteFuel = false;
  double gravityScale = 1.0;
  double thrustScale = 1.0;

  /// The main physics step, called every frame.
  /// Uses a semi-implicit Euler integration method to calculate forces,
  /// update velocity, and then update position.
  ///
  /// [state] - The current kinematic state of the ship (position, velocity, etc.)
  /// [dt] - Delta time since the last frame (in seconds)
  /// [throttle] - The current throttle percentage [0.0, 1.0] from player input

  void update(LanderState state, double dt, double throttle) {
    if (state.isCrashed || state.isLanded) return;

    double steeringTorque = state.steeringTorque;

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
    // For a spherical moon centered at (0, 0), the vector pointing from the
    // ship to the center of the moon is simply the negative of its position.
    // Normalized, this gives us a pure directional unit vector for gravity.
    Vector2 gravityDirection = -state.position.normalized();
    // Start our net force calculation with the continuous pull of gravity
    // We scale the real-world gravity acceleration (m/s^2) into pixels/s^2.
    double gravityAccelPixels =
        lunarGravity * PhysicsConstants.pixelsPerMeter * gravityScale;
    Vector2 gravityForce =
        gravityDirection * gravityAccelPixels * state.totalMass;
    Vector2 netForce = gravityForce;

    if (state.isThrusting) {
      // In Flame's coordinate system, angle 0 points directly "UP" (towards negative Y).
      // A positive angle rotates clockwise.
      // Therefore, the forward vector is:
      // X = sin(angle)
      // Y = -cos(angle)
      //
      // This calculates the thrust vector pointing opposite the engine nozzle.
      // We scale the real-world thrust acceleration into pixels/s^2.
      // Since thrust is a force (N), the acceleration it causes is Thrust / Mass.
      // By multiplying the raw force by pixelsPerMeter here, the resulting
      // acceleration later (netForce / mass) will be perfectly scaled to pixels.
      double thrustPixels =
          mainThrustMagnitude * PhysicsConstants.pixelsPerMeter;
      Vector2 thrustVector = Vector2(
        sin(state.angle) * thrustPixels,
        -cos(state.angle) * thrustPixels,
      );
      netForce += thrustVector;
    }

    // 3. Accumulate Torques
    // In our simplified 2D physics, torque is directly applied by the RCS thrusters
    // without worrying about off-axis mass distribution.
    double netTorque = steeringTorque;

    // Angular Acceleration = Torque / Moment of Inertia (τ = I * α)
    double angularAcceleration = netTorque / state.baseInertia;

    // 4. Semi-Implicit Euler Integration
    // First, find the linear acceleration (a = F / m)
    Vector2 acceleration = netForce / state.totalMass;

    // G-Force Calculation (magnitude of non-gravitational acceleration)
    // We must reverse the pixelsPerMeter scaling to get the true real-world acceleration.
    Vector2 feltAcceleration =
        state.isThrusting
            ? ((netForce - gravityForce) / state.totalMass) /
                PhysicsConstants.pixelsPerMeter
            : Vector2.zero();
    double currentG =
        feltAcceleration.length / PhysicsConstants.standardGravity;
    state.currentGForce = currentG;
    if (currentG > state.maxGForce) {
      state.maxGForce = currentG;
    }

    state.velocity += acceleration * dt;
    state.position += state.velocity * dt;

    // Rotational Update
    state.angularVelocity += angularAcceleration * dt;
    state.angle += state.angularVelocity * dt;
  }

  /// Validates whether a collision with the ground is a successful landing or a fatal crash.
  ///
  /// Because our moon is spherical, "down" changes depending on where the ship is.
  /// We must calculate everything (tilt, horizontal speed, vertical speed) relative
  /// to the curved surface directly beneath the ship.
  void validateLanding(LanderState state) {
    // Convert the ship's internal radians to degrees and clamp to [0, 360)
    double angleDeg = (state.angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;

    // The exact angle of the landing pad the ship collided with.
    double surfaceAngleDeg = state.padAngleDeg!;
    double surfaceAngleRad = surfaceAngleDeg * pi / 180;

    // Convert the angle back to a normal vector to calculate relative velocities.
    // In Flame, angle 0 points UP (0, -1).
    Vector2 surfaceNormal = Vector2(
      sin(surfaceAngleRad),
      -cos(surfaceAngleRad),
    );

    // The tilt is the absolute difference between the ship's angle and the surface angle.
    // We use min(diff, 360 - diff) to find the shortest angular distance (e.g. 359 and 1 are 2 degrees apart).
    double diffDeg = (angleDeg - surfaceAngleDeg).abs();
    double tilt = min(diffDeg, 360 - diffDeg);

    // Landing requirement 1: Must be relatively upright compared to the ground
    bool isUpright = tilt <= ScoreBreakdown.maxLandingTiltDegrees;

    // Radial velocity (falling speed):
    // The dot product projects the ship's velocity onto the surface normal vector.
    // Since the normal points OUT, a positive dot product means moving AWAY from the moon.
    // A negative dot product means falling TOWARDS the moon.
    // By taking the negative dot product, we get a positive "falling speed".
    double fallingSpeed = -state.velocity.dot(surfaceNormal);

    // Landing requirement 2: Must not hit the ground too hard vertically
    // We convert the max m/s limit to pixels/s for comparison.
    bool isSlowV =
        fallingSpeed <=
        (ScoreBreakdown.maxLandingVelocityY * PhysicsConstants.pixelsPerMeter);

    // Tangential velocity (horizontal sliding speed):
    // The tangent vector is exactly 90 degrees rotated from the normal vector.
    // (x, y) rotated 90 degrees becomes (-y, x).
    Vector2 surfaceTangent = Vector2(-surfaceNormal.y, surfaceNormal.x);

    // The dot product projects the ship's velocity onto the tangent vector, giving us
    // the true "sliding" speed across the surface, regardless of our location on the sphere.
    double horizontalSpeed = state.velocity.dot(surfaceTangent).abs();

    // Landing requirement 3: Must not be sliding too fast horizontally across the ground
    bool isSlowH =
        horizontalSpeed <=
        (ScoreBreakdown.maxLandingVelocityX * PhysicsConstants.pixelsPerMeter);

    // If all three conditions are met, it's a perfect landing! Otherwise, explosion.
    if (isUpright && isSlowV && isSlowH) {
      state.isLanded = true;
    } else {
      state.isCrashed = true;
      if (!isUpright) {
        state.crashReason =
            'Tilt exceeded maximum by \n${(tilt - ScoreBreakdown.maxLandingTiltDegrees).toStringAsFixed(1)}°';
      } else if (!isSlowV) {
        double excessV =
            (fallingSpeed / PhysicsConstants.pixelsPerMeter) -
            ScoreBreakdown.maxLandingVelocityY;
        state.crashReason =
            'Vertical speed exceeded limit by \n${excessV.toStringAsFixed(1)} m/s';
      } else if (!isSlowH) {
        double excessH =
            (horizontalSpeed / PhysicsConstants.pixelsPerMeter) -
            ScoreBreakdown.maxLandingVelocityX;
        state.crashReason =
            'Horizontal sliding exceeded limit by \n${excessH.toStringAsFixed(1)} m/s';
      }
    }
  }
}
