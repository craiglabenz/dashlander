import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../physics/constants.dart';
import '../physics/lander_state.dart';
import 'models/game_status.dart';
import 'models/level_data.dart';
import 'models/sandbox_config.dart';
import 'models/telemetry_data.dart';

class ScoreBreakdown {
  final int fuelScore;
  final int velocityPenalty;
  final int tiltPenalty;
  final int totalScore;

  ScoreBreakdown({
    required this.fuelScore,
    required this.velocityPenalty,
    required this.tiltPenalty,
    required this.totalScore,
  });
}

class GameController {
  final ValueNotifier<TelemetryData> telemetry = ValueNotifier(
    TelemetryData.empty(),
  );
  final ValueNotifier<GameStatus> status = ValueNotifier(GameStatus.menu);

  // Game results
  int finalScore = 0;
  ScoreBreakdown? finalScoreBreakdown;
  LanderState? finalState;

  LevelData? currentLevel;
  SandboxConfig? sandboxConfig;
  int ghostShipsCount = 0;

  void updateTelemetry(LanderState state) {
    // Determine radial/tangential velocity relative to surface normal
    Vector2 surfaceNormal = state.position.normalized();
    double fallingSpeed = -state.velocity.dot(surfaceNormal);
    Vector2 surfaceTangent = Vector2(-surfaceNormal.y, surfaceNormal.x);
    double horizontalSpeed = state.velocity.dot(surfaceTangent);

    // Calculate relative tilt compared to the surface normal beneath the ship
    double angleDeg = (state.angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;
    double surfaceAngle = atan2(surfaceNormal.x, -surfaceNormal.y);
    double surfaceAngleDeg = (surfaceAngle * 180 / pi) % 360;
    if (surfaceAngleDeg < 0) surfaceAngleDeg += 360;
    double diffDeg = (angleDeg - surfaceAngleDeg).abs();
    double tilt = min(diffDeg, 360 - diffDeg);

    telemetry.value = TelemetryData(
      fuel: state.fuelMass,
      maxFuel: currentLevel?.initialFuel ?? PhysicsConstants.defaultMaxFuel,
      vY: fallingSpeed / PhysicsConstants.pixelsPerMeter,
      vX: horizontalSpeed / PhysicsConstants.pixelsPerMeter,
      tilt: tilt,
      x: state.position.x,
      y: state.position.y,
    );
  }

  void setGameOver(GameStatus newStatus, LanderState state) {
    status.value = newStatus;
    finalState = state;

    if (newStatus == GameStatus.won) {
      // Heavily weight fuel conservation
      int fuelScore =
          (state.fuelMass * PhysicsConstants.fuelScoreMultiplier).toInt();

      // Penalty based on absolute landing velocity
      double speedMeters =
          state.velocity.length / PhysicsConstants.pixelsPerMeter;
      int velocityPenalty =
          (speedMeters * PhysicsConstants.velocityScoreMultiplier).toInt();

      // Penalty based on tilt relative to surface
      double surfaceAngleDeg;
      if (state.padAngleDeg != null) {
        surfaceAngleDeg = state.padAngleDeg!;
      } else {
        Vector2 surfaceNormal = state.position.normalized();
        double surfaceAngle = atan2(surfaceNormal.x, -surfaceNormal.y);
        surfaceAngleDeg = (surfaceAngle * 180 / pi) % 360;
        if (surfaceAngleDeg < 0) surfaceAngleDeg += 360;
      }
      
      double angleDeg = (state.angle * 180 / pi) % 360;
      if (angleDeg < 0) angleDeg += 360;
      
      double diffDeg = (angleDeg - surfaceAngleDeg).abs();
      double tilt = min(diffDeg, 360 - diffDeg);
      
      int tiltPenalty = (tilt * PhysicsConstants.tiltScoreMultiplier).toInt();

      int score = fuelScore + velocityPenalty + tiltPenalty;
      finalScore = score > 0 ? score : 0;

      finalScoreBreakdown = ScoreBreakdown(
        fuelScore: fuelScore,
        velocityPenalty: velocityPenalty,
        tiltPenalty: tiltPenalty,
        totalScore: finalScore,
      );
    } else {
      finalScore = 0;
      finalScoreBreakdown = null;
    }
  }

  void reset() {
    status.value = GameStatus.menu;
    finalScore = 0;
    finalScoreBreakdown = null;
    finalState = null;
  }
}
