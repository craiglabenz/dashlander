import 'dart:ui' as ui;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TerrainComponent extends PositionComponent with HasGameReference {
  final List<Vector2> points;
  final List<int> padIndices;
  final Map<int, double> padAngles;
  final Map<int, double> padAngleDeltas;

  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  double _time = 0;

  TerrainComponent({
    required this.points,
    required this.padIndices,
    required this.padAngles,
    required this.padAngleDeltas,
  });

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

    // 1. Draw 3D Depth Extrusion
    // This creates a "crust" beneath the bright neon surface lines.
    // It loops over each segment of the terrain boundary.
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Depth vectors pointing INWARDS towards the center of the moon (0,0).
      // We normalize the point (which gets a vector pointing from center to point),
      // then negate it and multiply by our desired crust thickness (60).
      final Vector2 d1 = -p1.normalized() * 60.0;
      final Vector2 d2 = -p2.normalized() * 60.0;

      // Create a quadrilateral representing the slice of crust for this segment.
      final Path depthPath =
          Path()
            ..moveTo(p1.x, p1.y) // Top-left of segment
            ..lineTo(p2.x, p2.y) // Top-right of segment
            ..lineTo(p2.x + d2.x, p2.y + d2.y) // Bottom-right (deep underground)
            ..lineTo(p1.x + d1.x, p1.y + d1.y) // Bottom-left (deep underground)
            ..close();

      // Simple gradient simulation
      final Paint fillPaint =
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(p1.x, p1.y),
              Offset(p1.x + d1.x, p1.y + d1.y),
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
    // Since the moon is a complete circle, the `points` array loops back to its start.
    // By simply drawing a path through all the points and closing it, we draw a 
    // massive solid polygon representing the inside volume of the entire moon!
    // This solid fill obscures the background parallax stars.
    final Path frontPath = Path();
    frontPath.moveTo(points.first.x, points.first.y);
    for (var p in points) {
      frontPath.lineTo(p.x, p.y);
    }
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
    // These bright lines define the precise collision boundary for the lander.
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // If this segment is part of a landing pad, give it a different color and thickness.
      bool isPad = padIndices.contains(i);

      Color baseColor =
          isPad ? const Color(0xFFFFFF00) : const Color(0xFF00FFFF);
      double width = isPad ? 4.0 : 2.0;

      // Glow layer: Draw a thick, transparent version of the line first.
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        Paint()
          ..color = baseColor.withValues(alpha: 0.4)
          ..strokeWidth = width * 4
          ..strokeCap = StrokeCap.round,
      );

      // Core layer: Draw the thin, bright white center line on top.
      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Draw Pad Angles
    for (int segmentIdx in padIndices) {
      Vector2 p1 = points[segmentIdx];
      Vector2 p2 = points[(segmentIdx + 1) % (points.length - 1)];
      Vector2 mid = (p1 + p2) / 2;
      
      double absoluteAngleDeg = padAngles[segmentIdx] ?? 0;
      double deltaDeg = padAngleDeltas[segmentIdx] ?? 0;
      double absoluteAngleRad = absoluteAngleDeg * pi / 180;
      
      // Vector pointing OUT from the moon
      Vector2 normal = Vector2(sin(absoluteAngleRad), -cos(absoluteAngleRad));
      
      // Push text outward by 40 physics units so it sits directly below the line
      Vector2 textPos = mid - normal * 30;
      
      final textSpan = TextSpan(
        text: '${deltaDeg > 0 ? '+' : ''}${deltaDeg.toStringAsFixed(1)}°',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(textPos.x, textPos.y);
      canvas.rotate(absoluteAngleRad);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }
}
