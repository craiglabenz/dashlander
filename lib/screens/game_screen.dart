import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../game/dashlander_game.dart';
import 'game_over_overlay.dart';

class GameScreen extends StatefulWidget {
  final LevelData level;
  final SandboxConfig sandboxConfig;
  final VoidCallback onExit;

  const GameScreen({
    super.key,
    required this.level,
    required this.sandboxConfig,
    required this.onExit,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DashlanderGame game;
  Telemetry telemetry = Telemetry();
  GameResult? result;

  @override
  void initState() {
    super.initState();
    _initGame();
  }
  
  void _initGame() {
    setState(() => result = null);
    game = DashlanderGame(
      level: widget.level,
      sandboxConfig: widget.sandboxConfig,
      onTelemetryUpdate: (t) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              telemetry = t;
            });
          }
        });
      },
      onGameOver: (r) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              result = r;
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: game),
          
          // HUD Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x4D003333),
                    border: Border.all(color: const Color(0x4D00FFFF)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x1A00FFFF), blurRadius: 20)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exit Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: widget.onExit,
                      ),
                      
                      // Telemetry Items
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          runSpacing: 12,
                          spacing: 4,
                          children: [
                            _TelemetryItem(
                              label: 'FUEL',
                              value: '${telemetry.fuel.floor()} kg',
                              isCritical: telemetry.fuel < telemetry.maxFuel * 0.2,
                              child: Container(
                                width: 80,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade800),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: telemetry.maxFuel > 0 ? (telemetry.fuel / telemetry.maxFuel).clamp(0.0, 1.0) : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFFFF00FF), Color(0xFF00FFFF)]),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _TelemetryItem(
                              label: 'V.SPD',
                              value: '${(telemetry.vy * 10).toStringAsFixed(1)} m/s',
                              isCritical: telemetry.vy * 10 > 15,
                            ),
                            _TelemetryItem(
                              label: 'H.SPD',
                              value: '${(telemetry.vx * 10).toStringAsFixed(1)} m/s',
                              isCritical: (telemetry.vx * 10).abs() > 8,
                            ),
                            _TelemetryItem(
                              label: 'G-FORCE',
                              value: '${telemetry.gForce.toStringAsFixed(1)} G',
                              isCritical: telemetry.gForce > 3.0,
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
          
          if (result != null)
            GameOverOverlay(
              result: result!,
              onMenu: widget.onExit,
              onRetry: _initGame,
            ),
        ],
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isCritical;
  final Widget? child;

  const _TelemetryItem({
    required this.label,
    required this.value,
    this.isCritical = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xB300FFFF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCritical ? const Color(0xFFFF4444) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
