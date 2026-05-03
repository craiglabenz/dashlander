import 'dart:math';
import 'package:flame/components.dart';

class MathUtils {
  /// Calculates the absolute angle (0 to 360 degrees) of a normal vector.
  /// Uses Flame's coordinate system (-Y is up).
  static double calculateAbsoluteAngleDeg(Vector2 normal) {
    double angle = atan2(normal.x, -normal.y);
    double angleDeg = (angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;
    return angleDeg;
  }

  /// Calculates the tilt of an object relative to the straight line down to the
  /// center of the moon at the object's given position.
  ///
  /// [position] The cartesian position of the object relative to the moon's center (0,0).
  /// [absoluteAngleDeg] The absolute world angle of the object.
  ///
  /// Returns a delta degree value between [-180, 180] where 0 means the object
  /// is perfectly aligned with the spherical gravity vector at that position.
  static double calculateRelativeTiltDeg({
    required Vector2 position,
    required double absoluteAngleDeg,
  }) {
    // 1. Find the spherical normal (straight line down to the center of the moon (0,0))
    Vector2 sphericalNormal = position.normalized();

    // 2. Calculate the absolute angle of the spherical normal
    double sphericalAngleDeg = calculateAbsoluteAngleDeg(sphericalNormal);

    // 3. Normalize the object's absolute angle
    double normAbsoluteAngleDeg = absoluteAngleDeg % 360;
    if (normAbsoluteAngleDeg < 0) normAbsoluteAngleDeg += 360;

    // 4. Calculate the delta
    double deltaDeg = normAbsoluteAngleDeg - sphericalAngleDeg;

    // 5. Normalize delta to [-180, 180]
    while (deltaDeg > 180) {
      deltaDeg -= 360;
    }
    while (deltaDeg <= -180) {
      deltaDeg += 360;
    }

    return deltaDeg;
  }

  /// Calculates the shortest angular distance (0 to 180 degrees) between two angles.
  static double calculateTiltDifference(double angle1, double angle2) {
    double diffDeg = (angle1 - angle2).abs();
    return min(diffDeg, 360 - diffDeg);
  }
}
