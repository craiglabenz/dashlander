import 'package:flame_behaviors/flame_behaviors.dart';
import '../components/ship.dart';
import '../../physics/physics_engine.dart';

class PhysicsBehavior extends Behavior<ShipComponent> {
  final PhysicsEngine physicsEngine;

  PhysicsBehavior({required this.physicsEngine});

  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    physicsEngine.update(state, dt, 1.0);
    parent.position = state.position;
    parent.angle = state.angle;
  }
}
