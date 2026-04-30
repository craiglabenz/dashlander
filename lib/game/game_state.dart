import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';
import '../physics/constants.dart';
import '../physics/lander_state.dart';

enum GameStatus { menu, playing, won, lost }

class TelemetryData {
  final double fuel;
  final double maxFuel;
  final double vY; // Vertical velocity
  final double vX; // Horizontal velocity
  final double gForce;

  TelemetryData({
    required this.fuel,
    required this.maxFuel,
    required this.vY,
    required this.vX,
    required this.gForce,
  });

  factory TelemetryData.empty() => TelemetryData(
    fuel: 0,
    maxFuel: PhysicsConstants.defaultMaxFuel,
    vY: 0,
    vX: 0,
    gForce: 0,
  );
}

class LevelData {
  final int id;
  final String name;
  final double initialFuel;
  final List<Vector2> terrainPoints;

  // Pairs of indices representing landing pads e.g. [3, 4] means segment
  // between terrainPoints[3] and [4] is a pad.
  final List<int> padIndices;
  final Vector2 startPosition;

  LevelData({
    required this.id,
    required this.name,
    required this.initialFuel,
    required this.terrainPoints,
    required this.padIndices,
    required this.startPosition,
  });
}

class SandboxConfig {
  final double gravity;
  final double thrustPower;
  final bool infiniteFuel;

  SandboxConfig({
    required this.gravity,
    required this.thrustPower,
    required this.infiniteFuel,
  });
}

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
