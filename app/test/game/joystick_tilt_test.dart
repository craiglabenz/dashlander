import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

double calculateRelativeJoystickAngleDeg({
  required double joystickAngleRad,
  required double shipAngleRad,
  required double cameraAngleRad,
}) {
  double screenSpaceShipAngle = shipAngleRad - cameraAngleRad;
  double relativeAngle = joystickAngleRad - screenSpaceShipAngle;
  
  while (relativeAngle < -pi) {
    relativeAngle += 2 * pi;
  }
  while (relativeAngle > pi) {
    relativeAngle -= 2 * pi;
  }
  
  return relativeAngle * 180 / pi;
}

void main() {
  group('Joystick Angle Calculation factoring Ship Tilt and Camera Rotation', () {
    test('Zero ship tilt and zero camera angle matches raw joystick angle', () {
      final joystickAngle = 30.0 * pi / 180.0;
      final shipAngle = 0.0;
      final cameraAngle = 0.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(
        joystickAngleRad: joystickAngle,
        shipAngleRad: shipAngle,
        cameraAngleRad: cameraAngle,
      );
      expect(relativeAngleDeg, closeTo(30.0, 0.0001));
    });

    test('Ship tilted 45 deg, camera rotated 45 deg -> ship looks upright on screen', () {
      final joystickAngle = 0.0; // Pushed straight up
      final shipAngle = 45.0 * pi / 180.0;
      final cameraAngle = 45.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(
        joystickAngleRad: joystickAngle,
        shipAngleRad: shipAngle,
        cameraAngleRad: cameraAngle,
      );
      // Since the ship looks perfectly upright, pushing straight up should trigger the main thruster
      expect(relativeAngleDeg, closeTo(0.0, 0.0001));
    });

    test('Ship tilted 45 deg, camera rotated 15 deg -> ship looks tilted 30 deg', () {
      final joystickAngle = 30.0 * pi / 180.0; // Pushed 30 deg right (pointing in ship's nose direction)
      final shipAngle = 45.0 * pi / 180.0;
      final cameraAngle = 15.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(
        joystickAngleRad: joystickAngle,
        shipAngleRad: shipAngle,
        cameraAngleRad: cameraAngle,
      );
      expect(relativeAngleDeg, closeTo(0.0, 0.0001));
    });

    test('Wrapping boundary test with active camera rotation', () {
      final joystickAngle = -170.0 * pi / 180.0;
      final shipAngle = 170.0 * pi / 180.0;
      final cameraAngle = 10.0 * pi / 180.0;
      
      final relativeAngleDeg = calculateRelativeJoystickAngleDeg(
        joystickAngleRad: joystickAngle,
        shipAngleRad: shipAngle,
        cameraAngleRad: cameraAngle,
      );
      // screenSpaceShipAngle = 170 - 10 = 160.
      // -170 - 160 = -330 -> wraps to +30.
      expect(relativeAngleDeg, closeTo(30.0, 0.0001));
    });
  });
}
