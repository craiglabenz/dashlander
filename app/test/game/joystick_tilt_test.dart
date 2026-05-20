import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

double calculateRelativeJoystickAngleDeg(double joystickAngleRad, double shipAngleRad) {
  double relativeAngle = joystickAngleRad - shipAngleRad;
  
  while (relativeAngle < -pi) {
    relativeAngle += 2 * pi;
  }
  while (relativeAngle > pi) {
    relativeAngle -= 2 * pi;
  }
  
  return relativeAngle * 180 / pi;
}

void main() {
  group('Joystick Angle Calculation factoring Ship Tilt', () {
    test('Zero ship tilt matches raw joystick angle', () {
      final joystickAngle = 30.0 * pi / 180.0;
      final shipAngle = 0.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(joystickAngle, shipAngle);
      expect(relativeAngleDeg, closeTo(30.0, 0.0001));
    });

    test('Ship tilted 45 degrees clockwise, joystick aligned with ship nose', () {
      final joystickAngle = 45.0 * pi / 180.0;
      final shipAngle = 45.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(joystickAngle, shipAngle);
      expect(relativeAngleDeg, closeTo(0.0, 0.0001));
    });

    test('Ship tilted 45 degrees clockwise, joystick pushed straight up (0 degrees)', () {
      final joystickAngle = 0.0;
      final shipAngle = 45.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(joystickAngle, shipAngle);
      expect(relativeAngleDeg, closeTo(-45.0, 0.0001));
    });

    test('Wrapping boundary test (ship 170 deg clockwise, joystick 170 deg counter-clockwise)', () {
      final joystickAngle = -170.0 * pi / 180.0;
      final shipAngle = 170.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(joystickAngle, shipAngle);
      expect(relativeAngleDeg, closeTo(20.0, 0.0001)); // -170 - 170 = -340 -> wraps to +20
    });
  });
}
