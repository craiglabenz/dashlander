import 'package:freezed_annotation/freezed_annotation.dart';
import '../../physics/constants.dart';

part 'telemetry_data.freezed.dart';

@freezed
sealed class TelemetryData with _$TelemetryData {
  const TelemetryData._();
  factory TelemetryData({
    required double fuel,
    required double maxFuel,
    required double vY, // Vertical velocity
    required double vX, // Horizontal velocity
    required double tilt, // Replaces gForce
    required double x,
    required double y,
    required int terrainIndexBelow,
    required bool debugModeEnabled,
    required double height,
  }) = _TelemetryData;

  factory TelemetryData.empty() => TelemetryData(
    fuel: 0,
    maxFuel: PhysicsConstants.defaultMaxFuel,
    vY: 0,
    vX: 0,
    tilt: 0,
    x: 0,
    y: PhysicsConstants.moonRadius,
    terrainIndexBelow: 0,
    debugModeEnabled: false,
    height: 0.0,
  );
}
