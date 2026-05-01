import 'package:flame_behaviors/flame_behaviors.dart';
import '../components/ship.dart';
import '../dashlander_game.dart';

class TelemetryBehavior extends Behavior<ShipComponent> {
  @override
  void update(double dt) {
    super.update(dt);
    final game = parent.findParent<DashlanderGame>();
    if (game == null) return;

    game.gameController.updateTelemetry(parent.state);
  }
}
