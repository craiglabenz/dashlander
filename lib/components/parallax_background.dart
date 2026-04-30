import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Star {
  double x, y, size, alpha;
  Star(this.x, this.y, this.size, this.alpha);
}

class ParallaxBackground extends Component {
  final List<Star> stars = [];
  final Random rnd = Random();
  late CameraComponent camera;
  
  final Paint whitePaint = Paint()..color = Colors.white;

  ParallaxBackground() {
    for (int i = 0; i < 150; i++) {
      stars.add(Star(
        rnd.nextDouble() * 3000 - 500,
        rnd.nextDouble() * 2000 - 500,
        rnd.nextDouble() * 1.5,
        rnd.nextDouble(),
      ));
    }
  }
  
  @override
  void onMount() {
    super.onMount();
    // Assuming the parent is a FlameGame, but we will pass camera reference if needed, 
    // or just rely on global position.
    // Wait, in Flame 1.x with CameraComponent, ParallaxBackground is usually added to the viewport, 
    // or we just draw it and offset based on camera's viewFinder.position.
  }

  @override
  void render(Canvas canvas) {
    // If we add this to the Viewport or HUD, it won't move with the world.
    // We can fetch the camera's position from the game ref if needed.
    // For now, let's assume we handle the parallax offset externally or just render stars statically.
    // Actually, since it's added to the World, it moves 1:1 with camera.
    // To make it parallax, we want to negate some of the camera movement.
    
    for (var s in stars) {
      whitePaint.color = Colors.white.withOpacity(s.alpha);
      canvas.drawCircle(Offset(s.x, s.y), s.size, whitePaint);
    }
  }
}
