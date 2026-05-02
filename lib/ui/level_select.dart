import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_state.dart';

import '../game/level_generator.dart';

final List<LevelData> defaultLevels = [
  LevelGenerator.generate(
    seed: 101,
    name: "Sea of Tranquility",
    initialFuel: 256,
  ),
  LevelGenerator.generate(seed: 404, name: "Tycho Crater", initialFuel: 256),
  LevelGenerator.generate(seed: 999, name: "Lunar Alps", initialFuel: 256),
];

class LevelSelect extends StatefulWidget {
  final VoidCallback onBack;
  final Function(LevelData) onSelect;

  const LevelSelect({super.key, required this.onBack, required this.onSelect});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  final TextEditingController _seedController = TextEditingController();

  void _generateCustomLevel() {
    final seedStr = _seedController.text.trim();
    if (seedStr.isNotEmpty) {
      final seed = int.tryParse(seedStr) ?? seedStr.hashCode;
      widget.onSelect(LevelGenerator.generate(seed: seed.abs()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT SECTOR',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    color: Colors.cyanAccent,
                    shadows: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children:
                      defaultLevels
                          .map(
                            (lvl) => _LevelCard(
                              level: lvl,
                              onSelect: () => widget.onSelect(lvl),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _seedController,
                        style: GoogleFonts.shareTechMono(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter custom seed...',
                          hintStyle: GoogleFonts.shareTechMono(
                            color: Colors.grey.shade600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan.shade900),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          filled: true,
                          fillColor: Colors.cyan.shade900.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        onSubmitted: (_) => _generateCustomLevel(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _generateCustomLevel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade900.withValues(
                          alpha: 0.5,
                        ),
                        side: BorderSide(
                          color: Colors.cyanAccent.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      child: Text(
                        'GENERATE',
                        style: GoogleFonts.orbitron(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                TextButton(
                  onPressed: widget.onBack,
                  child: Text(
                    '← BACK TO MENU',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.grey.shade400,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final VoidCallback onSelect;

  const _LevelCard({required this.level, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.cyan.shade900.withValues(alpha: 0.2),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              level.name,
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Fuel: ${level.initialFuel} kg',
              style: GoogleFonts.shareTechMono(
                color: Colors.cyan.shade300,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
