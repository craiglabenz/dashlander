import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_state.dart';
import '../game/models/score_breakdown.dart';
import 'minimap.dart';

class HudOverlay extends StatelessWidget {
  final GameController controller;
  final VoidCallback onExit;

  const HudOverlay({super.key, required this.controller, required this.onExit});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double scale = screenWidth < 800 ? screenWidth / 800 : 1.0;

    return Positioned.fill(
      child: ValueListenableBuilder<TelemetryData>(
        valueListenable: controller.telemetry,
        builder: (context, data, child) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade900.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.teal.shade800.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              // Pause / Exit button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onExit,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildFuelGauge(
                                        data.fuel,
                                        data.maxFuel,
                                        scale,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildTelemetryItem(
                                        'V.SPD',
                                        '${data.vY.toStringAsFixed(1)} m/s',
                                        data.vY >
                                                ScoreBreakdown
                                                    .maxLandingVelocityY
                                            ? Colors.redAccent
                                            : Colors.cyanAccent,
                                        scale,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildTelemetryItem(
                                        'H.SPD',
                                        '${data.vX.abs().toStringAsFixed(1)} m/s',
                                        data.vX.abs() >
                                                ScoreBreakdown
                                                    .maxLandingVelocityX
                                            ? Colors.redAccent
                                            : Colors.cyanAccent,
                                        scale,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildTelemetryItem(
                                        'TILT',
                                        '${data.tilt.toStringAsFixed(1)}°',
                                        data.tilt >
                                                ScoreBreakdown
                                                    .maxLandingTiltDegrees
                                            ? Colors.redAccent
                                            : Colors.cyanAccent,
                                        scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: SafeArea(
                  child: Minimap(
                    telemetry: data,
                    levelData: controller.currentLevel!,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFuelGauge(double current, double max, double scale) {
    double percentage = (current / max).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FUEL',
          style: GoogleFonts.shareTechMono(
            color: Colors.tealAccent.shade400,
            fontSize: 11 * scale,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0 * scale,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          '${current.floor()} kg',
          style: GoogleFonts.shareTechMono(
            color: Colors.white,
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4 * scale),
        Container(
          width: 80 * scale,
          height: 6 * scale,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 80 * scale * percentage,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purpleAccent, Colors.cyanAccent],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    color: Color(0xB300FFFF),
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const _valueStyle = TextStyle(
    // color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );

  Widget _buildTelemetryItem(String label, String value, Color valueColor, double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _labelStyle.copyWith(
          fontSize: _labelStyle.fontSize! * scale,
          letterSpacing: _labelStyle.letterSpacing! * scale,
        )),
        SizedBox(height: 4 * scale),
        Text(value, style: _valueStyle.copyWith(
          color: valueColor,
          fontSize: _valueStyle.fontSize! * scale,
        )),
        SizedBox(height: 10 * scale), // Empty space to match the fuel gauge's bar
      ],
    );
  }
}
