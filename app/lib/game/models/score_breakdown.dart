import 'package:flutter/animation.dart';
import '../../physics/lander_state.dart';
import '../game_controller.dart';

class ScoreBreakdown {
  // ---------------------------------------------------------------------------
  // LANDING VALIDATION LIMITS
  // ---------------------------------------------------------------------------

  /// The maximum allowable angle (in degrees) between the ship's orientation
  /// and the surface normal of the landing pad.
  /// If the ship is tilted more than this when it touches the pad, it crashes.
  // static const double maxLandingTiltDegrees = 15.0;
  static const double maxLandingTiltDegrees = 90.0;

  /// The maximum allowable radial speed (falling towards the center of the moon)
  /// when touching a pad (in m/s). Exceeding this shatters the landing legs.
  // static const double maxLandingVelocityY = 2.0;
  static const double maxLandingVelocityY = 100.0;

  /// The maximum allowable tangential speed (sliding sideways across the pad)
  /// when touching down (in m/s). Exceeding this snaps the landing legs sideways.
  // static const double maxLandingVelocityX = 1.0;
  static const double maxLandingVelocityX = 100.0;

  // ---------------------------------------------------------------------------
  // SCORING VALUES
  // ---------------------------------------------------------------------------
  static const int maxVelocityScore = 5000;
  static const int maxTiltScore = 2500;
  static const int maxFuelScore = 2500;

  final int fuelScore;
  final int velocityScore;
  final int tiltScore;
  final int totalScore;
  final double difficultyMultiplier;
  final int finalScore;

  ScoreBreakdown({
    required this.fuelScore,
    required this.velocityScore,
    required this.tiltScore,
    required this.totalScore,
    required this.difficultyMultiplier,
    required this.finalScore,
  });

  factory ScoreBreakdown.calculate(
    FinalMetrics metrics,
    LanderState state,
    double maxFuel,
    double difficultyMultiplier,
  ) {
    double applyCurve(double linearValue) {
      if (linearValue > 0) {
        return Curves.easeIn.transform(linearValue);
      } else {
        return -Curves.easeIn.transform(-linearValue);
      }
    }

    // Score based on percentage of fuel conserved
    double fuelAccuracy = (state.fuelMass / maxFuel).clamp(0.0, 1.0);
    int fuelScore = (Curves.easeIn.transform(fuelAccuracy) * maxFuelScore).toInt();

    // Curved Scoring Algorithm for Velocity
    double velocityAccuracy = (1.0 - (metrics.impactVelocityMetersPerSecond / maxLandingVelocityY)).clamp(0.0, 1.0);
    double velocityLinearScore = velocityAccuracy * 2.0 - 1.0;
    int velocityScore = (applyCurve(velocityLinearScore) * maxVelocityScore).toInt();

    // Curved Scoring Algorithm for Tilt
    double tiltAccuracy = (1.0 - (metrics.finalTiltDeg / maxLandingTiltDegrees)).clamp(0.0, 1.0);
    double tiltLinearScore = tiltAccuracy * 2.0 - 1.0;
    int tiltScore = (applyCurve(tiltLinearScore) * maxTiltScore).toInt();

    int score = fuelScore + velocityScore + tiltScore;
    int totalScore = score > 0 ? score : 0;
    int finalScore = (totalScore * difficultyMultiplier).round();

    return ScoreBreakdown(
      fuelScore: fuelScore,
      velocityScore: velocityScore,
      tiltScore: tiltScore,
      totalScore: totalScore,
      difficultyMultiplier: difficultyMultiplier,
      finalScore: finalScore,
    );
  }
}
