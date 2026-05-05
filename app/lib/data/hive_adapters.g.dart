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
      x: fields[3] == null ? 0.0 : (fields[3] as num).toDouble(),
      y: fields[4] == null ? 0.0 : (fields[4] as num).toDouble(),
      vx: fields[5] == null ? 0.0 : (fields[5] as num).toDouble(),
      vy: fields[6] == null ? 0.0 : (fields[6] as num).toDouble(),
      angle: fields[7] == null ? 0.0 : (fields[7] as num).toDouble(),
      angularVelocity: fields[8] == null ? 0.0 : (fields[8] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, ThrusterAction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.thruster)
      ..writeByte(1)
      ..write(obj.isFiring)
      ..writeByte(2)
      ..write(obj.timestampMs)
      ..writeByte(3)
      ..write(obj.x)
      ..writeByte(4)
      ..write(obj.y)
      ..writeByte(5)
      ..write(obj.vx)
      ..writeByte(6)
      ..write(obj.vy)
      ..writeByte(7)
      ..write(obj.angle)
      ..writeByte(8)
      ..write(obj.angularVelocity);
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
