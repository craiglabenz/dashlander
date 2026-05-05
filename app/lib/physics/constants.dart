class PhysicsConstants {
  // ---------------------------------------------------------------------------
  // ENVIRONMENT
  // ---------------------------------------------------------------------------

  /// The absolute magnitude of lunar gravity acting on the ship (in m/s^2).
  /// This is applied radially toward the center of the spherical moon.
  /// Higher values pull the ship down faster, requiring more fuel to survive.
  // static const double lunarGravity = 3.2 * 1.25;
  static const double lunarGravity = 3.2;

  /// Earth's standard gravity (in m/s^2).
  /// Used solely as a reference to calculate the "G-Force" experienced by the
  /// ship during extreme maneuvers, which can be reported in telemetry.
  static const double standardGravity = 9.80665;

  // ---------------------------------------------------------------------------
  // PROCEDURAL LEVEL GENERATION
  // ---------------------------------------------------------------------------

  /// The base radius of the spherical moon.
  /// This defines the overall size of the world. A larger radius creates a
  /// flatter-feeling surface curvature, while a smaller radius creates a tiny,
  /// asteroid-like world.
  static const double moonRadius = 1000.0;
  static const double moonRadiusVariance = 0.2;

  /// The number of discrete geometric line segments used to draw the moon.
  /// Higher values create a smoother circle but cost more performance to render
  /// and perform collision checks against.
  static const int terrainSegments = 80;
  static const double terrainSegmentsVariance = 0.2;

  /// The maximum vertical height (in meters) of mountains and craters added
  /// on top of the base `moonRadius`. Higher values create more jagged,
  /// extreme terrain that is harder to navigate.
  static const double maxTerrainHeight = 300.0;
  static const double maxTerrainHeightVariance = 0.75;

  /// A multiplier applied to the sine wave generators that produce hills.
  /// Higher values mean more frequent, narrower hills. Lower values mean
  /// fewer, wider, rolling hills.
  static const double noiseFrequency = 4.5;
  static const double noiseFrequencyVariance = 0.3;

  /// The total number of perfectly flat landing pads carved out of the terrain.
  /// More pads make the level easier to complete.
  static const int numLandingPads = 3;
  static const double numLandingPadsVariance = 0.66;

  /// The width of each landing pad, measured in `terrainSegments`.
  /// Since the total circumference is divided into 400 segments, a pad width of
  /// 2 means each pad spans roughly 1.8 degrees of the moon's surface.
  static const int padWidthSegments = 2;
  static const double padWidthSegmentsVariance = 0.5;

  // ---------------------------------------------------------------------------
  // SHIP PARAMETERS (Mass & Thrust)
  // ---------------------------------------------------------------------------

  /// The mass of the ship without any fuel (in kg).
  /// Based loosely on the real Apollo Lunar Module. This determines the ship's
  /// minimum inertia when empty.
  static const double dryMass = 4280.0;

  /// The maximum force the main engine can produce (in Newtons).
  /// This dictates how fast the ship can accelerate upwards to fight gravity.
  static const double engineMaxThrust = 45040.0 * 1.8;

  /// The efficiency of the main engine (in seconds).
  /// A higher specific impulse means the engine consumes less fuel to produce
  /// the same amount of thrust.
  static const double specificImpulse = 311.0;

  /// The base 2D moment of inertia of the ship (in kg*m^2).
  /// This determines how resistant the ship is to rotational changes.
  /// A higher value makes the ship feel heavier and slower to turn.
  static const double baseInertia = 50000.0;

  /// The torque applied by the Reaction Control System (RCS) thrusters when
  /// the player steers left or right (in N*m).
  static const double rcsSteeringTorque = 25000.0;

  /// The assumed distance from the ship's center of mass to its RCS thrusters.
  /// Used purely to calculate the raw thrust force needed to produce the
  /// `rcsSteeringTorque`, which dictates RCS fuel consumption.
  static const double rcsLeverArm = 10.0;

  // ---------------------------------------------------------------------------
  // (Landing validation limits moved to ScoreBreakdown)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // GAME LIMITS & COLLISION
  // ---------------------------------------------------------------------------

  /// The starting fuel mass for the lander (in kg).
  static const double defaultMaxFuel = 1000.0;

  /// The radius of the ship's collision hitbox (in meters).
  /// This invisible circle is used to calculate collisions against the terrain's
  /// line segments.
  static const double shipRadius = 14.0;

  // ---------------------------------------------------------------------------
  // INITIAL STATE
  // ---------------------------------------------------------------------------

  /// The starting tangential velocity of the ship when spawned (in m/s).
  /// Giving the ship a slight sideways push helps initiate the feeling of orbit.
  static const double initialVelocityX = 2.0;
  static const double initialVelocityXVariance = 0.2;

  /// The starting radial velocity (falling speed) of the ship when spawned (in m/s).
  static const double initialVelocityY = 0.0;
  static const double initialVelocityYVariance = 0.2;

  /// The starting altitude of the ship above the moon's surface.
  static const double startAltitude = 300.0;
  static const double startAltitudeVariance = 0.2;

  // ---------------------------------------------------------------------------
  // SCALE
  // ---------------------------------------------------------------------------

  /// The visual height of the ship as drawn on the screen (in pixels/Flame units).
  static const double shipVisualHeight = 34.0;

  /// The real-world height of the ship we are simulating (in meters).
  static const double shipRealHeightMeters = 3.0;

  /// The conversion factor between real-world physics and Flame screen units.
  /// Used by the physics engine to scale gravity, thrust, and velocity limits
  /// so that the visual game acts exactly like the mathematical simulation.
  static const double pixelsPerMeter = shipVisualHeight / shipRealHeightMeters;

  // ---------------------------------------------------------------------------
  // SANDBOX REFERENCE VALUES
  // ---------------------------------------------------------------------------

  /// The base gravity slider value used in the sandbox UI to calculate scaling.
  static const double sandboxBaseGravity = 0.04;

  /// The base thrust slider value used in the sandbox UI to calculate scaling.
  static const double sandboxBaseThrust = 0.12;
}
