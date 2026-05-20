import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../gen/version.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback onPlayRandom;
  final VoidCallback onEnterSeed;
  final VoidCallback onLeaderboard;
  final ValueNotifier<bool> invertControls;

  const MainMenu({
    super.key,
    required this.onPlayRandom,
    required this.onEnterSeed,
    required this.onLeaderboard,
    required this.invertControls,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _showSettings = false;

  Widget _buildSettingsPanel() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showSettings = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from closing panel
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 380,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SETTINGS',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent,
                              letterSpacing: 2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.pinkAccent),
                            onPressed: () => setState(() => _showSettings = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.invertControls,
                        builder: (context, invert, child) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade900.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'INVERT CONTROLS',
                                      style: GoogleFonts.shareTechMono(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Switch(
                                      value: invert,
                                      activeThumbColor: Colors.cyanAccent,
                                      activeTrackColor: Colors.cyan.shade900,
                                      inactiveThumbColor: Colors.grey.shade400,
                                      inactiveTrackColor: Colors.grey.shade800,
                                      onChanged: (val) {
                                        widget.invertControls.value = val;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Flips the left and right RCS thruster inputs. Keeps the main thruster active on the top half.',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double scale = screenWidth < 600 ? screenWidth / 600 : 1.0;

    return Stack(
      children: [
        Container(
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
                  'RCS METEOR LANDER',
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
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: _SettingsButton(
              onTap: () => setState(() => _showSettings = true),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: SafeArea(
            child: Text(
              'v$appVersion',
              style: GoogleFonts.shareTechMono(
                color: Colors.cyanAccent.withValues(alpha: 0.4),
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (_showSettings) _buildSettingsPanel(),
      ],
    );
  }
}

class _SettingsButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _rotationController.repeat();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _rotationController.stop();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.cyan.shade900.withValues(alpha: 0.4)
                : Colors.cyan.shade900.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? Colors.cyanAccent
                  : Colors.cyanAccent.withValues(alpha: 0.3),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: RotationTransition(
            turns: _rotationController,
            child: const Icon(
              Icons.settings,
              color: Colors.cyanAccent,
              size: 24,
            ),
          ),
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
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
            color:
                isHovered
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
            boxShadow:
                isHovered
                    ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 15,
                      ),
                    ]
                    : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.shareTechMono(
              color: isHovered ? Colors.white : color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }

  // Helper getters to simplify code
  Color get color => widget.color;
}
