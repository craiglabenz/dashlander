import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../components/ship.dart';
import '../dashlander_game.dart';
import '../models/game_status.dart';
import '../../clean_audio_stub.dart' if (dart.library.html) '../../clean_audio_web.dart';

/// Safari-optimized audio behavior for the lander ship.
///
/// To bypass Safari's strict autoplay contexts and the high 1-2s latency when
/// starting/pausing HTML5 Audio players, this behavior starts continuous looping
/// audio players in the background at 0.0 volume once game interaction begins.
/// During active thrusting, it modulates the volume dynamically rather than
/// calling pause() or resume(), guaranteeing instant (1-frame) audio feedback.
class ShipAudioBehavior extends Behavior<ShipComponent> {
  final bool Function() hasFuel;
  final bool Function() isMuted;

  static AudioPlayer? _preInitializedMainEnginePlayer;
  static AudioPlayer? _preInitializedRcsEnginePlayer;

  /// Warm up the static engine looping players within a synchronous user-gesture callback.
  /// This is required to satisfy iOS/Safari's strict autoplay restrictions and avoid high latency.
  static void warmUp() {
    if (isSafariBrowser()) return;
    if (kIsWeb) {
      if (_preInitializedMainEnginePlayer == null) {
        FlameAudio.loopLongAudio('engine-main-long.mp3', volume: 0.0).then((player) {
          _preInitializedMainEnginePlayer = player;
        }).catchError((e) {
          debugPrint('Error warming up main engine loop: $e');
        });
      }
      if (_preInitializedRcsEnginePlayer == null) {
        FlameAudio.loopLongAudio('engine-rcs-long.mp3', volume: 0.0).then((player) {
          _preInitializedRcsEnginePlayer = player;
        }).catchError((e) {
          debugPrint('Error warming up RCS engine loop: $e');
        });
      }
    }
  }

  AudioPlayer? _mainEnginePlayer;
  AudioPlayer? _rcsEnginePlayer;
  
  bool _isLoadingMain = false;
  bool _isLoadingRcs = false;

  double _currentMainVolume = 0.0;
  double _currentRcsVolume = 0.0;
  bool _isPausedExternally = false;

