import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:dashlander/physics/math_utils.dart';

void main() {
  group('MathUtils', () {
    group('calculateAbsoluteAngleDeg', () {
      test('normal pointing UP (0 degrees)', () {
        Vector2 normal = Vector2(0, -1);
        expect(MathUtils.calculateAbsoluteAngleDeg(normal), closeTo(0.0, 0.0001));
      });

      test('normal pointing RIGHT (90 degrees)', () {
        Vector2 normal = Vector2(1, 0);
        expect(MathUtils.calculateAbsoluteAngleDeg(normal), closeTo(90.0, 0.0001));
      });

      test('normal pointing DOWN (180 degrees)', () {
        Vector2 normal = Vector2(0, 1);
        expect(MathUtils.calculateAbsoluteAngleDeg(normal), closeTo(180.0, 0.0001));
      });

      test('normal pointing LEFT (270 degrees)', () {
        Vector2 normal = Vector2(-1, 0);
        expect(MathUtils.calculateAbsoluteAngleDeg(normal), closeTo(270.0, 0.0001));
      });
    });

    group('calculateRelativeTiltDeg', () {
      test('perfectly aligned at top of moon', () {
        // Position at top of moon (Y is negative)
        Vector2 pos = Vector2(0, -100);
        // Angle is 0 (upright)
        double absoluteAngle = 0.0;
        
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: absoluteAngle,
        );
        expect(tilt, closeTo(0.0, 0.0001));
      });

      test('perfectly aligned at bottom of moon', () {
        // Position at bottom of moon
        Vector2 pos = Vector2(0, 100);
        // Angle is 180 (upside down)
        double absoluteAngle = 180.0;
        
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: absoluteAngle,
        );
        expect(tilt, closeTo(0.0, 0.0001));
      });

      test('tilted +15 degrees at right side of moon', () {
        // Position at right side
        Vector2 pos = Vector2(100, 0);
        // Spherical normal is 90 degrees. We tilt it by +15, so 105 degrees.
        double absoluteAngle = 105.0;
        
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: absoluteAngle,
        );
        expect(tilt, closeTo(15.0, 0.0001));
      });

      test('tilted -45 degrees at left side of moon', () {
        // Position at left side
        Vector2 pos = Vector2(-100, 0);
        // Spherical normal is 270 degrees. We tilt it by -45, so 225 degrees.
        double absoluteAngle = 225.0;
        
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: absoluteAngle,
        );
        expect(tilt, closeTo(-45.0, 0.0001));
      });

      test('wraps around -180/180 boundary correctly', () {
        // Position at top
        Vector2 pos = Vector2(0, -100);
        // Spherical normal is 0 degrees.
        // If absolute angle is 350 degrees, the relative tilt should be -10 degrees.
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: 350.0,
        );
        expect(tilt, closeTo(-10.0, 0.0001));
      });
      
      test('wraps around 360 values correctly', () {
        Vector2 pos = Vector2(0, -100); // spherical angle = 0
        double tilt = MathUtils.calculateRelativeTiltDeg(
          position: pos,
          absoluteAngleDeg: 730.0, // 730 % 360 = 10
        );
        expect(tilt, closeTo(10.0, 0.0001));
      });
    });

    group('calculateTiltDifference', () {
      test('simple difference', () {
        expect(MathUtils.calculateTiltDifference(10.0, 20.0), closeTo(10.0, 0.0001));
      });

      test('negative values', () {
        expect(MathUtils.calculateTiltDifference(-10.0, -20.0), closeTo(10.0, 0.0001));
      });

      test('crossing zero', () {
        expect(MathUtils.calculateTiltDifference(-10.0, 10.0), closeTo(20.0, 0.0001));
      });

      test('wrapping around 360', () {
        expect(MathUtils.calculateTiltDifference(350.0, 10.0), closeTo(20.0, 0.0001));
      });

      test('wrapping around 360 negative', () {
        expect(MathUtils.calculateTiltDifference(-10.0, 10.0), closeTo(20.0, 0.0001));
      });
      
      test('180 difference', () {
        expect(MathUtils.calculateTiltDifference(180.0, 0.0), closeTo(180.0, 0.0001));
      });
    });
  });
}
