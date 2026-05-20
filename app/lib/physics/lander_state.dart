import 'package:flame/components.dart';

/// Represents the physical state, configuration, and telemetry of the lander vessel.
///
/// This class serves as the single source of truth for the ship's physical simulation.
/// It is updated deterministically at 60Hz by the physics engine and used by
/// rendering and audio behaviors to display the ship's behavior and status.
class LanderState {
  /// The 2D position vector of the lander in the game world coordinates.
  Vector2 position;

  /// The 2D velocity vector of the lander (meters per second).
  Vector2 velocity;

  /// The Z-axis rotation angle of the lander in radians.
  /// 0 represents straight up, positive is clockwise, and negative is counter-clockwise.
  double angle;

  /// The rate of rotation around the Z-axis in radians per second.
  double angularVelocity;

  /// The current mass of the fuel onboard (kilograms).
  /// Consumed over time when the main engine or RCS thrusters are active.
  double fuelMass;

  /// The constant mass of the lander structure without any fuel (kilograms).
  final double dryMass;

  /// The maximum thrust force that the main engine can produce (Newtons).
  final double engineMaxThrust;

  /// The specific impulse (Isp) of the engine in seconds.
  /// Represents the fuel efficiency of the propulsion system.
  final double specificImpulse;

  /// The simplified 2D moment of inertia of the lander.
  /// Determines how resistant the vessel is to rotational acceleration.
  final double baseInertia;

  /// Flag indicating whether the main engine thruster is currently firing.
  bool isThrusting;

  /// The current steering torque applied by the RCS thrusters (Newton-meters).
  /// Negative for counter-clockwise rotation, positive for clockwise rotation.
  double steeringTorque;

  /// Flag indicating whether the lander has crashed (e.g. high velocity, steep angle, or out of bounds).
  bool isCrashed;

  /// Flag indicating whether the lander has successfully touched down on a landing pad.
  bool isLanded;

  /// The user-friendly description of why the ship crashed (if [isCrashed] is true).
  String? crashReason;

  /// The angle of the landing pad in degrees where the ship landed or crashed.
  double? padAngleDeg;

  /// The index of the landing pad segment in the level generation.
  int? padIndex;

  /// The current G-force experienced by the lander in this frame, shown on the HUD.
  double currentGForce;

  /// The maximum cumulative G-force sustained by the lander during the flight.
  /// Used in calculating the final landing score multiplier.
  double maxGForce;

  LanderState({
    required this.position,
    required this.velocity,
    required this.angle,
    required this.angularVelocity,
    required this.fuelMass,
    required this.dryMass,
    required this.engineMaxThrust,
    required this.specificImpulse,
    required this.baseInertia,
    this.isThrusting = false,
    this.steeringTorque = 0.0,
    this.isCrashed = false,
    this.isLanded = false,
    this.crashReason,
    this.padAngleDeg,
    this.padIndex,
    this.currentGForce = 0.0,
    this.maxGForce = 0.0,
  });

  /// The total instantaneous mass of the vessel (dry mass + remaining fuel mass).
  /// Used in F=ma physics calculations to determine acceleration.
  double get totalMass => dryMass + fuelMass;
}
