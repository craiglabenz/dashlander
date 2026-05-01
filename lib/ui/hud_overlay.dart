import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_state.dart';
import '../physics/constants.dart';

class HudOverlay extends StatelessWidget {
  final GameController controller;
  final VoidCallback onExit;

  const HudOverlay({super.key, required this.controller, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.cyan.shade900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
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
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: ValueListenableBuilder<TelemetryData>(
                      valueListenable: controller.telemetry,
                      builder: (context, data, child) {
                        return Row(
                          children: [
                            Expanded(flex: 3, child: _buildFuelGauge(data.fuel, data.maxFuel)),
                            Expanded(flex: 2, child: _buildTelemetryItem(
                              'V.SPD',
                              '${data.vY.toStringAsFixed(1)} m/s',
                              data.vY > PhysicsConstants.maxLandingVelocityY
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                            )),
                            Expanded(flex: 2, child: _buildTelemetryItem(
                              'H.SPD',
                              '${data.vX.abs().toStringAsFixed(1)} m/s',
                              data.vX.abs() > PhysicsConstants.maxLandingVelocityX
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                            )),
                            Expanded(flex: 2, child: _buildTelemetryItem(
                              'TILT',
                              '${data.tilt.toStringAsFixed(1)}°',
                              data.tilt > PhysicsConstants.maxLandingTiltDegrees
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                            )),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuelGauge(double current, double max) {
    double percentage = (current / max).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FUEL',
          style: GoogleFonts.shareTechMono(
            color: Colors.cyanAccent.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade800),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 80 * percentage,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pinkAccent, Colors.cyanAccent],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.floor()} kg',
          style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTelemetryItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: Colors.cyanAccent.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
