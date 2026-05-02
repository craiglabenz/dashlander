import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../physics/constants.dart';
import '../physics/lander_state.dart';
import '../physics/math_utils.dart';
import 'models/game_status.dart';
import 'models/level_data.dart';
import 'models/sandbox_config.dart';
import 'models/telemetry_data.dart';

import 'models/score_breakdown.dart';

class FinalMetrics {
  final double shipDeltaDeg;
  final double padDeltaDeg;
  final double finalTiltDeg;
  final double impactVelocityMetersPerSecond;

  FinalMetrics({
    required this.shipDeltaDeg,
    required this.padDeltaDeg,
    required this.finalTiltDeg,
    required this.impactVelocityMetersPerSecond,
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
  FinalMetrics? finalMetrics;
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

    double shipDeltaDeg = MathUtils.calculateRelativeTiltDeg(
      position: state.position,
      absoluteAngleDeg: angleDeg,
    );
    double tilt = shipDeltaDeg.abs();

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

    // 1. Calculate the final metrics unconditionally for the UI
    double angleDeg = (state.angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;

    double shipDeltaDeg = MathUtils.calculateRelativeTiltDeg(
      position: state.position,
      absoluteAngleDeg: angleDeg,
    );

    double padDeltaDeg;
    if (state.padIndex != null && currentLevel != null) {
      padDeltaDeg = currentLevel!.padAngleDeltas[state.padIndex!] ?? 0.0;
    } else {
      double surfaceAngleDeg;
      if (state.padAngleDeg != null) {
        surfaceAngleDeg = state.padAngleDeg!;
      } else {
        Vector2 surfaceNormal = state.position.normalized();
        surfaceAngleDeg = MathUtils.calculateAbsoluteAngleDeg(surfaceNormal);
      }
      padDeltaDeg = MathUtils.calculateRelativeTiltDeg(
        position: state.position,
        absoluteAngleDeg: surfaceAngleDeg,
      );
    }

    double tilt = MathUtils.calculateTiltDifference(shipDeltaDeg, padDeltaDeg);

    Vector2 surfaceNormal = state.position.normalized();
    double fallingSpeedPixels = -state.velocity.dot(surfaceNormal);
    double fallingSpeedMeters =
        fallingSpeedPixels / PhysicsConstants.pixelsPerMeter;

    finalMetrics = FinalMetrics(
      shipDeltaDeg: shipDeltaDeg,
      padDeltaDeg: padDeltaDeg,
      finalTiltDeg: tilt,
      impactVelocityMetersPerSecond: fallingSpeedMeters,
    );

    // 2. Calculate the score if won
    if (newStatus == GameStatus.won) {
      finalScoreBreakdown = ScoreBreakdown.calculate(finalMetrics!, state);
      finalScore = finalScoreBreakdown!.totalScore;
    } else {
      finalScore = 0;
      finalScoreBreakdown = null;
    }
  }

  void reset() {
    status.value = GameStatus.menu;
    finalScore = 0;
    finalScoreBreakdown = null;
    finalMetrics = null;
    finalState = null;
  }
}
