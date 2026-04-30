import 'package:flutter/foundation.dart';
import '../physics/constants.dart';
import '../physics/lander_state.dart';
import 'models/game_status.dart';
import 'models/level_data.dart';
import 'models/sandbox_config.dart';
import 'models/telemetry_data.dart';

class GameController {
  final ValueNotifier<TelemetryData> telemetry = ValueNotifier(
    TelemetryData.empty(),
  );
  final ValueNotifier<GameStatus> status = ValueNotifier(GameStatus.menu);

  // Game results
  int finalScore = 0;
  LanderState? finalState;

  LevelData? currentLevel;
  SandboxConfig? sandboxConfig;
  int ghostShipsCount = 0;

  void updateTelemetry(LanderState state) {
    telemetry.value = TelemetryData(
      fuel: state.fuelMass,
      maxFuel: currentLevel?.initialFuel ?? PhysicsConstants.defaultMaxFuel,
      vY: state.velocity.y,
      vX: state.velocity.x,
      gForce: state.maxGForce,
    );
  }

  void setGameOver(GameStatus newStatus, LanderState state) {
    status.value = newStatus;
    finalState = state;

    if (newStatus == GameStatus.won) {
      double fuelScore = state.fuelMass * 2;
      double velocityPenalty =
          (state.velocity.y.abs() + state.velocity.x.abs()) * 100;
      double score =
          10000 + fuelScore - velocityPenalty - (state.maxGForce * 50);
      finalScore = score > 0 ? score.toInt() : 0;
    } else {
      finalScore = 0;
    }
  }

  void reset() {
    status.value = GameStatus.menu;
    finalScore = 0;
    finalState = null;
  }
}
