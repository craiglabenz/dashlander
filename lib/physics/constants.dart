class PhysicsConstants {
  // Environment
  static const double lunarGravity = 1.625; // m/s^2
  static const double standardGravity = 9.80665; // m/s^2

  // Ship parameters
  static const double dryMass = 4280.0; // kg (Apollo LM dry mass approx)
  static const double engineMaxThrust = 45040.0; // N (Apollo LM max thrust)
  static const double specificImpulse = 311.0; // s
  static const double baseInertia =
      50000.0; // kg*m^2 (Arbitrary 2D moment of inertia)
  static const double rcsSteeringTorque = 25000.0; // N*m
  static const double rcsLeverArm = 10.0; // m

  // Landing Validation
  static const double maxLandingTiltDegrees = 15.0; // degrees
  static const double maxLandingVelocityY = 2.0; // m/s
  static const double maxLandingVelocityX = 1.0; // m/s

  // Game Limits
  static const double defaultMaxFuel = 1000.0; // kg

  // Sandbox Reference values
  static const double sandboxBaseGravity = 0.04;
  static const double sandboxBaseThrust = 0.12;

  // Collision
  static const double shipRadius = 14.0;

  // Ghost ship variations
  static const double ghostOffsetXRange = 40.0;
  static const double ghostOffsetYRange = 20.0;

  // Physics initial state
  static const double initialVelocityX = 2.0;
  static const double initialVelocityY = 0.0;
}
