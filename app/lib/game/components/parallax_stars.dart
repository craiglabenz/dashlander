import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParallaxStars extends Component with HasGameReference {
  final List<_Star> _stars = [];
  final Random _rnd = Random();

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 150; i++) {
      _stars.add(
        _Star(
          x: _rnd.nextDouble() * 3000 - 500,
          y: _rnd.nextDouble() * 2000 - 500,
          size: _rnd.nextDouble() * 1.5,
          alpha: _rnd.nextDouble(),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Get camera position
    final cameraPos = game.camera.viewfinder.position;

    final Paint paint = Paint()..color = Colors.white;

    for (var s in _stars) {
      // Simple parallax offset relative to camera
      double sx = s.x - cameraPos.x * 0.1;
      double sy = s.y - cameraPos.y * 0.1;

      // Wrap stars so they never run out
      sx = ((sx % 3000) + 3000) % 3000 - 500;
      sy = ((sy % 2000) + 2000) % 2000 - 500;

      paint.color = Colors.white.withValues(alpha: s.alpha);
      canvas.drawCircle(Offset(sx, sy), s.size, paint);
    }
  }
}

class _Star {
  double x, y, size, alpha;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.alpha,
  });
}
