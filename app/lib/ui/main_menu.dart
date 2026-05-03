import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenu extends StatefulWidget {
  final Function(int) onPlayCampaign;
  final Function(int) onPlaySandbox;
  final VoidCallback onLeaderboard;

  const MainMenu({
    super.key,
    required this.onPlayCampaign,
    required this.onPlaySandbox,
    required this.onLeaderboard,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int ghostShipsCount = 0;

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
            const SizedBox(height: 48),
            _buildGhostShipsSelector(),
            const SizedBox(height: 48),
            _MenuButton(
              label: 'CAMPAIGN MODE',
              color: Colors.cyanAccent,
              onTap: () => widget.onPlayCampaign(ghostShipsCount),
            ),
            const SizedBox(height: 24),
            _MenuButton(
              label: 'SANDBOX MODE',
              color: Colors.pinkAccent,
              onTap: () => widget.onPlaySandbox(ghostShipsCount),
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

  Widget _buildGhostShipsSelector() {
    return Column(
      children: [
        Text(
          'GHOST SHIPS: $ghostShipsCount',
          style: GoogleFonts.shareTechMono(
            color: Colors.purpleAccent,
            fontSize: 18,
          ),
        ),
        SizedBox(
          width: 300,
          child: Slider(
            value: ghostShipsCount.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.purple.shade900,
            onChanged: (v) => setState(() => ghostShipsCount = v.toInt()),
          ),
        ),
      ],
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
