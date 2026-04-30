import 'package:freezed_annotation/freezed_annotation.dart';

part 'sandbox_config.freezed.dart';

@freezed
sealed class SandboxConfig with _$SandboxConfig {
  factory SandboxConfig({
    required double gravity,
    required double thrustPower,
    required bool infiniteFuel,
  }) = _SandboxConfig;
}
