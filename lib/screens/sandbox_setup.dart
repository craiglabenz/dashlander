import 'package:flutter/material.dart';
import '../models/models.dart';

class SandboxSetup extends StatefulWidget {
  final VoidCallback onBack;
  final Function(SandboxConfig) onStart;

  const SandboxSetup({
    super.key,
    required this.onBack,
    required this.onStart,
  });

  @override
  State<SandboxSetup> createState() => _SandboxSetupState();
}

class _SandboxSetupState extends State<SandboxSetup> {
  double gravity = 1.625;
  double thrust = 5.0;
  bool infiniteFuel = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050510),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SANDBOX PROTOCOL',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFFFF00FF),
                  shadows: [Shadow(color: Color(0xFFFF00FF), blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0x1AFF00FF),
                  border: Border.all(color: const Color(0x4DFF00FF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSlider(
                      label: 'Gravity',
                      value: gravity,
                      min: 0.1,
                      max: 10.0,
                      suffix: 'm/s²',
                      onChanged: (v) => setState(() => gravity = v),
                    ),
                    const SizedBox(height: 24),
                    _buildSlider(
                      label: 'Thrust Power',
                      value: thrust,
                      min: 1.0,
                      max: 20.0,
                      suffix: 'kN',
                      onChanged: (v) => setState(() => thrust = v),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Infinite Fuel', style: TextStyle(color: Color(0xFFFFAAFF), fontSize: 18)),
                        Switch(
                          value: infiniteFuel,
                          onChanged: (v) => setState(() => infiniteFuel = v),
                          activeColor: const Color(0xFFFF00FF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('CANCEL', style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                  ),
                  const SizedBox(width: 32),
                  ElevatedButton(
                    onPressed: () {
                      widget.onStart(SandboxConfig(
                        gravity: gravity,
                        thrustPower: thrust,
                        infiniteFuel: infiniteFuel,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x33FF00FF),
                      side: const BorderSide(color: Color(0xFFFF00FF)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shadowColor: const Color(0x66FF00FF),
                      elevation: 10,
                    ),
                    child: const Text(
                      'LAUNCH SIMULATION',
                      style: TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold),
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

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFFFFAAFF))),
            Text('${value.toStringAsFixed(1)} $suffix', style: const TextStyle(color: Colors.white)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFFFF00FF),
          inactiveColor: const Color(0x4DFF00FF),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
