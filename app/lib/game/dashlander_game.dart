import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'dart:ui' as ui;

import '../physics/constants.dart';
import '../physics/lander_state.dart';
import '../physics/physics_engine.dart';
import 'components/parallax_stars.dart';
import 'components/ship.dart';
import 'components/terrain.dart';
import 'game_state.dart';
import 'behaviors/physics_behavior.dart';
import 'behaviors/exhaust_behavior.dart';
import 'behaviors/ship_collision_behavior.dart';
import 'behaviors/player_input_behavior.dart';
import 'behaviors/telemetry_behavior.dart';
import 'behaviors/ghost_input_behavior.dart';
import 'behaviors/ship_audio_behavior.dart';
import 'replay_recorder.dart';

class DashlanderGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final GameController gameController;

  late PhysicsEngine physicsEngine;
  late LanderState landerState;

  late ShipComponent ship;
  late TerrainComponent terrain;
  late ReplayRecorder replayRecorder;

  bool isLeftPressed = false;
  bool isRightPressed = false;
  bool isUpPressed = false;

  bool _gameOverTriggered = false;

  ui.FragmentProgram? _bloomProgram;
  ui.FragmentShader? _bloomShader;

  JoystickComponent? joystick;

  bool _isKeyboardLeft = false;
  bool _isKeyboardRight = false;
  bool _isKeyboardUp = false;

  bool _isJoystickLeft = false;
  bool _isJoystickRight = false;
  bool _isJoystickUp = false;

  double _accumulator = 0.0;
  static const double _fixedDt = 1.0 / 60.0;

  DashlanderGame({required this.gameController});

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      _bloomProgram = await ui.FragmentProgram.fromAsset('shaders/bloom.frag');
    } catch (e) {
      debugPrint("Failed to load bloom shader: $e");
    }

    // 1. Add background
    add(ParallaxStars()..priority = -9);

    // 2. Setup Physics
    physicsEngine = PhysicsEngine();
    if (gameController.sandboxConfig != null) {
      physicsEngine.gravityScale =
          gameController.sandboxConfig!.gravity /
          PhysicsConstants.sandboxBaseGravity;
      physicsEngine.thrustScale =
          gameController.sandboxConfig!.thrustPower /
          PhysicsConstants.sandboxBaseThrust;
      physicsEngine.infiniteFuel = gameController.sandboxConfig!.infiniteFuel;
    }

    final level = gameController.currentLevel!;

    replayRecorder = ReplayRecorder(
      userId: 'local_user', // Placeholder
      levelSeed: level.id,
    );

    landerState = LanderState(
      position: level.startPosition.clone(),
      velocity: level.initialVelocity.clone(), // Slight initial push
      angle: 0,
      angularVelocity: 0,
      fuelMass: level.initialFuel,
      dryMass: PhysicsConstants.dryMass, // Apollo LM dry mass approx
      engineMaxThrust:
          PhysicsConstants.engineMaxThrust, // Apollo LM max thrust N
      specificImpulse: PhysicsConstants.specificImpulse,
      baseInertia:
          PhysicsConstants
              .baseInertia, // Arbitrary 2D moment of inertia for responsive feel
    );

    // 3. Add Terrain
    terrain = TerrainComponent(
      points: level.terrainPoints,
      padIndices: level.padIndices,
      padAngles: level.padAngles,
      padAngleDeltas: level.padAngleDeltas,
    );
    world.add(terrain);

    // 4. Add Ship
    if (!gameController.isWatching) {
      ship = ShipComponent(
        state: landerState,
        behaviors: [
          PlayerInputBehavior(),
          PhysicsBehavior(physicsEngine: physicsEngine),
          ExhaustBehavior(
            hasFuel:
                () => landerState.fuelMass > 0 || physicsEngine.infiniteFuel,
          ),
          ShipAudioBehavior(
            hasFuel:
                () => landerState.fuelMass > 0 || physicsEngine.infiniteFuel,
            isMuted: () => gameController.isMuted.value,
          ),
          ShipCollisionBehavior(physicsEngine: physicsEngine),
          TelemetryBehavior(),
        ],
      );
      world.add(ship);
    }

    // 5. Add Target Ghost Ship (if playing against leaderboard)
    if (gameController.targetGhostReplay != null) {
      final ghostState = LanderState(
        position: level.startPosition.clone(),
        velocity: level.initialVelocity.clone(),
        angle: 0,
        angularVelocity: 0,
        fuelMass: level.initialFuel,
        dryMass: PhysicsConstants.dryMass,
        engineMaxThrust: PhysicsConstants.engineMaxThrust,
        specificImpulse: PhysicsConstants.specificImpulse,
        baseInertia: PhysicsConstants.baseInertia,
      );

      final ghostShip = ShipComponent(
        state: ghostState,
        isGhost: !gameController.isWatching,
        tintColor: gameController.isWatching ? null : Colors.deepOrangeAccent,
        behaviors: [
          GhostInputBehavior(replay: gameController.targetGhostReplay!),
          PhysicsBehavior(physicsEngine: physicsEngine),
          ExhaustBehavior(
            hasFuel:
                () => ghostState.fuelMass > 0 || physicsEngine.infiniteFuel,
          ),
          ShipCollisionBehavior(physicsEngine: physicsEngine),
          if (gameController.isWatching) TelemetryBehavior(),
          if (gameController.isWatching)
            ShipAudioBehavior(
              hasFuel:
                  () => ghostState.fuelMass > 0 || physicsEngine.infiniteFuel,
              isMuted: () => gameController.isMuted.value,
            ),
        ],
      );
      world.add(ghostShip);

      if (gameController.isWatching) {
        ship = ghostShip;
        landerState = ghostState;
      }
    }

    // Set camera to follow ship
    camera.follow(ship);

    // Set initial state
    gameController.status.value = GameStatus.playing;

    if (!gameController.isWatching &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android ||
            (kIsWeb && size.x < 800))) {
      joystick = JoystickComponent(
        knob: CircleComponent(
          radius: 30,
          paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
        ),
        background: JoystickHUDBackground(
          radius: 80,
          paint: Paint()..color = Colors.white.withValues(alpha: 0.15),
          getShipAngle: () => landerState.angle,
        ),
        margin: const EdgeInsets.only(right: 40, bottom: 40),
      );
      camera.viewport.add(joystick!);
    }
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    _accumulator += dt;
    if (_accumulator > 0.1) _accumulator = 0.1; // clamp to prevent death spiral

    while (_accumulator >= _fixedDt) {
      _fixedUpdate(_fixedDt);
      _accumulator -= _fixedDt;
    }
  }

  void _updateCombinedInputState() {
    bool newUp = _isKeyboardUp || _isJoystickUp;
    bool rawLeft = _isKeyboardLeft || _isJoystickLeft;
    bool rawRight = _isKeyboardRight || _isJoystickRight;

    bool newLeft = gameController.invertControls.value ? rawRight : rawLeft;
    bool newRight = gameController.invertControls.value ? rawLeft : rawRight;

    if (newUp != isUpPressed ||
        newLeft != isLeftPressed ||
        newRight != isRightPressed) {
      isUpPressed = newUp;
      isLeftPressed = newLeft;
      isRightPressed = newRight;

      if (gameController.status.value == GameStatus.playing) {
        replayRecorder.recordInputState(
          isUpPressed: isUpPressed,
          isLeftPressed: isLeftPressed,
          isRightPressed: isRightPressed,
          x: landerState.position.x,
          y: landerState.position.y,
          vx: landerState.velocity.x,
          vy: landerState.velocity.y,
          angle: landerState.angle,
          angularVelocity: landerState.angularVelocity,
          timeOffset: _fixedDt,
        );
      }
    }
  }

  void _fixedUpdate(double dt) {
    if (joystick != null) {
      final delta = joystick!.relativeDelta;
      if (delta.length < 0.15) {
        if (_isJoystickUp || _isJoystickLeft || _isJoystickRight) {
          _isJoystickUp = false;
          _isJoystickLeft = false;
          _isJoystickRight = false;
          _updateCombinedInputState();
        }
      } else {
        // Calculate joystick angle in screen space:
        // 0 is straight UP, positive is clockwise (right), negative is counter-clockwise (left)
        final joystickAngle = atan2(delta.x, -delta.y);
        
        // Factor in the ship's tilt so that UP on the dial is aligned with the ship's nose:
        double relativeAngle = joystickAngle - landerState.angle;
        
        // Normalize the relative angle to the range [-pi, pi] to ensure continuous wrapping
        while (relativeAngle < -pi) {
          relativeAngle += 2 * pi;
        }
        while (relativeAngle > pi) {
          relativeAngle -= 2 * pi;
        }
        
        final angleDeg = relativeAngle * 180 / pi;

        if (angleDeg.abs() <= 30) {
          // Zone 1: Straight UP (+/- 30 deg) -> Main thruster only
          _isJoystickUp = true;
          _isJoystickLeft = false;
          _isJoystickRight = false;
        } else if (angleDeg > 30 && angleDeg <= 90) {
          // Zone 2: Up-Right (30 to 90 deg) -> Main thruster + Right RCS (turn clockwise)
          _isJoystickUp = true;
          _isJoystickLeft = false;
          _isJoystickRight = true;
        } else if (angleDeg < -30 && angleDeg >= -90) {
          // Zone 3: Up-Left (-90 to -30 deg) -> Main thruster + Left RCS (turn counter-clockwise)
          _isJoystickUp = true;
          _isJoystickLeft = true;
          _isJoystickRight = false;
        } else if (angleDeg > 90 && angleDeg <= 180) {
          // Zone 4: Bottom-Right (90 to 180 deg) -> Right RCS only
          _isJoystickUp = false;
          _isJoystickLeft = false;
          _isJoystickRight = true;
        } else if (angleDeg < -90 && angleDeg >= -180) {
          // Zone 5: Bottom-Left (-180 to -90 deg) -> Left RCS only
          _isJoystickUp = false;
          _isJoystickLeft = true;
          _isJoystickRight = false;
        }

        _updateCombinedInputState();
      }
    }

    super.update(dt);
    // Only update active game logic if we're not game over
    if (gameController.status.value == GameStatus.playing) {
      replayRecorder.updateTime(dt);
      gameController.updateTelemetry(
        landerState,
        debugModeEnabled: debugMode,
        terrainPoints: terrain.points,
      );
    }
    if (gameController.status.value == GameStatus.playing && isMounted) {
      // Dynamic Spherical Camera Rotation
      // To keep the surface of the moon always "beneath" the player on screen,
      // we must constantly rotate the camera viewfinder based on the ship's position.
      // We calculate the angle of the ship relative to the moon's center (0,0).
      // Since Flame's Y-axis points down, we use atan2(x, -y) to find the angle.
      // Setting the viewfinder angle to this value counter-rotates the entire game world,
      // creating the illusion of a flat surface directly below the ship at all times.
      camera.viewfinder.angle = atan2(
        landerState.position.x,
        -landerState.position.y,
      );

      // Dynamic Camera Zoom
      double altitude = max(
        0.0,
        landerState.position.length - gameController.currentLevel!.radius,
      );

      // The distance from the center of the screen to the bottom edge is size.y / 2.
      // If the ship's altitude exceeds this, the surface will be off-screen.
      // We start zooming out when the altitude reaches the ratio of the visible distance
      // to keep the surface comfortably visible at the bottom of the screen.
      double minVisibleDistance = size.y / 2; // Zoom 1.0
      double zoomStartAltitude =
          minVisibleDistance * PhysicsConstants.cameraZoomSurfaceRatio;

      if (altitude <= zoomStartAltitude) {
        camera.viewfinder.zoom = 1.0;
      } else {
        // To keep the surface at the constant ratio mark on the screen, the total visible distance
        // from the ship to the screen edge must be `altitude / ratio`.
        double targetVisibleDistance =
            altitude / PhysicsConstants.cameraZoomSurfaceRatio;

        // Cap the maximum visible distance so the ship doesn't become invisibly small.
        // The deep space boundary is tracked perfectly by the constant.
        double maxVisibleDistance = PhysicsConstants.maxCameraVisibleDistance;

        double currentVisibleDistance = min(
          targetVisibleDistance,
          maxVisibleDistance,
        );
        camera.viewfinder.zoom = minVisibleDistance / currentVisibleDistance;
      }
    }
  }

  void triggerGameOver(bool landed) {
    if (!_gameOverTriggered) {
      _gameOverTriggered = true;

      // Record a final checkpoint to ensure the ghost comes to rest correctly
      replayRecorder.recordCheckpoint(
        x: landerState.position.x,
        y: landerState.position.y,
        vx: landerState.velocity.x,
        vy: landerState.velocity.y,
        angle: landerState.angle,
        angularVelocity: landerState.angularVelocity,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (isMounted) {
          gameController.setGameOver(
            landed ? GameStatus.won : GameStatus.lost,
            landerState,
            replayRecorder: replayRecorder,
          );
        }
      });
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _isKeyboardLeft =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    _isKeyboardRight =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    _isKeyboardUp =
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.space);

    _updateCombinedInputState();

    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backquote) {
      debugMode = !debugMode;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyP) {
      paused = !paused;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void render(Canvas canvas) {
    if (_bloomProgram == null || size.x <= 0 || size.y <= 0) {
      super.render(canvas);
      return;
    }

    // Render game tree to picture
    final recorder = ui.PictureRecorder();
    final offscreenCanvas = Canvas(recorder);
    super.render(offscreenCanvas);
    final picture = recorder.endRecording();

    try {
      // Synchronously rasterize picture to image
      final image = picture.toImageSync(size.x.toInt(), size.y.toInt());

      _bloomShader ??= _bloomProgram!.fragmentShader();
      _bloomShader!.setFloat(0, size.x);
      _bloomShader!.setFloat(1, size.y);
      _bloomShader!.setImageSampler(0, image);

      final paint = Paint()..shader = _bloomShader;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

      image.dispose();
    } catch (e) {
      // Fallback if toImageSync fails (e.g. on unsupported platforms)
      canvas.drawPicture(picture);
    }
  }
}

