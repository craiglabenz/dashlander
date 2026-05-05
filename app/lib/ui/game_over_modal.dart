import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/game_state.dart';
import '../game/models/score_breakdown.dart';

class GameOverModal extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  final VoidCallback onNext;

  const GameOverModal({
    super.key,
    required this.controller,
    required this.onRetry,
    required this.onMenu,
    required this.onNext,
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

    final metrics = controller.finalMetrics;
    if (metrics == null) return const SizedBox.shrink();

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
                      if (controller.targetGhostReplay != null) ...[
                        const SizedBox(height: 8),
                        Divider(
                          color: Colors.cyan.shade700.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'GHOST SCORE',
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${controller.targetGhostReplay!.score}',
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.deepOrangeAccent.shade100,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'DIFFERENCE',
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.grey.shade400,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${controller.finalScore >= controller.targetGhostReplay!.score ? '+' : ''}${controller.finalScore - controller.targetGhostReplay!.score}',
                                  style: GoogleFonts.shareTechMono(
                                    color:
                                        controller.finalScore >=
                                                controller
                                                    .targetGhostReplay!
                                                    .score
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildStatRow(
                'Landing Pad',
                state.padIndex != null
                    ? 'Segment ${state.padIndex}'
                    : 'Off-pad Crash',
                Colors.white70,
              ),
              if (!isWin) ...[
                _buildStatRow(
                  'Vert. Velocity',
                  '${metrics.impactVelocityMetersPerSecond.toStringAsFixed(1)} m/s',
                  metrics.impactVelocityMetersPerSecond >
                          ScoreBreakdown.maxLandingVelocityY
                      ? Colors.redAccent
                      : Colors.greenAccent,
                ),
                _buildStatRow(
                  'Horiz. Velocity',
                  '${metrics.horizontalVelocityMetersPerSecond.abs().toStringAsFixed(1)} m/s',
                  metrics.horizontalVelocityMetersPerSecond.abs() >
                          ScoreBreakdown.maxLandingVelocityX
                      ? Colors.redAccent
                      : Colors.greenAccent,
                ),
              ] else ...[
                _buildStatRow(
                  'Impact Velocity',
                  '${metrics.impactVelocityMetersPerSecond.toStringAsFixed(1)} m/s',
                  metrics.impactVelocityMetersPerSecond >
                          ScoreBreakdown.maxLandingVelocityY
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  impactText:
                      isWin
                          ? '${controller.finalScoreBreakdown!.velocityScore >= 0 ? '+' : ''}${controller.finalScoreBreakdown?.velocityScore ?? 0}'
                          : null,
                  impactColor:
                      (controller.finalScoreBreakdown?.velocityScore ?? 0) >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                ),
              ],
              _buildStatRow(
                'Tilt Delta',
                '${metrics.finalTiltDeg.toStringAsFixed(1)}°',
                metrics.finalTiltDeg > ScoreBreakdown.maxLandingTiltDegrees
                    ? Colors.redAccent
                    : Colors.greenAccent,
                impactText:
                    isWin
                        ? '${controller.finalScoreBreakdown!.tiltScore >= 0 ? '+' : ''}${controller.finalScoreBreakdown?.tiltScore ?? 0}'
                        : null,
                impactColor:
                    (controller.finalScoreBreakdown?.tiltScore ?? 0) >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
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
              if (isWin) ...[
                const SizedBox(height: 8),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                _buildStatRow(
                  'Base Score',
                  '${controller.finalScoreBreakdown?.totalScore ?? 0}',
                  Colors.white70,
                ),
                _buildStatRow(
                  'Difficulty Multiplier',
                  'x${controller.finalScoreBreakdown?.difficultyMultiplier.toStringAsFixed(2) ?? "1.00"}',
                  Colors.orangeAccent,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    flex: 1,
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
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: onNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.cyanAccent,
                        side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'NEXT',
                        style: GoogleFonts.shareTechMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.shareTechMono(color: Colors.grey.shade400),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (impactText != null) ...[
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        impactText,
                        style: GoogleFonts.shareTechMono(
                          color: impactColor ?? Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      style: GoogleFonts.shareTechMono(color: valueColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///
extension DebuggableWidget on Widget {
  ///
  Widget border({Color? color}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? const Color.from(alpha: 1, red: 1, green: 0, blue: 0),
        ),
      ),
      child: this,
    );
  }

  ///
  Widget withBorder({Color? color}) => border(color: color);
}
