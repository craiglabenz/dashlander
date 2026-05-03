import 'package:shared/shared.dart';

class ReplayRecorder {
  final String userId;
  final int levelSeed;
  
  double _elapsedTimeSeconds = 0.0;
  final List<ThrusterAction> _actions = [];

  bool _isMainFiring = false;
  bool _isLeftFiring = false;
  bool _isRightFiring = false;

  ReplayRecorder({
    required this.userId,
    required this.levelSeed,
  });

  void updateTime(double dt) {
    _elapsedTimeSeconds += dt;
  }

  void recordInputState({
    required bool isUpPressed,
    required bool isLeftPressed,
    required bool isRightPressed,
  }) {
    int timestampMs = (_elapsedTimeSeconds * 1000).toInt();

    if (isUpPressed != _isMainFiring) {
      _isMainFiring = isUpPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.main,
        isFiring: isUpPressed,
        timestampMs: timestampMs,
      ));
    }

    if (isLeftPressed != _isLeftFiring) {
      _isLeftFiring = isLeftPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.left,
        isFiring: isLeftPressed,
        timestampMs: timestampMs,
      ));
    }

    if (isRightPressed != _isRightFiring) {
      _isRightFiring = isRightPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.right,
        isFiring: isRightPressed,
        timestampMs: timestampMs,
      ));
    }
  }

  GameReplay finalizeReplay({required int score}) {
    return GameReplay(
      userId: userId,
      score: score,
      levelSeed: levelSeed,
      actions: List.unmodifiable(_actions),
      durationMs: (_elapsedTimeSeconds * 1000).toInt(),
    );
  }
}
