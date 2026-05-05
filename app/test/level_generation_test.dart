import 'package:flutter_test/flutter_test.dart';
import 'package:dashlander/game/level_generator.dart';
import 'package:dashlander/game/models/level_data.dart';
import 'test_levels_data.dart';

extension LevelDataToJson on LevelData {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initialFuel': initialFuel,
      'terrainPoints': terrainPoints.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'padIndices': padIndices,
      'padAngles': padAngles.map((k, v) => MapEntry(k.toString(), v)),
      'padAngleDeltas': padAngleDeltas.map((k, v) => MapEntry(k.toString(), v)),
      'startPosition': {'x': startPosition.x, 'y': startPosition.y},
      'initialVelocity': {'x': initialVelocity.x, 'y': initialVelocity.y},
      'radius': radius,
      'maxTerrainHeight': maxTerrainHeight,
      'difficultyMultiplier': difficultyMultiplier,
    };
  }
}

void main() {
  group('LevelGeneration determinism and pad tilt tests', () {
    test('Generated levels are perfectly deterministic', () {
      final seeds = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000];
      
      for (var seed in seeds) {
        final generatedLevel = LevelGenerator.generate(seed: seed);
        final generatedJson = generatedLevel.toJson();
        
        final expectedJson = testLevelsData[seed];
        expect(expectedJson, isNotNull);
        
        expect(generatedJson, equals(expectedJson));
      }
    });

    test('All landing pads on generated levels satisfy the tilt constraints', () {
      final seeds = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000];
      
      for (var seed in seeds) {
        final level = LevelGenerator.generate(seed: seed);
        
        for (var padIdx in level.padIndices) {
          final deltaDeg = level.padAngleDeltas[padIdx] ?? 0.0;
          final tilt = deltaDeg.abs();
          
          // Max fallback tilt is 25.0
          expect(tilt, lessThanOrEqualTo(25.01), reason: 'Pad at $padIdx on seed $seed is tilted $tilt degrees, which exceeds the max allowed 25.0');
        }
      }
    });
  });
}
