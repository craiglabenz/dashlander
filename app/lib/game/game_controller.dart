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
import 'replay_recorder.dart';
import 'package:shared/shared.dart';

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
  GameReplay? targetGhostReplay;

  GameReplay? lastReplay;

  void updateTelemetry(
    LanderState state, {
    bool debugModeEnabled = false,
    List<Vector2>? terrainPoints,
  }) {
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

    // Calculate the terrain index directly below the lander
    // In Flame, -Y is UP. Angle is 0 at the top, increasing clockwise.
    double angleRad = atan2(state.position.x, -state.position.y);
    if (angleRad < 0) angleRad += 2 * pi;
    int terrainIndexBelow =
        (angleRad / (2 * pi) * PhysicsConstants.terrainSegments).floor() %
        PhysicsConstants.terrainSegments;

    double height = 0.0;
    if (terrainPoints != null && terrainPoints.isNotEmpty) {
      Vector2 p1 = terrainPoints[terrainIndexBelow];
      Vector2 p2 =
          terrainPoints[(terrainIndexBelow + 1) % terrainPoints.length];

      // Direction of the terrain segment (clockwise)
      Vector2 dir = p2 - p1;
      // Normal pointing outwards from the moon center
      Vector2 normal = Vector2(dir.y, -dir.x).normalized();

      Vector2 s0 = state.position;
      Vector2 v =
          state.position
              .normalized(); // Vector pointing straight UP from moon center

      // If the ship falls straight down towards the center of the moon, its position over time
      // is S(t) = s0 - t * v.
      // It impacts the ground when its bounding circle touches the line segment p1-p2.
      // This occurs when the perpendicular distance from S(t) to the line equals the ship's radius:
      // (S(t) - p1) . normal = shipRadius
      // (s0 - t * v - p1) . normal = shipRadius
      // (s0 - p1).dot(normal) - t * v.dot(normal) = shipRadius
      // t = ( (s0 - p1).dot(normal) - shipRadius ) / v.dot(normal)

      double shipRadius = PhysicsConstants.shipRadius;
      double dotVNormal = v.dot(normal);

      if (dotVNormal != 0) {
        double t = ((s0 - p1).dot(normal) - shipRadius) / dotVNormal;
        height = max(0.0, t);
      }
    }

    telemetry.value = TelemetryData(
      fuel: state.fuelMass,
      maxFuel: currentLevel?.initialFuel ?? PhysicsConstants.defaultMaxFuel,
      vY: fallingSpeed / PhysicsConstants.pixelsPerMeter,
      vX: horizontalSpeed / PhysicsConstants.pixelsPerMeter,
      tilt: tilt,
      x: state.position.x,
      y: state.position.y,
      terrainIndexBelow: terrainIndexBelow,
      debugModeEnabled: debugModeEnabled,
      height: height,
    );
  }

  void setGameOver(
    GameStatus newStatus,
    LanderState state, {
    ReplayRecorder? replayRecorder,
  }) {
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
      double maxFuel =
          currentLevel?.initialFuel ?? PhysicsConstants.defaultMaxFuel;
      finalScoreBreakdown = ScoreBreakdown.calculate(
        finalMetrics!,
        state,
        maxFuel,
      );
      finalScore = finalScoreBreakdown!.totalScore;
    } else {
      finalScore = 0;
      finalScoreBreakdown = null;
    }

    if (replayRecorder != null) {
      lastReplay = replayRecorder.finalizeReplay(score: finalScore);
      print('set lastReplay: $lastReplay');
    }

    // It is important that these lines remain the last in this function, as
    // they trigger listeners to fire elsewhere; but those listeners logically
    // assume that this function has completed (specifically, setting
    // `lastReplay`).
    status.value = newStatus;
    finalState = state;
  }

  void reset() {
    status.value = GameStatus.menu;
    finalScore = 0;
    finalScoreBreakdown = null;
    finalMetrics = null;
    finalState = null;
    lastReplay = null;
    targetGhostReplay = null;
  }
}
