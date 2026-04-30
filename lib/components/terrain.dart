import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../models/models.dart';

class Terrain extends Component {
  final List<TerrainPoint> points;
  
  final Paint fillDark = Paint()
    ..color = const Color(0xFF01050A)
    ..style = PaintingStyle.fill;
    
  final Paint neonCyan = Paint()
    ..color = const Color(0xFF00FFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);
    
  final Paint padYellow = Paint()
    ..color = const Color(0xFFFFFF00)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    
  final Paint strokeWhite = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Terrain({required this.points});

  @override
  void render(Canvas canvas) {
    if (points.isEmpty) return;
    
    // 1. Draw 2.5D Extruded Plains (Depth effect)
    const double depthX = -30;
    const double depthY = 60;
    
    for (int i = 0; i < points.length - 1; i++) {
      var p1 = points[i];
      var p2 = points[i + 1];
      
      Path face = Path()
        ..moveTo(p1.x, p1.y)
        ..lineTo(p2.x, p2.y)
        ..lineTo(p2.x + depthX, p2.y + depthY)
        ..lineTo(p1.x + depthX, p1.y + depthY)
        ..close();
        
      var gradient = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF003333), Color(0xFF020205)],
        ).createShader(Rect.fromPoints(Offset(p1.x, p1.y), Offset(p1.x + depthX, p1.y + depthY)))
        ..style = PaintingStyle.fill;
        
      var strokeDark = Paint()
        ..color = const Color(0xFF111122)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
        
      canvas.drawPath(face, gradient);
      canvas.drawPath(face, strokeDark);
    }
    
    // 2. Draw front-facing Terrain Fill
    Path front = Path()
      ..moveTo(points.first.x, 3000) // far down
      ;
    for (var p in points) {
      front.lineTo(p.x, p.y);
    }
    front.lineTo(points.last.x, 3000);
    front.close();
    canvas.drawPath(front, fillDark);
    
    // 3. Draw Neon Surface Lines
    for (int i = 0; i < points.length - 1; i++) {
      var p1 = points[i];
      var p2 = points[i + 1];
      bool isPad = p1.isPad && p2.isPad;
      
      var paintGlow = isPad ? padYellow : neonCyan;
      var paintStroke = strokeWhite..strokeWidth = isPad ? 4 : 2;
      
      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paintGlow);
      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paintStroke);
    }
  }
}
