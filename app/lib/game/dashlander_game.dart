import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'dart:ui' as ui;
import 'package:flame_audio/flame_audio.dart';
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

    try {
      FlameAudio.bgm.initialize();
      FlameAudio.audioCache.prefix = 'assets/audio/';
      await FlameAudio.bgm.play('background.mp3');
    } catch (e) {
      debugPrint("Failed to load or play background music: $e");
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
      velocity: Vector2(
        PhysicsConstants.initialVelocityX * PhysicsConstants.pixelsPerMeter,
        PhysicsConstants.initialVelocityY * PhysicsConstants.pixelsPerMeter,
      ), // Slight initial push
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
    ship = ShipComponent(
      state: landerState,
      behaviors: [
        PlayerInputBehavior(),
        PhysicsBehavior(physicsEngine: physicsEngine),
        ExhaustBehavior(
          hasFuel: () => landerState.fuelMass > 0 || physicsEngine.infiniteFuel,
        ),
        ShipAudioBehavior(
          hasFuel: () => landerState.fuelMass > 0 || physicsEngine.infiniteFuel,
        ),
        ShipCollisionBehavior(physicsEngine: physicsEngine),
        TelemetryBehavior(),
      ],
    );
    world.add(ship);

    // 5. Add Target Ghost Ship (if playing against leaderboard)
    if (gameController.targetGhostReplay != null) {
      final ghostState = LanderState(
        position: level.startPosition.clone(),
        velocity: Vector2(
          PhysicsConstants.initialVelocityX * PhysicsConstants.pixelsPerMeter,
          PhysicsConstants.initialVelocityY * PhysicsConstants.pixelsPerMeter,
        ),
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
        isGhost: true,
        tintColor: Colors.deepOrangeAccent,
        behaviors: [
          GhostInputBehavior(replay: gameController.targetGhostReplay!),
          PhysicsBehavior(physicsEngine: physicsEngine),
          ExhaustBehavior(
            hasFuel:
                () => ghostState.fuelMass > 0 || physicsEngine.infiniteFuel,
          ),
          ShipCollisionBehavior(physicsEngine: physicsEngine),
        ],
      );
      world.add(ghostShip);
    }

    // Set camera to follow ship
    camera.follow(ship);

    // Set initial state
    gameController.status.value = GameStatus.playing;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android ||
        (kIsWeb && size.x < 800)) {
      joystick = JoystickComponent(
        knob: CircleComponent(
          radius: 30,
          paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
        ),
        background: CircleComponent(
          radius: 80,
          paint: Paint()..color = Colors.white.withValues(alpha: 0.2),
        ),
        margin: const EdgeInsets.only(right: 40, bottom: 40),
      );
      camera.viewport.add(joystick!);
    }
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    if (joystick != null) {
      final jUp = joystick!.relativeDelta.y < -0.2;
      final jLeft = joystick!.relativeDelta.x < -0.2;
      final jRight = joystick!.relativeDelta.x > 0.2;

      if (jUp != _isJoystickUp ||
          jLeft != _isJoystickLeft ||
          jRight != _isJoystickRight) {
        _isJoystickUp = jUp;
        _isJoystickLeft = jLeft;
        _isJoystickRight = jRight;
        _updateCombinedInputState();
      }
    }

    _accumulator += dt;
    if (_accumulator > 0.1) _accumulator = 0.1; // clamp to prevent death spiral

    while (_accumulator >= _fixedDt) {
      _fixedUpdate(_fixedDt);
      _accumulator -= _fixedDt;
    }
  }

  void _updateCombinedInputState() {
    bool newUp = _isKeyboardUp || _isJoystickUp;
    bool newLeft = _isKeyboardLeft || _isJoystickLeft;
    bool newRight = _isKeyboardRight || _isJoystickRight;

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
        landerState.position.length - PhysicsConstants.moonRadius,
      );

      // Only start zooming out once the player reaches a threshold altitude
      const double zoomStartAltitude = 800.0;
      const double zoomEndAltitude = 3000.0; // Deep space boundary

      if (altitude <= zoomStartAltitude) {
        camera.viewfinder.zoom = 1.0;
      } else {
        double zoomProgress = ((altitude - zoomStartAltitude) /
                (zoomEndAltitude - zoomStartAltitude))
            .clamp(0.0, 1.0);

        // Cap the maximum zoom-out to 0.5x of the initial scope.
        // We still interpolate visible distance to maintain the smooth 1/x curve.
        double minVisibleDistance = size.y / 2; // Zoom 1.0
        double maxVisibleDistance = minVisibleDistance / 0.5; // Zoom 0.5

        double currentVisibleDistance =
            ui.lerpDouble(
              minVisibleDistance,
              maxVisibleDistance,
              zoomProgress,
            )!;
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
