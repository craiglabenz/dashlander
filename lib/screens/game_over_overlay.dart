import 'package:flutter/material.dart';
import '../models/models.dart';

class GameOverOverlay extends StatelessWidget {
  final GameResult result;
  final VoidCallback onMenu;
  final VoidCallback onRetry;

  const GameOverOverlay({
    super.key,
    required this.result,
    required this.onMenu,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    bool isWin = result.status == GameStatus.win;
    Color primaryColor = isWin ? const Color(0xFF00FFFF) : const Color(0xFFFF0000);
    
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWin ? 'TOUCHDOWN' : 'CATASTROPHE',
              style: TextStyle(
                color: primaryColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWin ? 'Flawless execution, Commander.' : 'Structural integrity compromised.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            if (isWin) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x4D00FFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('MISSION SCORE', style: TextStyle(color: Color(0xFFAAF5FF), fontSize: 12)),
                    Text(
                      '${result.score}',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            _buildStatRow('Impact Velocity', '${(result.telemetry.vy * 10).abs().toStringAsFixed(1)} m/s', 
              (result.telemetry.vy * 10).abs() > 15 ? Colors.redAccent : Colors.greenAccent),
            const Divider(color: Colors.white24),
            _buildStatRow('Max G-Force', '${result.telemetry.maxG.toStringAsFixed(1)} G', Colors.yellowAccent),
            const Divider(color: Colors.white24),
            _buildStatRow('Remaining Fuel', '${result.telemetry.fuel.floor()} kg', const Color(0xFF00FFFF)),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMenu,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('MENU', style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('RETRY', style: TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
