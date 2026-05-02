import 'package:flutter_test/flutter_test.dart';
import 'package:dashlander/game/level_generator.dart';

void main() {
  group('LevelGenerator', () {
    test('produces the exact same dataset when given the same seed', () {
      final level1 = LevelGenerator.generate(seed: 42);
      final level2 = LevelGenerator.generate(seed: 42);

      expect(level1.id, equals(level2.id));
      expect(level1.name, equals(level2.name));
      expect(level1.initialFuel, equals(level2.initialFuel));
      expect(level1.startPosition.x, equals(level2.startPosition.x));
      expect(level1.startPosition.y, equals(level2.startPosition.y));
      
      expect(level1.terrainPoints.length, equals(level2.terrainPoints.length));
      for (int i = 0; i < level1.terrainPoints.length; i++) {
        expect(level1.terrainPoints[i].x, equals(level2.terrainPoints[i].x));
        expect(level1.terrainPoints[i].y, equals(level2.terrainPoints[i].y));
      }

      expect(level1.padIndices, equals(level2.padIndices));
    });

    test('produces a different dataset when given a different seed', () {
      final level1 = LevelGenerator.generate(seed: 42);
      final level2 = LevelGenerator.generate(seed: 99);

      // IDs should differ since they're based on seed
      expect(level1.id, isNot(equals(level2.id)));
      
      // Terrain points should be different due to different chaos noise
      bool hasDifferences = false;
      for (int i = 0; i < level1.terrainPoints.length; i++) {
        if (level1.terrainPoints[i].x != level2.terrainPoints[i].x ||
            level1.terrainPoints[i].y != level2.terrainPoints[i].y) {
          hasDifferences = true;
          break;
        }
      }
      
      expect(hasDifferences, isTrue, reason: 'Different seeds should produce different terrain geometry');
    });
  });
}
