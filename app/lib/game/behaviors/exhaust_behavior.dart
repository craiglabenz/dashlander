import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import '../components/ship.dart';
import '../components/particle_exhaust.dart';

class ExhaustBehavior extends Behavior<ShipComponent> {
  final bool Function() hasFuel;

  ExhaustBehavior({required this.hasFuel});

  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    final ship = parent;

    if (state.isCrashed || state.isLanded) return;

    // Main Thruster
    if (state.isThrusting && hasFuel()) {
      final mainExhaustOffset = Vector2(0, 12)..rotate(ship.angle);
      for (int i = 0; i < 3; i++) {
        parent.parent?.add(
          ParticleExhaust(
            position: ship.position + mainExhaustOffset,
            emissionAngle: ship.angle + pi,
            shipVelocity: state.velocity,
            startRadius: 4.0,
          )..priority = ship.isGhost ? 9 : 10,
        );
      }
    }

    // RCS Particles
    if (hasFuel()) {
      if (state.steeringTorque < 0) {
        // Rotating left (CCW) -> fire left RCS outward to the left
        final rcsOffset = Vector2(-10, 8)..rotate(ship.angle);
        parent.parent?.add(
          ParticleExhaust(
            position: ship.position + rcsOffset,
            emissionAngle: ship.angle - pi / 2,
            shipVelocity: state.velocity,
            color: Colors.white,
            startRadius: 2.0,
          )..priority = ship.isGhost ? 9 : 10,
        );
      } else if (state.steeringTorque > 0) {
        // Rotating right (CW) -> fire right RCS outward to the right
        final rcsOffset = Vector2(10, 8)..rotate(ship.angle);
        parent.parent?.add(
          ParticleExhaust(
            position: ship.position + rcsOffset,
            emissionAngle: ship.angle + pi / 2,
            shipVelocity: state.velocity,
            color: Colors.white,
            startRadius: 2.0,
          )..priority = ship.isGhost ? 9 : 10,
        );
      }
    }
  }
}
