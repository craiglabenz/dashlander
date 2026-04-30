import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/components.dart';
import '../game/game_state.dart';

final List<LevelData> defaultLevels = [
  LevelData(
    id: 1,
    name: "Sea of Tranquility",
    initialFuel: 1000,
    terrainPoints: [
      Vector2(0, 600), Vector2(200, 550), Vector2(350, 650),
      Vector2(450, 650), Vector2(600, 650), // Pad between indices 3 and 4
      Vector2(800, 500), Vector2(1000, 700), Vector2(1200, 600), Vector2(1500, 600)
    ],
    padIndices: [3],
    startPosition: Vector2(100, 100),
  ),
  LevelData(
    id: 2,
    name: "Tycho Crater",
    initialFuel: 800,
    terrainPoints: [
      Vector2(0, 400), Vector2(150, 300), Vector2(250, 500),
      Vector2(400, 800), Vector2(500, 800), Vector2(600, 800), // Pads 3-4 and 4-5
      Vector2(750, 450), Vector2(900, 350), Vector2(1100, 650), Vector2(1500, 500)
    ],
    padIndices: [3, 4],
    startPosition: Vector2(100, 100),
  ),
  LevelData(
    id: 3,
    name: "Lunar Alps",
    initialFuel: 600,
    terrainPoints: [
      Vector2(0, 700), Vector2(200, 700), Vector2(300, 400),
      Vector2(450, 300), Vector2(600, 600), Vector2(700, 750),
      Vector2(800, 750), Vector2(880, 750), // Pad 6-7
      Vector2(950, 500), Vector2(1100, 200), Vector2(1300, 400), Vector2(1500, 800)
    ],
    padIndices: [6],
    startPosition: Vector2(150, 100),
  ),
];

class LevelSelect extends StatelessWidget {
  final VoidCallback onBack;
  final Function(LevelData) onSelect;

  const LevelSelect({super.key, required this.onBack, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.8),
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
                shadows: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: defaultLevels.map((lvl) => _LevelCard(level: lvl, onSelect: () => onSelect(lvl))).toList(),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: onBack,
              child: Text(
                '← BACK TO MENU',
                style: GoogleFonts.shareTechMono(color: Colors.grey.shade400, letterSpacing: 2),
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
          color: Colors.cyan.shade900.withOpacity(0.2),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              level.name,
              style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Fuel: ${level.initialFuel} kg',
              style: GoogleFonts.shareTechMono(color: Colors.cyan.shade300, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
