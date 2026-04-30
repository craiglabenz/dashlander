import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Particle {
  Vector2 position;
  Vector2 velocity;
  double life;
  double maxLife;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
  });
}

class ExhaustParticleSystem extends Component {
  final List<Particle> _particles = [];
  final math.Random _rnd = math.Random();
  
  final Color neonOrange = const Color(0xFFFFAA00);
  final Color neonPink = const Color(0xFFFF00FF);
  final Color neonCyan = const Color(0xFF00FFFF);

  void spawn(Vector2 pos, double shipAngle, double shipVx, double shipVy) {
    for (int i = 0; i < 2; i++) {
      _particles.add(Particle(
        position: pos.clone()
          ..add(Vector2((_rnd.nextDouble() - 0.5) * 6, (_rnd.nextDouble() - 0.5) * 6)),
        velocity: Vector2(
          shipVx - math.sin(shipAngle) * 2 + (_rnd.nextDouble() - 0.5),
          shipVy + math.cos(shipAngle) * 2 + (_rnd.nextDouble() - 0.5),
        ),
        life: 0.5 + _rnd.nextDouble() * 0.5,
        maxLife: 1.0,
        color: _rnd.nextBool() ? neonOrange : neonPink,
      ));
    }
  }
  
  void explode(Vector2 pos) {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        position: pos.clone(),
        velocity: Vector2(
          (_rnd.nextDouble() - 0.5) * 15,
          (_rnd.nextDouble() - 0.5) * 15,
        ),
        life: 1.0 + _rnd.nextDouble() * 1.0,
        maxLife: 2.0,
        color: _rnd.nextBool() ? neonPink : neonCyan,
      ));
    }
  }

  @override
  void update(double dt) {
    for (int i = _particles.length - 1; i >= 0; i--) {
      var p = _particles[i];
      p.position.add(p.velocity * (dt * 60)); // Normalize velocity to 60fps frame delta
      p.life -= dt;
      if (p.life <= 0) {
        _particles.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (var p in _particles) {
      double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      Paint paint = Paint()
        ..color = p.color.withOpacity(alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5); // Glow effect
        
      canvas.drawCircle(p.position.toOffset(), 3.0, paint);
    }
  }
}