class JoystickHUDBackground extends CircleComponent {
  final double Function() getShipAngle;

  JoystickHUDBackground({
    required super.radius,
    required super.paint,
    required this.getShipAngle,
  });

  @override
  void render(Canvas canvas) {
    // 1. Draw the transparent background circle first
    super.render(canvas);

    final center = Offset(radius, radius);
    final shipAngle = getShipAngle();

    // High-tech sci-fi theme paints
    final paintZoneDivider = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    final paintNose = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.8)
      ..strokeWidth = 2.5;

    // Sector boundary angles relative to the ship's nose:
    // Zone 1 (Main only): [-30, 30] deg -> boundaries at +/-30 deg
    // Zone 2/3 (Main + RCS): [30, 90] / [-90, -30] deg -> boundaries at +/-90 deg
    // Zone 4/5 (RCS only): [90, 180] / [-180, -90] deg -> boundary at 180 deg
    final boundaries = [
      shipAngle - 30 * pi / 180,
      shipAngle + 30 * pi / 180,
      shipAngle - 90 * pi / 180,
      shipAngle + 90 * pi / 180,
      shipAngle + 180 * pi / 180,
    ];

    void drawRay(double angle, Paint paint, {double lengthFactor = 1.0}) {
      final dx = sin(angle) * radius * lengthFactor;
      final dy = -cos(angle) * radius * lengthFactor;
      canvas.drawLine(center, center + Offset(dx, dy), paint);
    }

    // 2. Draw partition boundaries
    for (final angle in boundaries) {
      drawRay(angle, paintZoneDivider, lengthFactor: 0.95);
    }

    // 3. Draw ship's nose reference ray (center of the main thruster zone)
    drawRay(shipAngle, paintNose, lengthFactor: 1.0);

    // 4. Draw an inner concentric tech reticle ring
    final paintReticle = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.4, paintReticle);
  }
}
