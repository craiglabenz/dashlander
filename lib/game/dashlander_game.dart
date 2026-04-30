import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'dart:ui' as ui;
import '../physics/lander_state.dart';
import '../physics/physics_engine.dart';
import 'components/particle_exhaust.dart';
import 'components/parallax_stars.dart';
import 'components/ship.dart';
import 'components/terrain.dart';
import 'game_state.dart';
import 'ai_controller.dart';

class DashlanderGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final GameController gameController;

  late PhysicsEngine physicsEngine;
  late LanderState landerState;

  late ShipComponent ship;
  late TerrainComponent terrain;

  final List<LanderState> ghostStates = [];
  final List<ShipComponent> ghostShips = [];
  final List<GhostAIController> ghostAIs = [];

  bool isLeftPressed = false;
  bool isRightPressed = false;
  bool isUpPressed = false;

  bool _gameOverTriggered = false;

  ui.FragmentProgram? _bloomProgram;
  ui.FragmentShader? _bloomShader;

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
      physicsEngine.gravityScale = gameController.sandboxConfig!.gravity / 0.04;
      physicsEngine.thrustScale =
          gameController.sandboxConfig!.thrustPower / 0.12;
      physicsEngine.infiniteFuel = gameController.sandboxConfig!.infiniteFuel;
    }

    final level = gameController.currentLevel!;
    landerState = LanderState(
      position: level.startPosition.clone(),
      velocity: Vector2(2, 0), // Slight initial push
      angle: 0,
      angularVelocity: 0,
      fuelMass: level.initialFuel,
      dryMass: 4280.0, // Apollo LM dry mass approx
      engineMaxThrust: 45040.0, // Apollo LM max thrust N
      specificImpulse: 311.0,
      baseInertia:
          50000.0, // Arbitrary 2D moment of inertia for responsive feel
    );

    // 3. Add Terrain
    terrain = TerrainComponent(
      points: level.terrainPoints,
      padIndices: level.padIndices,
    );
    add(terrain);

    // 4. Add Ship
    ship = ShipComponent(state: landerState);
    add(ship);

    // 5. Setup Ghost Ships
    for (int i = 0; i < gameController.ghostShipsCount; i++) {
      final seed = DateTime.now().millisecondsSinceEpoch + i;
      final ai = GhostAIController(seed: seed);
      ghostAIs.add(ai);

      // Offset ghost ships slightly so they don't perfectly overlap
      final offset = Vector2(
        (Random().nextDouble() - 0.5) * 40,
        (Random().nextDouble() - 0.5) * 20,
      );
      final ghostState = LanderState(
        position: level.startPosition.clone() + offset,
        velocity: Vector2(2, 0), // Slight initial push
        angle: 0,
        angularVelocity: 0,
        fuelMass: level.initialFuel,
        dryMass: 4280.0,
        engineMaxThrust: 45040.0,
        specificImpulse: 311.0,
        baseInertia: 50000.0,
      );
      final hue = Random().nextDouble() * 360.0;
      final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
      final ghostShip = ShipComponent(
        state: ghostState,
        isGhost: true,
        tintColor: color,
      );
      ghostStates.add(ghostState);
      ghostShips.add(ghostShip);
      add(ghostShip);
    }

    // Set camera to follow ship
    camera.follow(ship);

    // Set initial state
    gameController.status.value = GameStatus.playing;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameController.status.value != GameStatus.playing) return;

    // Handle Input
    double steeringTorque = 0.0;
    if (isLeftPressed) steeringTorque -= 25000.0;
    if (isRightPressed) steeringTorque += 25000.0;

    landerState.isThrusting = isUpPressed;

    // Physics Step
    physicsEngine.update(landerState, dt, 1.0, steeringTorque);

    // Sync Ship Component
    ship.position = landerState.position;
    ship.angle = landerState.angle;
    ship.isThrusting =
        landerState.isThrusting &&
        (landerState.fuelMass > 0 || physicsEngine.infiniteFuel);

    // Exhaust Particles (Main Thruster)
    if (ship.isThrusting) {
      final mainExhaustOffset = Vector2(0, 12)..rotate(ship.angle);
      for (int i = 0; i < 3; i++) {
        add(
          ParticleExhaust(
            position: ship.position + mainExhaustOffset,
            emissionAngle: ship.angle + pi,
            shipVelocity: landerState.velocity,
            startRadius: 4.0,
          )..priority = 10,
        );
      }
    }

    // RCS Particles (Rotation)
    bool hasFuel = landerState.fuelMass > 0 || physicsEngine.infiniteFuel;
    if (isLeftPressed && hasFuel) {
      // Rotating left (CCW): Fire left RCS outward to the left
      final rcsOffset = Vector2(-10, 8)..rotate(ship.angle);
      add(
        ParticleExhaust(
          position: ship.position + rcsOffset,
          emissionAngle: ship.angle - pi / 2,
          shipVelocity: landerState.velocity,
          color: Colors.white,
          startRadius: 2.0,
        )..priority = 10,
      );
    }
    if (isRightPressed && hasFuel) {
      // Rotating right (CW): Fire right RCS outward to the right
      final rcsOffset = Vector2(10, 8)..rotate(ship.angle);
      add(
        ParticleExhaust(
          position: ship.position + rcsOffset,
          emissionAngle: ship.angle + pi / 2,
          shipVelocity: landerState.velocity,
          color: Colors.white,
          startRadius: 2.0,
        )..priority = 10,
      );
    }

    // Ghost Ships Update
    for (int i = 0; i < ghostStates.length; i++) {
      final ghostState = ghostStates[i];
      final ghostShip = ghostShips[i];
      final ghostAI = ghostAIs[i];

      if (!ghostState.isCrashed && !ghostState.isLanded) {
        double ghostTorque = ghostAI.update(
          ghostState,
          dt,
          gameController.currentLevel!,
        );
        physicsEngine.update(ghostState, dt, 1.0, ghostTorque);

        ghostShip.position = ghostState.position;
        ghostShip.angle = ghostState.angle;
        ghostShip.isThrusting =
            ghostState.isThrusting &&
            (ghostState.fuelMass > 0 || physicsEngine.infiniteFuel);

        if (ghostShip.isThrusting) {
          final mainExhaustOffset = Vector2(0, 12)..rotate(ghostShip.angle);
          for (int j = 0; j < 3; j++) {
            add(
              ParticleExhaust(
                position: ghostShip.position + mainExhaustOffset,
                emissionAngle: ghostShip.angle + pi,
                shipVelocity: ghostState.velocity,
                startRadius: 4.0,
              )..priority = 9,
            );
          }
        }
        bool ghostHasFuel =
            ghostState.fuelMass > 0 || physicsEngine.infiniteFuel;
        if (ghostTorque < 0 && ghostHasFuel) {
          // Negative torque (CCW) -> Fire left RCS leftward
          final rcsOffset = Vector2(-10, 8)..rotate(ghostShip.angle);
          add(
            ParticleExhaust(
              position: ghostShip.position + rcsOffset,
              emissionAngle: ghostShip.angle - pi / 2, // Exhaust points left
              shipVelocity: ghostState.velocity,
              color: Colors.white,
              startRadius: 2.0,
            )..priority = 9,
          );
        } else if (ghostTorque > 0 && ghostHasFuel) {
          // Positive torque (CW) -> Fire right RCS rightward
          final rcsOffset = Vector2(10, 8)..rotate(ghostShip.angle);
          add(
            ParticleExhaust(
              position: ghostShip.position + rcsOffset,
              emissionAngle: ghostShip.angle + pi / 2, // Exhaust points right
              shipVelocity: ghostState.velocity,
              color: Colors.white,
              startRadius: 2.0,
            )..priority = 9,
          );
        }
      }
    }

    // Collision Detection (Raycast against terrain segments)
    _checkCollisions();

    // Update Telemetry UI
    gameController.updateTelemetry(landerState);
  }

  void _checkCollisions() {
    final shipRadius = 14.0;
    bool crashed = false;
    bool landed = false;

    for (int i = 0; i < terrain.points.length - 1; i++) {
      final p1 = terrain.points[i];
      final p2 = terrain.points[i + 1];

      double dist = _pointLineDistance(landerState.position, p1, p2);

      if (dist < shipRadius) {
        // Collision!
        if (terrain.padIndices.contains(i)) {
          // It's a landing pad, check landing parameters
          physicsEngine.validateLanding(landerState);
          if (landerState.isLanded) {
            landed = true;
          } else {
            crashed = true;
          }
        } else {
          crashed = true;
        }
      }
    }

    // Out of bounds check
    final minX = terrain.points.first.x;
    final maxX = terrain.points.last.x;
    if (landerState.position.x < minX ||
        landerState.position.x > maxX ||
        landerState.position.y < -2000) {
      crashed = true;
    }

    if (crashed || landed) {
      if (!_gameOverTriggered) {
        _gameOverTriggered = true;
        if (crashed) {
          landerState.isCrashed = true; // Ensure physics stops
          _createExplosion(landerState.position);
          ship.isVisible = false; // Hide player ship safely
        } else {
          landerState.isLanded = true;
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (isMounted) {
            gameController.setGameOver(
              landed ? GameStatus.won : GameStatus.lost,
              landerState,
            );
          }
        });
      }
    }

    // Check Ghost Collisions
    for (int g = 0; g < ghostStates.length; g++) {
      final ghostState = ghostStates[g];
      final ghostShip = ghostShips[g];

      if (ghostState.isCrashed || ghostState.isLanded) continue;

      bool ghostCrashed = false;
      bool ghostLanded = false;

      for (int i = 0; i < terrain.points.length - 1; i++) {
        final p1 = terrain.points[i];
        final p2 = terrain.points[i + 1];

        double dist = _pointLineDistance(ghostState.position, p1, p2);

        if (dist < shipRadius) {
          if (terrain.padIndices.contains(i)) {
            physicsEngine.validateLanding(ghostState);
            if (ghostState.isLanded) {
              ghostLanded = true;
            } else {
              ghostCrashed = true;
            }
          } else {
            ghostCrashed = true;
          }
        }
      }

      if (ghostState.position.x < minX ||
          ghostState.position.x > maxX ||
          ghostState.position.y < -2000) {
        ghostCrashed = true;
      }

      if (ghostCrashed || ghostLanded) {
        if (ghostCrashed) {
          ghostState.isCrashed = true;
          _createExplosion(ghostState.position);
          ghostShip.isVisible = false;
        } else if (ghostLanded) {
          ghostState.isLanded = true;
        }
      }
    }
  }

  double _pointLineDistance(Vector2 p, Vector2 a, Vector2 b) {
    final ab = b - a;
    final ap = p - a;
    double t = ap.dot(ab) / ab.length2;
    t = t.clamp(0.0, 1.0);
    final nearest = a + ab * t;
    return (p - nearest).length;
  }

  void _createExplosion(Vector2 pos) {
    // Generate many particles
    for (int i = 0; i < 50; i++) {
      add(ParticleExhaust.explosion(position: pos));
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    isLeftPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    isRightPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    isUpPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.space);
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
