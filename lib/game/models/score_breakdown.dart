import '../../physics/lander_state.dart';
import '../game_controller.dart';

class ScoreBreakdown {
  // ---------------------------------------------------------------------------
  // LANDING VALIDATION LIMITS
  // ---------------------------------------------------------------------------

  /// The maximum allowable angle (in degrees) between the ship's orientation
  /// and the surface normal of the landing pad.
  /// If the ship is tilted more than this when it touches the pad, it crashes.
  static const double maxLandingTiltDegrees = 15.0;

  /// The maximum allowable radial speed (falling towards the center of the moon)
  /// when touching a pad (in m/s). Exceeding this shatters the landing legs.
  static const double maxLandingVelocityY = 2.0;

  /// The maximum allowable tangential speed (sliding sideways across the pad)
  /// when touching down (in m/s). Exceeding this snaps the landing legs sideways.
  static const double maxLandingVelocityX = 1.0;

  // ---------------------------------------------------------------------------
  // SCORING VALUES
  // ---------------------------------------------------------------------------
  static const int maxVelocityScore = 1000;
  static const int maxTiltScore = 500;
  static const int maxFuelScore = 5000;

  final int fuelScore;
  final int velocityScore;
  final int tiltScore;
  final int totalScore;

  ScoreBreakdown({
    required this.fuelScore,
    required this.velocityScore,
    required this.tiltScore,
    required this.totalScore,
  });

  factory ScoreBreakdown.calculate(FinalMetrics metrics, LanderState state, double maxFuel) {
    // Score based on percentage of fuel conserved
    double fuelPercentage = (state.fuelMass / maxFuel).clamp(0.0, 1.0);
    int fuelScore = (fuelPercentage * maxFuelScore).toInt();

    // Midpoint Scoring Algorithm for Velocity
    double velocityMidpoint = maxLandingVelocityY / 2;
    double velocityScoreRaw =
        ((velocityMidpoint - metrics.impactVelocityMetersPerSecond) /
                velocityMidpoint) *
            maxVelocityScore;
    int velocityScore = velocityScoreRaw.toInt();

    // Midpoint Scoring Algorithm for Tilt
    double tiltMidpoint = maxLandingTiltDegrees / 2;
    double tiltScoreRaw =
        ((tiltMidpoint - metrics.finalTiltDeg) / tiltMidpoint) * maxTiltScore;
    int tiltScore = tiltScoreRaw.toInt();

    int score = fuelScore + velocityScore + tiltScore;
    int totalScore = score > 0 ? score : 0;

    return ScoreBreakdown(
      fuelScore: fuelScore,
      velocityScore: velocityScore,
      tiltScore: tiltScore,
      totalScore: totalScore,
    );
  }
}
