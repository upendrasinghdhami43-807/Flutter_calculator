import 'dart:math' as math;

import '../expression_engine/errors.dart';
import 'conic_geometry_base.dart';
import 'conic_result.dart';

/// Builds a fully computed [ConicResult] for a parabola from canonical
/// parameters: a vertex, a signed focal distance `p` (positive opens toward
/// +x'/+y', negative toward -x'/-y'), and whether the axis of symmetry runs
/// along the local x or y direction.
class ConicGeometryParabola {
  const ConicGeometryParabola();

  ConicResult parabola({
    required double vertexLocalX,
    required double vertexLocalY,
    required double p,
    required bool opensAlongX,
    double rotation = 0,
    Point2D origin = const Point2D(0, 0),
  }) {
    if (p == 0) throw const MathDomainException('A parabola\'s focal distance cannot be zero.');
    final vertex = transformPoint(vertexLocalX, vertexLocalY, rotation, origin);
    final focus = opensAlongX
        ? transformPoint(vertexLocalX + p, vertexLocalY, rotation, origin)
        : transformPoint(vertexLocalX, vertexLocalY + p, rotation, origin);

    final directrixHalfSpan = math.max(p.abs() * 3, 4.0);
    final directrixSegment = opensAlongX
        ? lineSegmentThrough(vertexLocalX - p, vertexLocalY, 0, 1, directrixHalfSpan, rotation, origin)
        : lineSegmentThrough(vertexLocalX, vertexLocalY - p, 1, 0, directrixHalfSpan, rotation, origin);
    final directrixDescription = opensAlongX ? 'x = ${formatCoefficient(vertexLocalX - p)}' : 'y = ${formatCoefficient(vertexLocalY - p)}';

    final latusRectumLength = (4 * p).abs();
    final latusEndpoints = opensAlongX
        ? [
            transformPoint(vertexLocalX + p, vertexLocalY + 2 * p, rotation, origin),
            transformPoint(vertexLocalX + p, vertexLocalY - 2 * p, rotation, origin),
          ]
        : [
            transformPoint(vertexLocalX + 2 * p, vertexLocalY + p, rotation, origin),
            transformPoint(vertexLocalX - 2 * p, vertexLocalY + p, rotation, origin),
          ];

    final span = math.max(6 * p.abs(), 6.0);
    const steps = 240;
    final points = List.generate(steps + 1, (i) {
      final t = -span + (2 * span * i / steps);
      final localX = opensAlongX ? vertexLocalX + (t * t) / (4 * p) : vertexLocalX + t;
      final localY = opensAlongX ? vertexLocalY + t : vertexLocalY + (t * t) / (4 * p);
      return transformPoint(localX, localY, rotation, origin);
    });

    final axisLabel = rotation.abs() < 1e-9 ? 'x' : "x'";
    final axisLabelY = rotation.abs() < 1e-9 ? 'y' : "y'";
    final equation = opensAlongX
        ? '($axisLabelY − ${formatCoefficient(vertexLocalY)})² = ${formatCoefficient(4 * p)}($axisLabel − ${formatCoefficient(vertexLocalX)})'
        : '($axisLabel − ${formatCoefficient(vertexLocalX)})² = ${formatCoefficient(4 * p)}($axisLabelY − ${formatCoefficient(vertexLocalY)})';

    return ConicResult(
      type: ConicType.parabola,
      standardFormEquation: equation,
      center: vertex,
      vertices: [vertex],
      foci: [focus],
      eccentricity: 1,
      directrixDescriptions: [directrixDescription],
      directrixSegments: [directrixSegment],
      latusRectumLength: latusRectumLength,
      latusRectumEndpoints: latusEndpoints,
      rotationAngleRadians: rotation,
      curveSegments: [points],
    );
  }
}
