import 'package:flutter_test/flutter_test.dart';
import 'package:dashlander/game/game_controller.dart';

void main() {
  group('Control Inversion State', () {
    test('invertControls is false by default', () {
      final controller = GameController();
      expect(controller.invertControls.value, isFalse);
    });

    test('invertControls notifies listeners when value changes', () {
      final controller = GameController();
      bool listenerNotified = false;

      controller.invertControls.addListener(() {
        listenerNotified = true;
      });

      controller.invertControls.value = true;
      expect(controller.invertControls.value, isTrue);
      expect(listenerNotified, isTrue);
    });
  });
}