  ShipAudioBehavior({required this.hasFuel, required this.isMuted});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isSafariBrowser()) return;
    if (_preInitializedMainEnginePlayer != null) {
      _mainEnginePlayer = _preInitializedMainEnginePlayer;
      _mainEnginePlayer?.setVolume(0.0);
    }
    if (_preInitializedRcsEnginePlayer != null) {
      _rcsEnginePlayer = _preInitializedRcsEnginePlayer;
      _rcsEnginePlayer?.setVolume(0.0);
    }
  }

  void _initMainPlayer() {
    if (_mainEnginePlayer != null || _isLoadingMain) return;
    
    if (_preInitializedMainEnginePlayer != null) {
      _mainEnginePlayer = _preInitializedMainEnginePlayer;
      _currentMainVolume = 0.0;
      _mainEnginePlayer?.setVolume(0.0);
      return;
    }
    
    _isLoadingMain = true;
    FlameAudio.loopLongAudio('engine-main-long.mp3', volume: 0.0).then((player) {
      _mainEnginePlayer = player;
      _isLoadingMain = false;
      
      // Sync immediately to the current engine state
      final game = parent.findParent<DashlanderGame>();
      final bool isPlaying = game?.gameController.status.value == GameStatus.playing;
      final bool wantMain = isPlaying && parent.state.isThrusting && hasFuel() && !parent.state.isCrashed && !parent.state.isLanded;
      final bool shouldPlayMain = wantMain && !isMuted() && !_isPausedExternally;
      
      _currentMainVolume = shouldPlayMain ? 1.0 : 0.0;
      player.setVolume(_currentMainVolume);
    }).catchError((e) {
      debugPrint('Error starting main engine loop: $e');
      _isLoadingMain = false;
    });
  }

  void _initRcsPlayer() {
    if (_rcsEnginePlayer != null || _isLoadingRcs) return;
    
    if (_preInitializedRcsEnginePlayer != null) {
      _rcsEnginePlayer = _preInitializedRcsEnginePlayer;
      _currentRcsVolume = 0.0;
      _rcsEnginePlayer?.setVolume(0.0);
      return;
    }
    
    _isLoadingRcs = true;
    FlameAudio.loopLongAudio('engine-rcs-long.mp3', volume: 0.0).then((player) {
      _rcsEnginePlayer = player;
      _isLoadingRcs = false;
      
      // Sync immediately to the current RCS state
      final game = parent.findParent<DashlanderGame>();
      final bool isPlaying = game?.gameController.status.value == GameStatus.playing;
      final bool wantRcs = isPlaying && parent.state.steeringTorque != 0 && hasFuel() && !parent.state.isCrashed && !parent.state.isLanded;
      final bool shouldPlayRcs = wantRcs && !isMuted() && !_isPausedExternally;
      
      _currentRcsVolume = shouldPlayRcs ? 0.5 : 0.0;
      player.setVolume(_currentRcsVolume);
    }).catchError((e) {
      debugPrint('Error starting RCS engine loop: $e');
      _isLoadingRcs = false;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSafariBrowser()) return;
    if (parent.isGhost) return;

    final game = parent.findParent<DashlanderGame>();
    final bool isPlaying = game?.gameController.status.value == GameStatus.playing;

    final state = parent.state;
    final bool wantMain = isPlaying && state.isThrusting && hasFuel() && !state.isCrashed && !state.isLanded;
    final bool wantRcs = isPlaying && state.steeringTorque != 0 && hasFuel() && !state.isCrashed && !state.isLanded;

    final bool mainMuted = isMuted() || _isPausedExternally;
    final bool shouldPlayMain = wantMain && !mainMuted;
    final bool shouldPlayRcs = wantRcs && !mainMuted;

    // Load players lazily on first user interaction requiring them
    if (shouldPlayMain && _mainEnginePlayer == null) {
      _initMainPlayer();
    }
    if (shouldPlayRcs && _rcsEnginePlayer == null) {
      _initRcsPlayer();
    }

    // Direct continuous volume tracking (no high-frequency platform channel setup, only edge volume writes)
    if (_mainEnginePlayer != null) {
      final double targetVol = shouldPlayMain ? 1.0 : 0.0;
      if (_currentMainVolume != targetVol) {
        _currentMainVolume = targetVol;
        _mainEnginePlayer?.setVolume(targetVol);
      }
    }

    if (_rcsEnginePlayer != null) {
      final double targetVol = shouldPlayRcs ? 0.5 : 0.0;
      if (_currentRcsVolume != targetVol) {
        _currentRcsVolume = targetVol;
        _rcsEnginePlayer?.setVolume(targetVol);
      }
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
    // If these are the persistent pre-initialized static players, do not dispose them.
    // Simply mute them to ensure silence when leaving the game screen.
    _mainEnginePlayer?.setVolume(0.0);
    _rcsEnginePlayer?.setVolume(0.0);
    
    if (_mainEnginePlayer != null && _mainEnginePlayer != _preInitializedMainEnginePlayer) {
      try {
        _mainEnginePlayer?.stop();
        _mainEnginePlayer?.dispose();
      } catch (e) {
        debugPrint('Error disposing main engine player: $e');
      }
    }
    _mainEnginePlayer = null;

    if (_rcsEnginePlayer != null && _rcsEnginePlayer != _preInitializedRcsEnginePlayer) {
      try {
        _rcsEnginePlayer?.stop();
        _rcsEnginePlayer?.dispose();
      } catch (e) {
        debugPrint('Error disposing RCS engine player: $e');
      }
    }
    _rcsEnginePlayer = null;
    
    _isLoadingMain = false;
    _isLoadingRcs = false;
  }

  @override
  void onRemove() {
    stopAndDispose();
    super.onRemove();
  }
}
