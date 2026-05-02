import 'dart:math';
import 'package:flame/components.dart';
import 'package:chaos/chaos.dart';
import '../physics/constants.dart';
import '../physics/math_utils.dart';
import 'models/level_data.dart';

class LevelGenerator {
  static LevelData generate({
    required int seed,
    String? name,
    double? moonRadius,
    int? terrainSegments,
    double? maxTerrainHeight,
    double? noiseFrequency,
    int? numLandingPads,
    int? padWidthSegments,
    double? initialFuel,
  }) {
    final chaos = Xoshiro128PP(seed);

    final double radius = moonRadius ?? PhysicsConstants.moonRadius;
    final int segments = terrainSegments ?? PhysicsConstants.terrainSegments;
    final double maxHeight =
        maxTerrainHeight ?? PhysicsConstants.maxTerrainHeight;
    final double freq = noiseFrequency ?? PhysicsConstants.noiseFrequency;
    final int padsCount = numLandingPads ?? PhysicsConstants.numLandingPads;
    final int padWidth = padWidthSegments ?? PhysicsConstants.padWidthSegments;

    // Generate heights using a mixture of base sine waves (for large hills)
    // and chaotic noise (for small craters and jagged edges).
    List<double> heights = List.filled(segments, 0.0);
    for (int i = 0; i < segments; i++) {
      double t = (i / segments) * 2 * pi;
      // Base variation using sine waves for smooth hills
      double h =
          sin(t * freq) * maxHeight * 0.5 +
          cos(t * freq * 2.3) * maxHeight * 0.25;
      // Add chaos noise
      h += chaos.nextDouble() * maxHeight * 0.25;
      heights[i] = h;
    }

    // Choose pad indices
    List<int> padIndices = [];
    int padsToPlace = padsCount;

    // Ensure one pad is near the start (index 0)
    int startPadIndex = 5; // near the start
    if (padsToPlace > 0) {
      padIndices.add(startPadIndex);
      padsToPlace--;
    }

    // Prevent infinite loop if too many pads requested
    int maxAttempts = padsCount * 10;
    while (padsToPlace > 0 && maxAttempts > 0) {
      maxAttempts--;
      int idx = chaos.nextInt(segments - padWidth);
      // Ensure pads don't overlap and aren't too close
      bool valid = true;
      for (int p in padIndices) {
        if ((p - idx).abs() < padWidth * 3) {
          valid = false;
          break;
        }
      }
      if (valid) {
        padIndices.add(idx);
        padsToPlace--;
      }
    }

    // We will expand padIndices after generating points, so we can interpolate the secants.
    List<int> expandedPadIndices = [];
    for (int p in padIndices) {
      for (int i = 0; i < padWidth; i++) {
        expandedPadIndices.add((p + i) % segments);
      }
    }

    // Build actual points
    // Convert scalar heights to 2D Cartesian coordinates wrapped around the center (0,0)
    List<Vector2> terrainPoints = [];
    for (int i = 0; i < segments; i++) {
      double t = (i / segments) * 2 * pi;
      double totalHeight = radius + heights[i];

      // Calculate (x, y) for this segment.
      // - t is the angle in radians starting from the top (0) and going clockwise.
      // - In Flame, -Y is UP. So an angle of 0 means we want the point at the top of the moon: (0, -radius).
      // - X = sin(0) * r = 0
      // - Y = -cos(0) * r = -r
      double x = sin(t) * totalHeight;
      double y = -cos(t) * totalHeight;
      terrainPoints.add(Vector2(x, y));
    }

    // Flatten the pads by making them a perfect straight line (secant) between their start and end points
    for (int p in padIndices) {
      Vector2 pStart = terrainPoints[p];
      Vector2 pEnd = terrainPoints[(p + padWidth) % segments];

      // Interpolate the points between p and pEnd so they lie perfectly on the straight line
      for (int i = 1; i < padWidth; i++) {
        int idx = (p + i) % segments;
        double t = i / padWidth;
        // Linear interpolation in 2D Cartesian space
        terrainPoints[idx] = pStart + (pEnd - pStart) * t;
      }
    }

    // Close the circle by making the final point identical to the first.
    // This allows the polygon renderer and collision logic to loop seamlessly.
    terrainPoints.add(terrainPoints[0].clone());

    // Start position slightly above surface at theta=0
    // The ship always starts just above the very "top" of the moon (angle 0).
    double startR = radius + heights[0] + 300.0;
    Vector2 startPosition = Vector2(0, -startR);

    // Compute pad angles
    Map<int, double> padAngles = {};
    Map<int, double> padAngleDeltas = {};
    for (int idx in expandedPadIndices) {
      Vector2 p1 = terrainPoints[idx];
      Vector2 p2 = terrainPoints[(idx + 1) % segments];
      Vector2 diff = p2 - p1;

      // The normal vector is (-dy, dx). We want it to point outward.
      Vector2 normal = Vector2(-diff.y, diff.x).normalized();
      Vector2 mid = (p1 + p2) / 2;
      if (normal.dot(mid) < 0) {
        normal = -normal;
      }

      // Calculate absolute angle of the pad's normal
      double absoluteAngleDeg = MathUtils.calculateAbsoluteAngleDeg(normal);
      
      // Calculate delta. A delta of 0 means the pad is perfectly aligned with the moon's curvature.
      double deltaDeg = MathUtils.calculateRelativeTiltDeg(
        position: mid,
        absoluteAngleDeg: absoluteAngleDeg,
      );
      
      padAngles[idx] = absoluteAngleDeg;
      padAngleDeltas[idx] = deltaDeg;
    }

    return LevelData(
      id: seed,
      name: name ?? "Sector $seed",
      initialFuel: initialFuel ?? PhysicsConstants.defaultMaxFuel,
      terrainPoints: terrainPoints,
      padIndices: expandedPadIndices,
      padAngles: padAngles,
      padAngleDeltas: padAngleDeltas,
      startPosition: startPosition,
    );
  }
}
