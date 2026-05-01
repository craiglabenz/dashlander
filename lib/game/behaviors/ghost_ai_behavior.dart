import 'package:flame_behaviors/flame_behaviors.dart';
import '../components/ship.dart';
import '../ai_controller.dart';
import '../dashlander_game.dart';

class GhostAIBehavior extends Behavior<ShipComponent> {
  final GhostAIController aiController;

  GhostAIBehavior({required this.aiController});

  @override
  void update(double dt) {
    super.update(dt);
    final state = parent.state;
    if (state.isCrashed || state.isLanded) return;

    final game = parent.findParent<DashlanderGame>();
    if (game == null || game.gameController.currentLevel == null) return;

    final torque = aiController.update(state, dt, game.gameController.currentLevel!);
    state.steeringTorque = torque;
  }
}
