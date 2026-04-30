import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final String subtitle = isWin ? 'Flawless execution, Commander.' : 'Structural integrity compromised.';

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 30),
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
                style: GoogleFonts.shareTechMono(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isWin) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('MISSION SCORE', style: GoogleFonts.shareTechMono(color: Colors.cyan.shade200, fontSize: 12)),
                      Text('${controller.finalScore}', style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildStatRow('Impact Velocity', '${(state.velocity.y.abs() * 10).toStringAsFixed(1)} m/s', state.velocity.y.abs() > 2.0 ? Colors.redAccent : Colors.greenAccent),
              _buildStatRow('Max G-Force', '${state.maxGForce.toStringAsFixed(1)} G', Colors.orangeAccent),
              _buildStatRow('Remaining Fuel', '${state.fuelMass.floor()} kg', Colors.cyanAccent),
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
                      child: Text('MENU', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text('RETRY', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
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

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.shareTechMono(color: Colors.grey.shade400)),
          Text(value, style: GoogleFonts.shareTechMono(color: valueColor)),
        ],
      ),
    );
  }
}
