import 'package:flame_behaviors/flame_behaviors.dart';
import '../components/ship.dart';
import '../dashlander_game.dart';
import '../../physics/constants.dart';

class PlayerInputBehavior extends Behavior<ShipComponent> {
  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    if (state.isCrashed || state.isLanded) return;

    final game = parent.findParent<DashlanderGame>();
    if (game == null) return;

    double steeringTorque = 0.0;
    if (game.isLeftPressed) steeringTorque -= PhysicsConstants.rcsSteeringTorque;
    if (game.isRightPressed) steeringTorque += PhysicsConstants.rcsSteeringTorque;

    state.steeringTorque = steeringTorque;
    state.isThrusting = game.isUpPressed;
  }
}
