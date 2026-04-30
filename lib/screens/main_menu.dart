import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final VoidCallback onPlayCampaign;
  final VoidCallback onPlaySandbox;

  const MainMenu({
    super.key,
    required this.onPlayCampaign,
    required this.onPlaySandbox,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050510).withOpacity(0.8), // Assuming black/80
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
              ).createShader(bounds),
              child: const Text(
                'NEON\nLANDER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Color(0xCC00FFFF), blurRadius: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '2.5D PHYSICS SIMULATION',
              style: TextStyle(
                color: Color(0xFFAAF5FF),
                letterSpacing: 4,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 64),
            _MenuButton(
              label: 'CAMPAIGN MODE',
              color: const Color(0xFF00FFFF),
              onTap: onPlayCampaign,
            ),
            const SizedBox(height: 24),
            _MenuButton(
              label: 'SANDBOX MODE',
              color: const Color(0xFFFF00FF),
              onTap: onPlaySandbox,
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
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color, width: 2),
            borderRadius: BorderRadius.circular(4),
            color: isHovered ? widget.color.withOpacity(0.4) : Colors.transparent,
            boxShadow: isHovered ? [BoxShadow(color: widget.color, blurRadius: 15)] : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: isHovered ? Colors.white : widget.color.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
