import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:shared/shared.dart';
import '../components/ship.dart';
import '../../physics/constants.dart';

class GhostInputBehavior extends Behavior<ShipComponent> {
  final GameReplay replay;
  double _elapsedTimeMs = 0.0;
  int _nextActionIndex = 0;

  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  bool _isUpPressed = false;

  GhostInputBehavior({required this.replay});

  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    if (state.isCrashed || state.isLanded) return;

    _elapsedTimeMs += dt * 1000;

    // Apply any actions that have occurred since last frame
    while (_nextActionIndex < replay.actions.length &&
        replay.actions[_nextActionIndex].timestampMs <= _elapsedTimeMs) {
      final action = replay.actions[_nextActionIndex];
      switch (action.thruster) {
        case ThrusterType.left:
          _isLeftPressed = action.isFiring;
        case ThrusterType.right:
          _isRightPressed = action.isFiring;
        case ThrusterType.main:
          _isUpPressed = action.isFiring;
      }
      _nextActionIndex++;
    }

    double steeringTorque = 0.0;
    if (_isLeftPressed) steeringTorque -= PhysicsConstants.rcsSteeringTorque;
    if (_isRightPressed) steeringTorque += PhysicsConstants.rcsSteeringTorque;

    state.steeringTorque = steeringTorque;
    state.isThrusting = _isUpPressed;
  }
}
