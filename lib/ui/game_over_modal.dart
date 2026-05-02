import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../physics/constants.dart';
import '../game/game_state.dart';

class GameOverModal extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverModal({
    super.key,
    required this.controller,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWin = controller.status.value == GameStatus.won;
    final state = controller.finalState;
    if (state == null) return const SizedBox.shrink();

    final Color primaryColor = isWin ? Colors.cyanAccent : Colors.redAccent;
    final String title = isWin ? 'TOUCHDOWN' : 'CATASTROPHE';
    final String subtitle =
        isWin
            ? 'Flawless execution, Commander.'
            : state.crashReason ?? 'Structural integrity compromised.';

    Vector2 sphericalNormal = state.position.normalized();
    double fallingSpeedPixels = -state.velocity.dot(sphericalNormal);
    double fallingSpeedMeters =
        fallingSpeedPixels / PhysicsConstants.pixelsPerMeter;

    double angleDeg = (state.angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;

    double surfaceAngleDeg;
    if (state.padAngleDeg != null) {
      surfaceAngleDeg = state.padAngleDeg!;
    } else {
      double surfaceAngle = atan2(sphericalNormal.x, -sphericalNormal.y);
      surfaceAngleDeg = (surfaceAngle * 180 / pi) % 360;
      if (surfaceAngleDeg < 0) surfaceAngleDeg += 360;
    }
    double diffDeg = (angleDeg - surfaceAngleDeg).abs();
    double tilt = min(diffDeg, 360 - diffDeg);

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.shareTechMono(
                  color:
                      isWin ? Colors.grey.shade400 : Colors.redAccent.shade100,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isWin) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MISSION SCORE',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.cyan.shade200,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${controller.finalScore}',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildStatRow(
                'Impact Velocity',
                '${fallingSpeedMeters.toStringAsFixed(1)} m/s',
                fallingSpeedMeters > PhysicsConstants.maxLandingVelocityY
                    ? Colors.redAccent
                    : Colors.greenAccent,
                impactText:
                    isWin
                        ? '${controller.finalScoreBreakdown?.velocityPenalty ?? 0}'
                        : null,
                impactColor: Colors.redAccent,
              ),
              _buildStatRow(
                'Final Tilt',
                '${tilt.toStringAsFixed(1)}°',
                tilt > PhysicsConstants.maxLandingTiltDegrees
                    ? Colors.redAccent
                    : Colors.greenAccent,
                impactText:
                    isWin
                        ? '${controller.finalScoreBreakdown?.tiltPenalty ?? 0}'
                        : null,
                impactColor: Colors.redAccent,
              ),
              _buildStatRow(
                'Remaining Fuel',
                '${state.fuelMass.floor()} kg',
                Colors.cyanAccent,
                impactText:
                    isWin
                        ? '+${controller.finalScoreBreakdown?.fuelScore ?? 0}'
                        : null,
                impactColor: Colors.greenAccent,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onMenu,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade300,
                        side: BorderSide(color: Colors.grey.shade600),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'MENU',
                        style: GoogleFonts.shareTechMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withValues(alpha: 0.2),
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.shareTechMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor, {
    String? impactText,
    Color? impactColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.shareTechMono(color: Colors.grey.shade400),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (impactText != null) ...[
                Text(
                  impactText,
                  style: GoogleFonts.shareTechMono(
                    color: impactColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(value, style: GoogleFonts.shareTechMono(color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }
}
