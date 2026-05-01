import 'package:flame/components.dart';

class LanderState {
  Vector2 position;
  Vector2 velocity;
  double angle; // Z-axis rotation (radians)
  double angularVelocity;

  double fuelMass; // Variable mass
  final double dryMass;

  final double engineMaxThrust;
  final double specificImpulse;
  final double baseInertia; // Simplified 2D moment of inertia

  bool isThrusting;
  double steeringTorque;

  bool isCrashed;
  bool isLanded;

  double maxGForce; // Track maximum G-force for scoring

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
    this.maxGForce = 0.0,
  });

  double get totalMass => dryMass + fuelMass;
}
