import 'package:flame/components.dart';

class TerrainPoint {
  final double x;
  final double y;
  final bool isPad;

  const TerrainPoint(this.x, this.y, {this.isPad = false});
  
  Vector2 toVector2() => Vector2(x, y);
}

class LevelData {
  final int id;
  final String name;
  final double fuel;
  final List<TerrainPoint> terrain;
  final Vector2 startPos;

  const LevelData({
    required this.id,
    required this.name,
    required this.fuel,
    required this.terrain,
    required this.startPos,
  });
}

class SandboxConfig {
  final double gravity;
  final double thrustPower;
  final bool infiniteFuel;

  const SandboxConfig({
    this.gravity = 1.625, // Lunar gravity approx
    this.thrustPower = 15.0,
    this.infiniteFuel = true,
  });
}

class Telemetry {
  double fuel;
  double maxFuel;
  double vx;
  double vy;
  double gForce;
  double maxG;

  Telemetry({
    this.fuel = 0,
    this.maxFuel = 100,
    this.vx = 0,
    this.vy = 0,
    this.gForce = 0,
    this.maxG = 0,
  });
}

enum GameStatus { running, win, crashed }

class GameResult {
  final GameStatus status;
  final int score;
  final Telemetry telemetry;

  const GameResult({
    required this.status,
    required this.score,
    required this.telemetry,
  });
}

final List<LevelData> gameLevels = [
  LevelData(
    id: 1,
    name: "Sea of Tranquility",
    fuel: 1000,
    terrain: const [
      TerrainPoint(0, 600),
      TerrainPoint(200, 550),
      TerrainPoint(350, 650),
      TerrainPoint(450, 650, isPad: true),
      TerrainPoint(600, 650, isPad: true),
      TerrainPoint(800, 500),
      TerrainPoint(1000, 700),
      TerrainPoint(1200, 600),
      TerrainPoint(1500, 600),
    ],
    startPos: Vector2(100, 100),
  ),
  LevelData(
    id: 2,
    name: "Tycho Crater",
    fuel: 800,
    terrain: const [
      TerrainPoint(0, 400),
      TerrainPoint(150, 300),
      TerrainPoint(250, 500),
      TerrainPoint(400, 800),
      TerrainPoint(500, 800, isPad: true),
      TerrainPoint(600, 800, isPad: true),
      TerrainPoint(750, 450),
      TerrainPoint(900, 350),
      TerrainPoint(1100, 650),
      TerrainPoint(1500, 500),
    ],
    startPos: Vector2(100, 100),
  ),
  LevelData(
    id: 3,
    name: "Lunar Alps",
    fuel: 600,
    terrain: const [
      TerrainPoint(0, 700),
      TerrainPoint(200, 700),
      TerrainPoint(300, 400),
      TerrainPoint(450, 300),
      TerrainPoint(600, 600),
      TerrainPoint(700, 750),
      TerrainPoint(800, 750, isPad: true),
      TerrainPoint(880, 750, isPad: true),
      TerrainPoint(950, 500),
      TerrainPoint(1100, 200),
      TerrainPoint(1300, 400),
      TerrainPoint(1500, 800),
    ],
    startPos: Vector2(150, 100),
  ),
];
