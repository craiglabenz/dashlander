// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class GameReplayAdapter extends TypeAdapter<GameReplay> {
  @override
  final typeId = 0;

  @override
  GameReplay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameReplay(
      id: fields[0] == null ? '' : fields[0] as String,
      userId: fields[1] as String,
      score: (fields[2] as num).toInt(),
      levelSeed: (fields[3] as num).toInt(),
      actions: (fields[4] as List).cast<ThrusterAction>(),
      durationMs: (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, GameReplay obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.levelSeed)
      ..writeByte(4)
      ..write(obj.actions)
      ..writeByte(5)
      ..write(obj.durationMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameReplayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThrusterActionAdapter extends TypeAdapter<ThrusterAction> {
  @override
  final typeId = 1;

  @override
  ThrusterAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThrusterAction(
      thruster: fields[0] as ThrusterType,
      isFiring: fields[1] as bool,
      timestampMs: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ThrusterAction obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.thruster)
      ..writeByte(1)
      ..write(obj.isFiring)
      ..writeByte(2)
      ..write(obj.timestampMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThrusterActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThrusterTypeAdapter extends TypeAdapter<ThrusterType> {
  @override
  final typeId = 2;

  @override
  ThrusterType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThrusterType.main;
      case 1:
        return ThrusterType.left;
      case 2:
        return ThrusterType.right;
      default:
        return ThrusterType.main;
    }
  }

  @override
  void write(BinaryWriter writer, ThrusterType obj) {
    switch (obj) {
      case ThrusterType.main:
        writer.writeByte(0);
      case ThrusterType.left:
        writer.writeByte(1);
      case ThrusterType.right:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThrusterTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
