import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback onPlayRandom;
  final VoidCallback onEnterSeed;
  final VoidCallback onLeaderboard;

  const MainMenu({
    super.key,
    required this.onPlayRandom,
    required this.onEnterSeed,
    required this.onLeaderboard,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double scale = screenWidth < 600 ? screenWidth / 600 : 1.0;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DASHLANDER',
              style: GoogleFonts.orbitron(
                fontSize: 48 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Colors.cyanAccent,
                shadows: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.8),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: Colors.pinkAccent.withValues(alpha: 0.8),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '2.5D PHYSICS SIMULATION',
              style: GoogleFonts.shareTechMono(
                color: Colors.cyan.shade200,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 64),
            _MenuButton(
              label: 'PLAY RANDOM SEED',
              color: Colors.cyanAccent,
              onTap: widget.onPlayRandom,
            ),
            const SizedBox(height: 24),
            _MenuButton(
              label: 'ENTER SEED',
              color: Colors.pinkAccent,
              onTap: widget.onEnterSeed,
            ),
            const SizedBox(height: 24),
            _MenuButton(
              label: 'LEADERBOARD',
              color: Colors.purpleAccent,
              onTap: widget.onLeaderboard,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color, width: 2),
            borderRadius: BorderRadius.circular(4),
            color:
                isHovered
                    ? widget.color.withValues(alpha: 0.2)
                    : Colors.transparent,
            boxShadow:
                isHovered
                    ? [BoxShadow(color: widget.color, blurRadius: 15)]
                    : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.shareTechMono(
              color: widget.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
