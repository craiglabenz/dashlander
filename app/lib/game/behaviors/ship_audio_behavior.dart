import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../components/ship.dart';

class ShipAudioBehavior extends Behavior<ShipComponent> {
  final bool Function() hasFuel;
  AudioPlayer? _mainEnginePlayer;
  AudioPlayer? _rcsEnginePlayer;
  
  double _mainVolume = 0.0;
  double _rcsVolume = 0.0;
  
  static const double _fadeSpeed = 5.0; // Volume per second

  ShipAudioBehavior({required this.hasFuel});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (parent.isGhost) return;

    try {
      _mainEnginePlayer = await FlameAudio.loopLongAudio('engine-main-long.mp3', volume: 0.0);
      _rcsEnginePlayer = await FlameAudio.loopLongAudio('engine-rcs-long.mp3', volume: 0.0);
    } catch (e) {
      debugPrint('Error loading ship audio: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parent.isGhost) return;
    if (_mainEnginePlayer == null || _rcsEnginePlayer == null) return;

    final state = parent.state;
    final bool isThrusting = state.isThrusting && hasFuel() && !state.isCrashed && !state.isLanded;
    final bool isRcsActive = state.steeringTorque != 0 && hasFuel() && !state.isCrashed && !state.isLanded;

    // Main Engine Volume
    if (isThrusting) {
      _mainVolume += _fadeSpeed * dt;
    } else {
      _mainVolume -= _fadeSpeed * dt;
    }
    _mainVolume = _mainVolume.clamp(0.0, 1.0);

    // RCS Volume
    if (isRcsActive) {
      _rcsVolume += _fadeSpeed * dt;
    } else {
      _rcsVolume -= _fadeSpeed * dt;
    }
    _rcsVolume = _rcsVolume.clamp(0.0, 0.5);

    _mainEnginePlayer?.setVolume(_mainVolume);
    _rcsEnginePlayer?.setVolume(_rcsVolume);
  }

  @override
  void onRemove() {
    _mainEnginePlayer?.stop();
    _mainEnginePlayer?.dispose();
    _rcsEnginePlayer?.stop();
    _rcsEnginePlayer?.dispose();
    super.onRemove();
  }
}
