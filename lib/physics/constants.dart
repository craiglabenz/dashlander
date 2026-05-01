class PhysicsConstants {
  // ---------------------------------------------------------------------------
  // ENVIRONMENT
  // ---------------------------------------------------------------------------

  /// The absolute magnitude of lunar gravity acting on the ship (in m/s^2).
  /// This is applied radially toward the center of the spherical moon.
  /// Higher values pull the ship down faster, requiring more fuel to survive.
  static const double lunarGravity = 1.625;

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

  /// The number of discrete geometric line segments used to draw the moon.
  /// Higher values create a smoother circle but cost more performance to render
  /// and perform collision checks against.
  static const int terrainSegments = 80;

  /// The maximum vertical height (in meters) of mountains and craters added
  /// on top of the base `moonRadius`. Higher values create more jagged,
  /// extreme terrain that is harder to navigate.
  static const double maxTerrainHeight = 100.0;

  /// A multiplier applied to the sine wave generators that produce hills.
  /// Higher values mean more frequent, narrower hills. Lower values mean
  /// fewer, wider, rolling hills.
  static const double noiseFrequency = 4.0;

  /// The total number of perfectly flat landing pads carved out of the terrain.
  /// More pads make the level easier to complete.
  static const int numLandingPads = 6;

  /// The width of each landing pad, measured in `terrainSegments`.
  /// Since the total circumference is divided into 400 segments, a pad width of
  /// 2 means each pad spans roughly 1.8 degrees of the moon's surface.
  static const int padWidthSegments = 2;

  // ---------------------------------------------------------------------------
  // SHIP PARAMETERS (Mass & Thrust)
  // ---------------------------------------------------------------------------

  /// The mass of the ship without any fuel (in kg).
  /// Based loosely on the real Apollo Lunar Module. This determines the ship's
  /// minimum inertia when empty.
  static const double dryMass = 4280.0;

  /// The maximum force the main engine can produce (in Newtons).
  /// This dictates how fast the ship can accelerate upwards to fight gravity.
  static const double engineMaxThrust = 45040.0;

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
  // LANDING VALIDATION
  // ---------------------------------------------------------------------------

  /// The maximum allowable angle (in degrees) between the ship's orientation
  /// and the surface normal of the landing pad.
  /// If the ship is tilted more than this when it touches the pad, it crashes.
  static const double maxLandingTiltDegrees = 15.0;

  /// The maximum allowable radial speed (falling towards the center of the moon)
  /// when touching a pad (in m/s). Exceeding this shatters the landing legs.
  static const double maxLandingVelocityY = 2.0;

  /// The maximum allowable tangential speed (sliding sideways across the pad)
  /// when touching down (in m/s). Exceeding this snaps the landing legs sideways.
  static const double maxLandingVelocityX = 1.0;

  // ---------------------------------------------------------------------------
  // GAME LIMITS & COLLISION
  // ---------------------------------------------------------------------------

  /// The starting fuel mass for the lander (in kg).
  static const double defaultMaxFuel = 200.0;

  /// The radius of the ship's collision hitbox (in meters).
  /// This invisible circle is used to calculate collisions against the terrain's
  /// line segments.
  static const double shipRadius = 14.0;

  // ---------------------------------------------------------------------------
  // GHOST SHIPS
  // ---------------------------------------------------------------------------

  /// The maximum randomized horizontal offset applied to a ghost ship's
  /// starting position to prevent them from perfectly overlapping the player.
  static const double ghostOffsetXRange = 40.0;

  /// The maximum randomized vertical offset applied to a ghost ship's
  /// starting position.
  static const double ghostOffsetYRange = 20.0;

  // ---------------------------------------------------------------------------
  // INITIAL STATE
  // ---------------------------------------------------------------------------

  /// The starting tangential velocity of the ship when spawned (in m/s).
  /// Giving the ship a slight sideways push helps initiate the feeling of orbit.
  static const double initialVelocityX = 2.0;

  /// The starting radial velocity (falling speed) of the ship when spawned (in m/s).
  static const double initialVelocityY = 0.0;

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

  // ---------------------------------------------------------------------------
  // SCORING VALUES
  // ---------------------------------------------------------------------------
  static const double fuelScoreMultiplier = 45;
  static const double velocityScoreMultiplier = -1000;
  static const double tiltScoreMultiplier = -500;
}
