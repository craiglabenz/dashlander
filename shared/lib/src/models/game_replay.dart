import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_replay.freezed.dart';
part 'game_replay.g.dart';

enum ThrusterType { main, left, right }

@freezed
abstract class ThrusterAction with _$ThrusterAction {
  const factory ThrusterAction({
    required ThrusterType thruster,
    required bool isFiring,
    required int timestampMs,
  }) = _ThrusterAction;

  factory ThrusterAction.fromJson(Map<String, dynamic> json) =>
      _$ThrusterActionFromJson(json);
}

@freezed
abstract class GameReplay with _$GameReplay {
  const factory GameReplay({
    required String userId,
    required int score,
    required int levelSeed,
    required List<ThrusterAction> actions,
    required int durationMs,
  }) = _GameReplay;

  factory GameReplay.fromJson(Map<String, dynamic> json) =>
      _$GameReplayFromJson(json);
}
