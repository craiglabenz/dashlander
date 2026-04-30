import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_state.dart';
import 'level_select.dart'; // For defaultLevels

class SandboxSetup extends StatefulWidget {
  final VoidCallback onBack;
  final Function(SandboxConfig, LevelData) onStart;

  const SandboxSetup({super.key, required this.onBack, required this.onStart});

  @override
  State<SandboxSetup> createState() => _SandboxSetupState();
}

class _SandboxSetupState extends State<SandboxSetup> {
  double gravity = 0.04;
  double thrustPower = 0.12;
  bool infiniteFuel = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SANDBOX PROTOCOL',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  color: Colors.pinkAccent,
                  shadows: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.8), blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.pink.shade900.withOpacity(0.1),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSlider(
                      'GRAVITY', 
                      '${(gravity * 100).toStringAsFixed(1)} m/s²', 
                      gravity, 0.01, 0.1, 
                      (v) => setState(() => gravity = v)
                    ),
                    const SizedBox(height: 24),
                    _buildSlider(
                      'THRUST POWER', 
                      '${(thrustPower * 100).toStringAsFixed(1)} kN', 
                      thrustPower, 0.05, 0.3, 
                      (v) => setState(() => thrustPower = v)
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INFINITE FUEL', style: GoogleFonts.shareTechMono(color: Colors.pink.shade200)),
                        Switch(
                          value: infiniteFuel,
                          activeColor: Colors.pinkAccent,
                          onChanged: (v) => setState(() => infiniteFuel = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      side: BorderSide(color: Colors.grey.shade600),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text('CANCEL', style: GoogleFonts.shareTechMono()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final config = SandboxConfig(gravity: gravity, thrustPower: thrustPower, infiniteFuel: infiniteFuel);
                      widget.onStart(config, defaultLevels[0]); // Just use first level terrain for sandbox
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade900.withOpacity(0.5),
                      foregroundColor: Colors.pink.shade100,
                      side: const BorderSide(color: Colors.pinkAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shadowColor: Colors.pinkAccent,
                      elevation: 10,
                    ),
                    child: Text('LAUNCH SIMULATION', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildSlider(String label, String valueStr, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.shareTechMono(color: Colors.pink.shade200)),
            Text(valueStr, style: GoogleFonts.shareTechMono(color: Colors.white)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.pinkAccent,
          inactiveColor: Colors.pink.shade900,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
