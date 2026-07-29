import 'dart:math' as math;

import '../expression_engine/errors.dart';
import 'conic_geometry_base.dart';
import 'conic_result.dart';

/// Builds a fully computed [ConicResult] for a circle or an ellipse from
/// canonical parameters. [rotation]/[origin] let the same code serve both
/// the manual shape builder (rotation = 0, origin = the user's world-space
/// center) and the general auto-detect solver (rotation = the computed
/// rotation angle, origin = world (0,0), with translation already folded
/// into [centerLocalX]/[centerLocalY]).
class ConicGeometryEllipse {
  const ConicGeometryEllipse();

  ConicResult circle({required double centerLocalX, required double centerLocalY, required double radius, double rotation = 0, Point2D origin = const Point2D(0, 0)}) {
    if (radius <= 0) throw const MathDomainException('A circle radius must be positive.');
    final points = List.generate(
      361,
      (i) => transformPoint(centerLocalX + radius * math.cos(i * math.pi / 180), centerLocalY + radius * math.sin(i * math.pi / 180), rotation, origin),
    );
    final center = transformPoint(centerLocalX, centerLocalY, rotation, origin);
    final vertices = [
      transformPoint(centerLocalX + radius, centerLocalY, rotation, origin),
      transformPoint(centerLocalX - radius, centerLocalY, rotation, origin),
      transformPoint(centerLocalX, centerLocalY + radius, rotation, origin),
      transformPoint(centerLocalX, centerLocalY - radius, rotation, origin),
    ];
    return ConicResult(
      type: ConicType.circle,
      standardFormEquation: '(x - ${formatCoefficient(center.x)})² + (y - ${formatCoefficient(center.y)})² = ${formatCoefficient(radius)}²',
      center: center,
      vertices: vertices,
      foci: [center],
      eccentricity: 0,
      radius: radius,
      directrixDescriptions: const ['Not applicable — a circle has eccentricity 0.'],
      curveSegments: [points],
    );
  }

  ConicResult ellipse({
    required double centerLocalX,
    required double centerLocalY,
    required double axisX,
    required double axisY,
    double rotation = 0,
    Point2D origin = const Point2D(0, 0),
  }) {
    if (axisX <= 0 || axisY <= 0) throw const MathDomainException('Ellipse semi-axis lengths must be positive.');
    final majorAlongX = axisX >= axisY;
    final a = majorAlongX ? axisX : axisY;
    final b = majorAlongX ? axisY : axisX;
    final c = math.sqrt(a * a - b * b);
    final eccentricity = c / a;
    final center = transformPoint(centerLocalX, centerLocalY, rotation, origin);

    final vertices = majorAlongX
        ? [transformPoint(centerLocalX + a, centerLocalY, rotation, origin), transformPoint(centerLocalX - a, centerLocalY, rotation, origin)]
        : [transformPoint(centerLocalX, centerLocalY + a, rotation, origin), transformPoint(centerLocalX, centerLocalY - a, rotation, origin)];
    final foci = majorAlongX
        ? [transformPoint(centerLocalX + c, centerLocalY, rotation, origin), transformPoint(centerLocalX - c, centerLocalY, rotation, origin)]
        : [transformPoint(centerLocalX, centerLocalY + c, rotation, origin), transformPoint(centerLocalX, centerLocalY - c, rotation, origin)];

    final directrixOffset = c < 1e-9 ? double.infinity : a * a / c;
    final directrixSegments = <LineSegment>[];
    final directrixDescriptions = <String>[];
    if (directrixOffset.isFinite) {
      if (majorAlongX) {
        directrixSegments.add(lineSegmentThrough(centerLocalX + directrixOffset, centerLocalY, 0, 1, b * 1.6, rotation, origin));
        directrixSegments.add(lineSegmentThrough(centerLocalX - directrixOffset, centerLocalY, 0, 1, b * 1.6, rotation, origin));
        directrixDescriptions.addAll(['x = ${formatCoefficient(centerLocalX + directrixOffset)}', 'x = ${formatCoefficient(centerLocalX - directrixOffset)}']);
      } else {
        directrixSegments.add(lineSegmentThrough(centerLocalX, centerLocalY + directrixOffset, 1, 0, b * 1.6, rotation, origin));
        directrixSegments.add(lineSegmentThrough(centerLocalX, centerLocalY - directrixOffset, 1, 0, b * 1.6, rotation, origin));
        directrixDescriptions.addAll(['y = ${formatCoefficient(centerLocalY + directrixOffset)}', 'y = ${formatCoefficient(centerLocalY - directrixOffset)}']);
      }
    }

    final latusRectumLength = 2 * b * b / a;
    final halfLatus = b * b / a;
    final latusEndpoints = majorAlongX
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

    final points = List.generate(361, (i) {
      final t = i * math.pi / 180;
      final localX = centerLocalX + (majorAlongX ? a * math.cos(t) : b * math.cos(t));
      final localY = centerLocalY + (majorAlongX ? b * math.sin(t) : a * math.sin(t));
      return transformPoint(localX, localY, rotation, origin);
    });

    final axisLabel = rotation.abs() < 1e-9 ? 'x' : "x'";
    final axisLabelY = rotation.abs() < 1e-9 ? 'y' : "y'";
    final equation = majorAlongX
        ? '($axisLabel − ${formatCoefficient(centerLocalX)})²/${formatCoefficient(a * a)} + ($axisLabelY − ${formatCoefficient(centerLocalY)})²/${formatCoefficient(b * b)} = 1'
        : '($axisLabel − ${formatCoefficient(centerLocalX)})²/${formatCoefficient(b * b)} + ($axisLabelY − ${formatCoefficient(centerLocalY)})²/${formatCoefficient(a * a)} = 1';

    return ConicResult(
      type: ConicType.ellipse,
      standardFormEquation: equation,
      center: center,
      vertices: vertices,
      foci: foci,
      eccentricity: eccentricity,
      semiMajorAxis: a,
      semiMinorAxis: b,
      directrixDescriptions: directrixDescriptions,
      directrixSegments: directrixSegments,
      latusRectumLength: latusRectumLength,
      latusRectumEndpoints: latusEndpoints,
      rotationAngleRadians: rotation,
      curveSegments: [points],
    );
  }
}
