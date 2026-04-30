import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../physics/lander_state.dart';

class ShipComponent extends PositionComponent {
  final LanderState state;
  final bool isGhost;
  bool isThrusting = false;

  late final Paint _hullPaint;
  late final Paint _hullStrokePaint;
  late final Paint _legPaint;
  late final Paint _windowPaint;

  bool isVisible = true;

  final Color? tintColor;

  ShipComponent({required this.state, this.isGhost = false, this.tintColor})
    : super(anchor: Anchor.center, size: Vector2(36, 36)) {
    final opacity =
        isGhost ? 0.4 : 1.0; // Slightly higher opacity for visibility

    final mainColor = tintColor ?? const Color(0xFFFF00FF);
    final secondaryColor = tintColor ?? const Color(0xFF00FFFF);

    _hullPaint =
        Paint()
          ..color = const Color(0xFF111111).withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

    _hullStrokePaint =
        Paint()
          ..color = mainColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    _legPaint =
        Paint()
          ..color = secondaryColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    _windowPaint =
        Paint()
          ..color = secondaryColor.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Draw Glow (simulate with shadows)
    if (!isGhost) {
      canvas.saveLayer(
        null,
        Paint()
          ..imageFilter = const ColorFilter.mode(
            Color(0x80FF00FF),
            BlendMode.srcATop,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      _drawHull(canvas, isGlow: true);
      canvas.restore();
    }

    // Draw Main Ship
    _drawHull(canvas, isGlow: false);

    // Draw Legs
    // Left leg
    canvas.drawLine(const Offset(-8, 8), const Offset(-14, 18), _legPaint);
    canvas.drawLine(const Offset(-14, 18), const Offset(-18, 18), _legPaint);
    // Right leg
    canvas.drawLine(const Offset(8, 8), const Offset(14, 18), _legPaint);
    canvas.drawLine(const Offset(14, 18), const Offset(18, 18), _legPaint);

    // Draw Window
    canvas.drawCircle(const Offset(0, -2), 4, _windowPaint);

    canvas.restore();
  }

  void _drawHull(Canvas canvas, {required bool isGlow}) {
    final Path path = Path();
    path.moveTo(0, -16); // Nose
    path.lineTo(10, 8); // Right wing
    path.lineTo(6, 12); // Right engine base
    path.lineTo(-6, 12); // Left engine base
    path.lineTo(-10, 8); // Left wing
    path.close();

    if (!isGlow) {
      canvas.drawPath(path, _hullPaint);
      canvas.drawPath(path, _hullStrokePaint);
    } else {
      canvas.drawPath(path, Paint()..color = const Color(0xFFFF00FF));
    }
  }
}
