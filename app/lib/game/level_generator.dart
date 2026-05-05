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

    final double scaleFactor = chaos.nextDouble() * 2.0 - 1.0;

    final double rawRadius = moonRadius ?? PhysicsConstants.moonRadius;
    final double radius = applyVariance(
      rawRadius,
      PhysicsConstants.moonRadiusVariance,
      scaleFactor,
    );

    final int rawSegments = terrainSegments ?? PhysicsConstants.terrainSegments;
    final int segments =
        applyVariance(
          rawSegments.toDouble(),
          PhysicsConstants.terrainSegmentsVariance,
          scaleFactor,
        ).round();

    final double rawMaxHeight =
        maxTerrainHeight ?? PhysicsConstants.maxTerrainHeight;
    final double maxHeight = applyVariance(
      rawMaxHeight,
      PhysicsConstants.maxTerrainHeightVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    );

    final double rawFreq = noiseFrequency ?? PhysicsConstants.noiseFrequency;
    final double freq = applyVariance(
      rawFreq,
      PhysicsConstants.noiseFrequencyVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    );

    final int rawPadsCount = numLandingPads ?? PhysicsConstants.numLandingPads;
    final int padsCount = applyVariance(
      rawPadsCount.toDouble(),
      PhysicsConstants.numLandingPadsVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    ).round().clamp(1, segments);

    final int rawPadWidth =
        padWidthSegments ?? PhysicsConstants.padWidthSegments;
    final int padWidth = applyVariance(
      rawPadWidth.toDouble(),
      PhysicsConstants.padWidthSegmentsVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    ).round().clamp(1, segments ~/ 4);

    final double rawStartX = PhysicsConstants.initialVelocityX;
    double vX = applyVariance(
      rawStartX,
      PhysicsConstants.initialVelocityXVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    );
    if (chaos.nextBool()) vX = -vX;

    final double rawStartY = PhysicsConstants.initialVelocityY;
    final double vY = applyVariance(
      rawStartY,
      PhysicsConstants.initialVelocityYVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    );

    final Vector2 initialVelocity = Vector2(
      vX * PhysicsConstants.pixelsPerMeter,
      vY * PhysicsConstants.pixelsPerMeter,
    );

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

    // Helper to calculate the tilt of a potential pad
    double getPadTilt(int p) {
      double t1 = (p / segments) * 2 * pi;
      double h1 = radius + heights[p];
      double x1 = sin(t1) * h1;
      double y1 = -cos(t1) * h1;
      Vector2 pStart = Vector2(x1, y1);

      int p2Idx = (p + padWidth) % segments;
      double t2 = (p2Idx / segments) * 2 * pi;
      double h2 = radius + heights[p2Idx];
      double x2 = sin(t2) * h2;
      double y2 = -cos(t2) * h2;
      Vector2 pEnd = Vector2(x2, y2);

      Vector2 diff = pEnd - pStart;
      Vector2 normal = Vector2(-diff.y, diff.x).normalized();
      Vector2 mid = (pStart + pEnd) / 2;
      if (normal.dot(mid) < 0) normal = -normal;

      double absAngleDeg = MathUtils.calculateAbsoluteAngleDeg(normal);
      return MathUtils.calculateRelativeTiltDeg(
        position: mid,
        absoluteAngleDeg: absAngleDeg,
      ).abs();
    }

    // Choose pad indices
    List<int> padIndices = [];
    int padsToPlace = padsCount;

    // Randomize where we look for the first pad so it can be much further away
    // than just immediately in front of the player. Distance floor is 60° and max is 180°.
    int minSearchIdx = max(2, (segments * 60.0 / 360.0).floor());
    int maxSearchIdx = (segments / 2).floor(); // Up to 180 degrees away

    // Square the random number so it skews closer on average, but can still be far.
    double distanceFactor = pow(chaos.nextDouble(), 2).toDouble();
    int searchWindowStart =
        minSearchIdx + (distanceFactor * (maxSearchIdx - minSearchIdx)).floor();

    int startPadIndex = searchWindowStart;
    double bestStartTilt = double.infinity;
    // Scan a 10-segment window to find the flattest spot in this region
    for (int i = searchWindowStart; i <= searchWindowStart + 10; i++) {
      double tilt = getPadTilt(i);
      if (tilt < bestStartTilt) {
        bestStartTilt = tilt;
        startPadIndex = i;
      }
    }

    if (padsToPlace > 0) {
      padIndices.add(startPadIndex);
      padsToPlace--;
    }

    // Prevent infinite loop if too many pads requested
    int maxAttempts = padsCount * 50;
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

      // Check tilt. Gradually relax the requirement if we're struggling to find spots.
      if (valid) {
        double allowedTilt = 10.0;
        if (maxAttempts < padsCount * 25) allowedTilt = 15.0;
        if (maxAttempts < padsCount * 10) allowedTilt = 25.0;

        if (getPadTilt(idx) > allowedTilt) {
          valid = false;
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
    final double rawAltitude = PhysicsConstants.startAltitude;
    final double altitude = applyVariance(
      rawAltitude,
      PhysicsConstants.startAltitudeVariance,
      chaos.nextDouble() * 2.0 - 1.0,
    );

    double startR = radius + heights[0] + altitude;
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

    // Calculate Multiplier per pad
    Map<int, double> padMultipliers = {};
    for (int p in padIndices) {
      int dist = min(p, segments - p);
      double distDeg = (dist / segments) * 360.0;
      double multiplier = 0.5 + (distDeg / 180.0) * 1.5; // 0.5 to 2.0 based on distance
      
      for (int i = 0; i < padWidth; i++) {
        padMultipliers[(p + i) % segments] = multiplier;
      }
    }

    return LevelData(
      id: seed,
      name: name ?? "Sector $seed",
      initialFuel: initialFuel ?? PhysicsConstants.defaultMaxFuel,
      terrainPoints: terrainPoints,
      padIndices: expandedPadIndices,
      padAngles: padAngles,
      padAngleDeltas: padAngleDeltas,
      padMultipliers: padMultipliers,
      startPosition: startPosition,
      initialVelocity: initialVelocity,
      radius: radius,
      maxTerrainHeight: maxHeight,
    );
  }

  static double applyVariance(
    double base,
    double variance,
    double randomFactor,
  ) {
    return base * (1.0 + (variance * randomFactor));
  }
}
