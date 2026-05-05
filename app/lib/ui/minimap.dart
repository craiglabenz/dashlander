import 'package:flutter/material.dart';
import '../game/models/telemetry_data.dart';
import '../game/models/level_data.dart';

class Minimap extends StatefulWidget {
  final TelemetryData telemetry;
  final LevelData levelData;
  final double size;

  const Minimap({
    super.key,
    required this.telemetry,
    required this.levelData,
    this.size = 120,
  });

  @override
  State<Minimap> createState() => _MinimapState();
}

class _MinimapState extends State<Minimap> {
  final List<Offset> _path = [];

  @override
  void initState() {
    super.initState();
    _path.add(Offset(widget.telemetry.x, widget.telemetry.y));
  }

  @override
  void didUpdateWidget(Minimap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the level changes, or the ship teleports a huge distance (e.g., game restart), clear the path.
    final newPos = Offset(widget.telemetry.x, widget.telemetry.y);
    if (oldWidget.levelData.id != widget.levelData.id ||
        (_path.isNotEmpty && (_path.last - newPos).distance > 1000)) {
      _path.clear();
      _path.add(newPos);
      return;
    }

    if (oldWidget.telemetry.x != widget.telemetry.x ||
        oldWidget.telemetry.y != widget.telemetry.y) {
      if (_path.isEmpty || (_path.last - newPos).distance > 10.0) {
        _path.add(newPos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _MinimapPainter(widget.telemetry, widget.levelData, _path),
        ),
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  final TelemetryData telemetry;
  final LevelData levelData;
  final List<Offset> path;

  _MinimapPainter(this.telemetry, this.levelData, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    // The physics space extends slightly past the moon radius (up to +3000).
    // Let's use moonRadius + maxTerrainHeight + 1500 as the visible edge of the minimap.
    final double maxDrawRadius =
        levelData.radius + levelData.maxTerrainHeight + 1500;

    // The center of the CustomPaint canvas represents the origin (0,0), which is the center of the moon.
    final Offset center = Offset(size.width / 2, size.height / 2);

    // How many pixels on the canvas equals 1 pixel in the physics space?
    final double scale = (size.width / 2) / maxDrawRadius;

    // Draw the moon's core (the base spherical shape beneath the terrain)
    final Paint moonCorePaint =
        Paint()
          ..color = Colors.grey.shade900
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, levelData.radius * scale, moonCorePaint);

    // Draw the terrain topology
    final Paint terrainOutlinePaint =
        Paint()
          ..color = Colors.cyan.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final Paint padPaint =
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    for (int i = 0; i < levelData.terrainPoints.length - 1; i++) {
      final p1 = levelData.terrainPoints[i];
      final p2 = levelData.terrainPoints[i + 1];

      final Offset drawP1 = center + Offset(p1.x * scale, p1.y * scale);
      final Offset drawP2 = center + Offset(p2.x * scale, p2.y * scale);

      if (levelData.padIndices.contains(i)) {
        canvas.drawLine(drawP1, drawP2, padPaint);
      } else {
        canvas.drawLine(drawP1, drawP2, terrainOutlinePaint);
      }
    }

    // Draw the ship's path
    if (path.length > 1) {
      final Paint pathPaint =
          Paint()
            ..color = Colors.pinkAccent.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;

      final Path drawPath = Path();
      final Offset firstPos =
          center + Offset(path.first.dx * scale, path.first.dy * scale);
      drawPath.moveTo(firstPos.dx, firstPos.dy);

      for (int i = 1; i < path.length; i++) {
        final Offset p =
            center + Offset(path[i].dx * scale, path[i].dy * scale);
        drawPath.lineTo(p.dx, p.dy);
      }

      // Draw line to current exact position
      final Offset currentPos =
          center + Offset(telemetry.x * scale, telemetry.y * scale);
      drawPath.lineTo(currentPos.dx, currentPos.dy);

      canvas.drawPath(drawPath, pathPaint);
    }

    // Draw the ship
    final Paint shipPaint =
        Paint()
          ..color = Colors.pinkAccent
          ..style = PaintingStyle.fill;

    // Ship position is in game coordinates where origin is (0,0) at center of moon.
    final Offset shipOffset =
        center + Offset(telemetry.x * scale, telemetry.y * scale);

    canvas.drawCircle(
      shipOffset,
      2.0,
      shipPaint,
    ); // 2.0 radius makes it a tiny dot
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) {
    return oldDelegate.telemetry.x != telemetry.x ||
        oldDelegate.telemetry.y != telemetry.y;
  }
}
