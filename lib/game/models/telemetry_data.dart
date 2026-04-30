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
    required double gForce,
  }) = _TelemetryData;

  factory TelemetryData.empty() => TelemetryData(
    fuel: 0,
    maxFuel: PhysicsConstants.defaultMaxFuel,
    vY: 0,
    vX: 0,
    gForce: 0,
  );
}

