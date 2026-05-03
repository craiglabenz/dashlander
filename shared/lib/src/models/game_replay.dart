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
    @Default(0.0) double x,
    @Default(0.0) double y,
    @Default(0.0) double vx,
    @Default(0.0) double vy,
    @Default(0.0) double angle,
    @Default(0.0) double angularVelocity,
  }) = _ThrusterAction;

  factory ThrusterAction.fromJson(Map<String, dynamic> json) =>
      _$ThrusterActionFromJson(json);
}

@freezed
abstract class GameReplay with _$GameReplay {
  const factory GameReplay({
    @Default('') String id,
    required String userId,
    required int score,
    required int levelSeed,

    @ThrusterActionConverter() //
    required List<ThrusterAction> actions,
    required int durationMs,
  }) = _GameReplay;

  factory GameReplay.fromJson(Map<String, dynamic> json) =>
      _$GameReplayFromJson(json);
}

@JsonSerializable()
class ThrusterActionConverter
    implements JsonConverter<ThrusterAction, Map<String, dynamic>> {
  const ThrusterActionConverter();

  @override
  ThrusterAction fromJson(Map<String, dynamic> json) {
    return ThrusterAction.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ThrusterAction object) {
    return object.toJson();
  }
}
