import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TerrainComponent extends PositionComponent with HasGameReference {
  final List<Vector2> points;
  final List<int> padIndices;

  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  double _time = 0;

  TerrainComponent({required this.points, required this.padIndices});

  @override
  Future<void> onLoad() async {
    _program = await ui.FragmentProgram.fromAsset('shaders/mesh_gradient.frag');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double depthX = -30.0;
    final double depthY = 60.0;

    // 1. Draw 3D Depth Extrusion
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final Path depthPath =
          Path()
            ..moveTo(p1.x, p1.y)
            ..lineTo(p2.x, p2.y)
            ..lineTo(p2.x + depthX, p2.y + depthY)
            ..lineTo(p1.x + depthX, p1.y + depthY)
            ..close();

      // Simple gradient simulation
      final Paint fillPaint =
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(p1.x, p1.y),
              Offset(p1.x + depthX, p1.y + depthY),
              [const Color(0xFF003333), const Color(0xFF020205)],
            );

      canvas.drawPath(depthPath, fillPaint);
      canvas.drawPath(
        depthPath,
        Paint()
          ..color = const Color(0xFF111122)
          ..style = PaintingStyle.stroke,
      );
    }

    // 2. Draw Main Front Terrain Fill
    final Path frontPath = Path();
    frontPath.moveTo(points.first.x, 2000); // far down
    for (var p in points) {
      frontPath.lineTo(p.x, p.y);
    }
    frontPath.lineTo(points.last.x, 2000);
    frontPath.close();

    final Paint frontPaint = Paint();
    if (_program != null) {
      _shader ??= _program!.fragmentShader();
      final screenSize = game.size;
      _shader!.setFloat(0, screenSize.x);
      _shader!.setFloat(1, screenSize.y);
      _shader!.setFloat(2, _time);
      _shader!.setFloat(3, 1.0); // 1.0 for foreground type
      frontPaint.shader = _shader;
    } else {
      frontPaint.color = const Color(0xFF01050A);
    }
    canvas.drawPath(frontPath, frontPaint);

    // 3. Draw Neon Surface Lines
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      bool isPad = padIndices.contains(i);

      Color baseColor =
          isPad ? const Color(0xFFFFFF00) : const Color(0xFF00FFFF);
      double width = isPad ? 4.0 : 2.0;

      // Glow layer
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        Paint()
          ..color = baseColor.withValues(alpha: 0.4)
          ..strokeWidth = width * 4
          ..strokeCap = StrokeCap.round,
      );

      // Core line
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
