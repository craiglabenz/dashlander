import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flame/components.dart';

part 'level_data.freezed.dart';

@freezed
sealed class LevelData with _$LevelData {
  factory LevelData({
    required int id,
    required String name,
    required double initialFuel,
    required List<Vector2> terrainPoints,
    // Pairs of indices representing landing pads e.g. [3, 4] means segment
    // between terrainPoints[3] and [4] is a pad.
    required List<int> padIndices,
    required Map<int, double> padAngles,
    required Map<int, double> padAngleDeltas,
    required Vector2 startPosition,
    required Vector2 initialVelocity,
    required double radius,
    required double maxTerrainHeight,
    required double difficultyMultiplier,
  }) = _LevelData;
}
