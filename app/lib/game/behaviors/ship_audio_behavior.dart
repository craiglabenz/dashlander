import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_audio/flame_audio.dart';
import '../components/ship.dart';
import '../dashlander_game.dart';
import '../models/game_status.dart';
import '../../clean_audio_stub.dart' if (dart.library.html) '../../clean_audio_web.dart';

/// Safari-optimized audio behavior for the lander ship.
///
/// To bypass Safari's issues, we detect Safari and disable thruster audio entirely.
/// On Chrome and other platforms, we use high-performance, non-blocking looping players
/// with edge-triggered volume adjustments to prevent platform channel saturation.
class ShipAudioBehavior extends Behavior<ShipComponent> {
  final bool Function() hasFuel;
  final bool Function() isMuted;

  AudioPlayer? _mainEnginePlayer;
  AudioPlayer? _rcsEnginePlayer;

  double _currentMainVolume = 0.0;
  double _currentRcsVolume = 0.0;
  bool _isPausedExternally = false;

  ShipAudioBehavior({required this.hasFuel, required this.isMuted});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isSafariBrowser()) return;
    if (parent.isGhost) return;

    try {
      _mainEnginePlayer = await FlameAudio.loopLongAudio('engine-main-long.mp3', volume: 0.0);
      _rcsEnginePlayer = await FlameAudio.loopLongAudio('engine-rcs-long.mp3', volume: 0.0);
    } catch (_) {
      // Ignore audio loading errors gracefully on unsupported platforms
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSafariBrowser()) return;
    if (parent.isGhost) return;
    if (_mainEnginePlayer == null || _rcsEnginePlayer == null) return;

    final game = parent.findParent<DashlanderGame>();
    final bool isPlaying = game?.gameController.status.value == GameStatus.playing;

    final state = parent.state;
    final bool wantMain = isPlaying && state.isThrusting && hasFuel() && !state.isCrashed && !state.isLanded;
    final bool wantRcs = isPlaying && state.steeringTorque != 0 && hasFuel() && !state.isCrashed && !state.isLanded;

    final bool mainMuted = isMuted() || _isPausedExternally;
    final bool shouldPlayMain = wantMain && !mainMuted;
    final bool shouldPlayRcs = wantRcs && !mainMuted;

    // Direct continuous volume tracking (no high-frequency platform channel setup, only edge volume writes)
    final double targetMainVol = shouldPlayMain ? 1.0 : 0.0;
    if (_currentMainVolume != targetMainVol) {
      _currentMainVolume = targetMainVol;
      _mainEnginePlayer?.setVolume(targetMainVol);
    }

    final double targetRcsVol = shouldPlayRcs ? 0.5 : 0.0;
    if (_currentRcsVolume != targetRcsVol) {
      _currentRcsVolume = targetRcsVol;
      _rcsEnginePlayer?.setVolume(targetRcsVol);
    }
  }

  void pauseAudio() {
    _isPausedExternally = true;
    _mainEnginePlayer?.setVolume(0.0);
    _rcsEnginePlayer?.setVolume(0.0);
    _currentMainVolume = 0.0;
    _currentRcsVolume = 0.0;
  }

  void resumeAudio() {
    _isPausedExternally = false;
  }

  void stopAndDispose() {
    if (_mainEnginePlayer != null) {
      try {
        _mainEnginePlayer?.stop();
        _mainEnginePlayer?.dispose();
      } catch (_) {}
      _mainEnginePlayer = null;
    }
    if (_rcsEnginePlayer != null) {
      try {
        _rcsEnginePlayer?.stop();
        _rcsEnginePlayer?.dispose();
      } catch (_) {}
      _rcsEnginePlayer = null;
    }
  }

  @override
  void onRemove() {
    stopAndDispose();
    super.onRemove();
  }
}
