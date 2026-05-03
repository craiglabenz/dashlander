// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_replay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThrusterActionConverter _$ThrusterActionConverterFromJson(
  Map<String, dynamic> json,
) => ThrusterActionConverter();

Map<String, dynamic> _$ThrusterActionConverterToJson(
  ThrusterActionConverter instance,
) => <String, dynamic>{};

_ThrusterAction _$ThrusterActionFromJson(Map<String, dynamic> json) =>
    _ThrusterAction(
      thruster: $enumDecode(_$ThrusterTypeEnumMap, json['thruster']),
      isFiring: json['isFiring'] as bool,
      timestampMs: (json['timestampMs'] as num).toInt(),
    );

Map<String, dynamic> _$ThrusterActionToJson(_ThrusterAction instance) =>
    <String, dynamic>{
      'thruster': _$ThrusterTypeEnumMap[instance.thruster]!,
      'isFiring': instance.isFiring,
      'timestampMs': instance.timestampMs,
    };

const _$ThrusterTypeEnumMap = {
  ThrusterType.main: 'main',
  ThrusterType.left: 'left',
  ThrusterType.right: 'right',
};

_GameReplay _$GameReplayFromJson(Map<String, dynamic> json) => _GameReplay(
  id: json['id'] as String? ?? '',
  userId: json['userId'] as String,
  score: (json['score'] as num).toInt(),
  levelSeed: (json['levelSeed'] as num).toInt(),
  actions: (json['actions'] as List<dynamic>)
      .map(
        (e) =>
            const ThrusterActionConverter().fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  durationMs: (json['durationMs'] as num).toInt(),
);

Map<String, dynamic> _$GameReplayToJson(_GameReplay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'score': instance.score,
      'levelSeed': instance.levelSeed,
      'actions': instance.actions
          .map(const ThrusterActionConverter().toJson)
          .toList(),
      'durationMs': instance.durationMs,
    };
