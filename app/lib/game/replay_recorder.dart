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
    required double x,
    required double y,
    required double vx,
    required double vy,
    required double angle,
    required double angularVelocity,
    double timeOffset = 0.0,
  }) {
    int timestampMs = ((_elapsedTimeSeconds + timeOffset) * 1000).toInt();

    if (isUpPressed != _isMainFiring) {
      _isMainFiring = isUpPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.main,
        isFiring: isUpPressed,
        timestampMs: timestampMs,
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        angle: angle,
        angularVelocity: angularVelocity,
      ));
    }

    if (isLeftPressed != _isLeftFiring) {
      _isLeftFiring = isLeftPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.left,
        isFiring: isLeftPressed,
        timestampMs: timestampMs,
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        angle: angle,
        angularVelocity: angularVelocity,
      ));
    }

    if (isRightPressed != _isRightFiring) {
      _isRightFiring = isRightPressed;
      _actions.add(ThrusterAction(
        thruster: ThrusterType.right,
        isFiring: isRightPressed,
        timestampMs: timestampMs,
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        angle: angle,
        angularVelocity: angularVelocity,
      ));
    }
  }

  void recordCheckpoint({
    required double x,
    required double y,
    required double vx,
    required double vy,
    required double angle,
    required double angularVelocity,
  }) {
    // Record a "dummy" action just to store position
    int timestampMs = (_elapsedTimeSeconds * 1000).toInt();
    _actions.add(ThrusterAction(
      thruster: ThrusterType.main,
      isFiring: _isMainFiring, // Maintain current visual state
      timestampMs: timestampMs,
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      angle: angle,
      angularVelocity: angularVelocity,
    ));
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
