import 'package:flutter/material.dart';
import '../models/models.dart';

class LevelSelect extends StatelessWidget {
  final VoidCallback onBack;
  final Function(LevelData) onSelect;

  const LevelSelect({
    super.key,
    required this.onBack,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050510),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SELECT SECTOR',
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFF00FFFF),
              shadows: [Shadow(color: Color(0xFF00FFFF), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              int crossAxisCount = width > 800 ? 3 : (width > 500 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 2,
                ),
                itemCount: gameLevels.length,
                itemBuilder: (context, index) {
                  final lvl = gameLevels[index];
                  return _LevelCard(
                    level: lvl,
                    onTap: () => onSelect(lvl),
                  );
                },
              );
            }
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: onBack,
            child: const Text(
              '← BACK TO MENU',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatefulWidget {
  final LevelData level;
  final VoidCallback onTap;

  const _LevelCard({required this.level, required this.onTap});

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovered ? const Color(0xFF00FFFF) : const Color(0x8000FFFF),
            ),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0x33003333),
            boxShadow: isHovered ? [const BoxShadow(color: Color(0xFF00FFFF), blurRadius: 15)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.level.name,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Fuel: ${widget.level.fuel.floor()}kg',
                style: const TextStyle(color: Color(0xFFAAF5FF), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
