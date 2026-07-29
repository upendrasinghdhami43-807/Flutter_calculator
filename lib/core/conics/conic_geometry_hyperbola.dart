import 'dart:math' as math;

import '../expression_engine/errors.dart';
import 'conic_geometry_base.dart';
import 'conic_result.dart';

/// Builds a fully computed [ConicResult] for a hyperbola or a rectangular
/// hyperbola (the special case `a == b`) from canonical parameters.
class ConicGeometryHyperbola {
  const ConicGeometryHyperbola();

  ConicResult hyperbola({
    required double centerLocalX,
    required double centerLocalY,
    required double a,
    required double b,
    required bool transverseAlongX,
    double rotation = 0,
    Point2D origin = const Point2D(0, 0),
    bool isRectangular = false,
  }) {
    if (a <= 0 || b <= 0) throw const MathDomainException('Hyperbola semi-axis lengths must be positive.');
    final c = math.sqrt(a * a + b * b);
    final eccentricity = c / a;
    final center = transformPoint(centerLocalX, centerLocalY, rotation, origin);

    final vertices = transverseAlongX
        ? [transformPoint(centerLocalX + a, centerLocalY, rotation, origin), transformPoint(centerLocalX - a, centerLocalY, rotation, origin)]
        : [transformPoint(centerLocalX, centerLocalY + a, rotation, origin), transformPoint(centerLocalX, centerLocalY - a, rotation, origin)];
    final foci = transverseAlongX
        ? [transformPoint(centerLocalX + c, centerLocalY, rotation, origin), transformPoint(centerLocalX - c, centerLocalY, rotation, origin)]
        : [transformPoint(centerLocalX, centerLocalY + c, rotation, origin), transformPoint(centerLocalX, centerLocalY - c, rotation, origin)];

    final directrixOffset = a * a / c;
    final directrixSegments = transverseAlongX
        ? [
            lineSegmentThrough(centerLocalX + directrixOffset, centerLocalY, 0, 1, b * 1.6, rotation, origin),
            lineSegmentThrough(centerLocalX - directrixOffset, centerLocalY, 0, 1, b * 1.6, rotation, origin),
          ]
        : [
            lineSegmentThrough(centerLocalX, centerLocalY + directrixOffset, 1, 0, b * 1.6, rotation, origin),
            lineSegmentThrough(centerLocalX, centerLocalY - directrixOffset, 1, 0, b * 1.6, rotation, origin),
          ];
    final directrixDescriptions = transverseAlongX
        ? ['x = ${formatCoefficient(centerLocalX + directrixOffset)}', 'x = ${formatCoefficient(centerLocalX - directrixOffset)}']
        : ['y = ${formatCoefficient(centerLocalY + directrixOffset)}', 'y = ${formatCoefficient(centerLocalY - directrixOffset)}'];

    final asymptoteSlope = transverseAlongX ? b / a : a / b;
    final asymptoteSegments = [
      lineSegmentThrough(centerLocalX, centerLocalY, 1, asymptoteSlope, math.max(a, b) * 3, rotation, origin),
      lineSegmentThrough(centerLocalX, centerLocalY, 1, -asymptoteSlope, math.max(a, b) * 3, rotation, origin),
    ];
    final axisLabel = rotation.abs() < 1e-9 ? 'x' : "x'";
    final axisLabelY = rotation.abs() < 1e-9 ? 'y' : "y'";
    final slopeText = formatCoefficient(asymptoteSlope);
    final asymptoteDescriptions = [
      '$axisLabelY − ${formatCoefficient(centerLocalY)} = $slopeText ($axisLabel − ${formatCoefficient(centerLocalX)})',
      '$axisLabelY − ${formatCoefficient(centerLocalY)} = -$slopeText ($axisLabel − ${formatCoefficient(centerLocalX)})',
    ];

    final latusRectumLength = 2 * b * b / a;
    final halfLatus = b * b / a;
    final latusEndpoints = transverseAlongX
        ? [
            transformPoint(centerLocalX + c, centerLocalY + halfLatus, rotation, origin),
            transformPoint(centerLocalX + c, centerLocalY - halfLatus, rotation, origin),
            transformPoint(centerLocalX - c, centerLocalY + halfLatus, rotation, origin),
            transformPoint(centerLocalX - c, centerLocalY - halfLatus, rotation, origin),
          ]
        : [
            transformPoint(centerLocalX + halfLatus, centerLocalY + c, rotation, origin),
            transformPoint(centerLocalX - halfLatus, centerLocalY + c, rotation, origin),
            transformPoint(centerLocalX + halfLatus, centerLocalY - c, rotation, origin),
            transformPoint(centerLocalX - halfLatus, centerLocalY - c, rotation, origin),
          ];

    const steps = 160;
    const tMax = 2.5;
    List<Point2D> branch(double sign) => List.generate(steps + 1, (i) {
      final t = -tMax + (2 * tMax * i / steps);
      final coshT = (math.exp(t) + math.exp(-t)) / 2;
      final sinhT = (math.exp(t) - math.exp(-t)) / 2;
      final localX = transverseAlongX ? centerLocalX + sign * a * coshT : centerLocalX + b * sinhT;
      final localY = transverseAlongX ? centerLocalY + b * sinhT : centerLocalY + sign * a * coshT;
      return transformPoint(localX, localY, rotation, origin);
    });

    final equation = transverseAlongX
        ? '($axisLabel − ${formatCoefficient(centerLocalX)})²/${formatCoefficient(a * a)} − ($axisLabelY − ${formatCoefficient(centerLocalY)})²/${formatCoefficient(b * b)} = 1'
        : '($axisLabelY − ${formatCoefficient(centerLocalY)})²/${formatCoefficient(a * a)} − ($axisLabel − ${formatCoefficient(centerLocalX)})²/${formatCoefficient(b * b)} = 1';

    return ConicResult(
      type: isRectangular ? ConicType.rectangularHyperbola : ConicType.hyperbola,
      standardFormEquation: equation,
      center: center,
      vertices: vertices,
      foci: foci,
      eccentricity: eccentricity,
      semiMajorAxis: a,
      semiMinorAxis: b,
      directrixDescriptions: directrixDescriptions,
      directrixSegments: directrixSegments,
      asymptoteDescriptions: asymptoteDescriptions,
      asymptoteSegments: asymptoteSegments,
      latusRectumLength: latusRectumLength,
      latusRectumEndpoints: latusEndpoints,
      rotationAngleRadians: rotation,
      curveSegments: [branch(1), branch(-1)],
    );
  }
}
