import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dashlander/game/game_controller.dart';
import 'package:dashlander/game/models/score_breakdown.dart';
import 'package:dashlander/physics/lander_state.dart';

void main() {
  group('ScoreBreakdown', () {
    late LanderState baseState;

    setUp(() {
      baseState = LanderState(
        position: Vector2.zero(),
        velocity: Vector2.zero(),
        angle: 0,
        angularVelocity: 0,
        fuelMass: 100.0,
        dryMass: 4000.0,
        engineMaxThrust: 40000.0,
        specificImpulse: 300.0,
        baseInertia: 50000.0,
      );
    });

    test('perfect landing gives maximum points', () {
      final metrics = FinalMetrics(
        shipDeltaDeg: 0.0,
        padDeltaDeg: 0.0,
        finalTiltDeg: 0.0,
        impactVelocityMetersPerSecond: 0.0,
      );

      final breakdown = ScoreBreakdown.calculate(metrics, baseState);

      expect(breakdown.velocityScore, ScoreBreakdown.maxVelocityScore);
      expect(breakdown.tiltScore, ScoreBreakdown.maxTiltScore);
      expect(breakdown.fuelScore, (100.0 * ScoreBreakdown.fuelScoreMultiplier).toInt());
    });

    test('midpoint landing gives zero points', () {
      final metrics = FinalMetrics(
        shipDeltaDeg: 0.0,
        padDeltaDeg: 0.0,
        finalTiltDeg: ScoreBreakdown.maxLandingTiltDegrees / 2,
        impactVelocityMetersPerSecond: ScoreBreakdown.maxLandingVelocityY / 2,
      );

      final breakdown = ScoreBreakdown.calculate(metrics, baseState);

      expect(breakdown.velocityScore, 0);
      expect(breakdown.tiltScore, 0);
    });

    test('near-fatal landing subtracts maximum points', () {
      final metrics = FinalMetrics(
        shipDeltaDeg: 0.0,
        padDeltaDeg: 0.0,
        finalTiltDeg: ScoreBreakdown.maxLandingTiltDegrees,
        impactVelocityMetersPerSecond: ScoreBreakdown.maxLandingVelocityY,
      );

      final breakdown = ScoreBreakdown.calculate(metrics, baseState);

      expect(breakdown.velocityScore, -ScoreBreakdown.maxVelocityScore);
      expect(breakdown.tiltScore, -ScoreBreakdown.maxTiltScore);
    });

    test('total score sums correctly and clamps to zero', () {
      final metrics = FinalMetrics(
        shipDeltaDeg: 0.0,
        padDeltaDeg: 0.0,
        finalTiltDeg: ScoreBreakdown.maxLandingTiltDegrees,
        impactVelocityMetersPerSecond: ScoreBreakdown.maxLandingVelocityY,
      );
      
      baseState.fuelMass = 0; // 0 fuel score, large negative penalty
      final breakdown = ScoreBreakdown.calculate(metrics, baseState);
      
      expect(breakdown.totalScore, 0);
    });
  });
}
