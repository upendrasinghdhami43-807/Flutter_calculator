import 'dart:math' as math;

import 'conic_classifier.dart';
import 'conic_geometry_ellipse.dart';
import 'conic_geometry_hyperbola.dart';
import 'conic_geometry_parabola.dart';
import 'conic_result.dart';

/// Implements the full seven-step conic auto-detect pipeline (degeneracy
/// check → discriminant classification → rotation → translate/complete the
/// square → extract standard parameters → transform back to original
/// coordinates) plus convenience entry points for the manual shape-picker
/// path, which is always axis-aligned (rotation = 0).
class ConicSolver {
  const ConicSolver({
    this.classifier = const ConicClassifier(),
    this.ellipseGeometry = const ConicGeometryEllipse(),
    this.parabolaGeometry = const ConicGeometryParabola(),
    this.hyperbolaGeometry = const ConicGeometryHyperbola(),
  });

  final ConicClassifier classifier;
  final ConicGeometryEllipse ellipseGeometry;
  final ConicGeometryParabola parabolaGeometry;
  final ConicGeometryHyperbola hyperbolaGeometry;

  static const double _tolerance = 1e-9;

  /// Step 1-7: classifies and solves the general second-degree equation
  /// `A·x² + B·x·y + C·y² + D·x + E·y + F = 0`.
  ConicResult solveGeneral(double a, double b, double c, double d, double e, double f) {
    final classification = classifier.classify(a, b, c, d, e, f);
    if (classification.isDegenerate) {
      return ConicResult(
        type: ConicType.degenerate,
        isDegenerate: true,
        degeneracyMessage: classification.degeneracyMessage,
        standardFormEquation: _originalEquationText(a, b, c, d, e, f),
        center: const Point2D(0, 0),
        vertices: const [],
        foci: const [],
        curveSegments: const [],
      );
    }

    // Step 3: eliminate the xy term via rotation.
    final theta = b.abs() < _tolerance ? 0.0 : 0.5 * math.atan2(b, a - c);
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);
    final aPrime = a * cosT * cosT + b * cosT * sinT + c * sinT * sinT;
    final cPrime = a * sinT * sinT - b * cosT * sinT + c * cosT * cosT;
    final dPrime = d * cosT + e * sinT;
    final ePrime = -d * sinT + e * cosT;
    final fPrime = f;

    return switch (classification.type) {
      ConicType.circle || ConicType.ellipse => _solveEllipseLike(classification.type, aPrime, cPrime, dPrime, ePrime, fPrime, theta),
      ConicType.parabola => _solveParabola(aPrime, cPrime, dPrime, ePrime, fPrime, theta),
      ConicType.hyperbola || ConicType.rectangularHyperbola => _solveHyperbolaLike(classification.type, aPrime, cPrime, dPrime, ePrime, fPrime, theta),
      ConicType.degenerate => throw StateError('Unreachable: degenerate case handled above.'),
    };
  }

  ConicResult _solveEllipseLike(ConicType type, double aPrime, double cPrime, double dPrime, double ePrime, double fPrime, double theta) {
    final h = -dPrime / (2 * aPrime);
    final k = -ePrime / (2 * cPrime);
    final constantTerm = fPrime - (dPrime * dPrime) / (4 * aPrime) - (ePrime * ePrime) / (4 * cPrime);
    final rhs = -constantTerm;
    final axisXSquared = rhs / aPrime;
    final axisYSquared = rhs / cPrime;
    if (axisXSquared <= 0 || axisYSquared <= 0) {
      // Numerically inconsistent with a real ellipse/circle; treat as degenerate.
      return ConicResult(
        type: ConicType.degenerate,
        isDegenerate: true,
        degeneracyMessage: 'This equation does not describe a real ellipse or circle.',
        standardFormEquation: 'No real locus',
        center: const Point2D(0, 0),
        vertices: const [],
        foci: const [],
        curveSegments: const [],
      );
    }
    if (type == ConicType.circle) {
      return ellipseGeometry.circle(centerLocalX: h, centerLocalY: k, radius: math.sqrt(axisXSquared), rotation: theta);
    }
    return ellipseGeometry.ellipse(centerLocalX: h, centerLocalY: k, axisX: math.sqrt(axisXSquared), axisY: math.sqrt(axisYSquared), rotation: theta);
  }

  ConicResult _solveParabola(double aPrime, double cPrime, double dPrime, double ePrime, double fPrime, double theta) {
    if (aPrime.abs() < _tolerance) {
      final k = -ePrime / (2 * cPrime);
      final constantTerm = fPrime - (ePrime * ePrime) / (4 * cPrime);
      final p = -dPrime / (4 * cPrime);
      final h = -constantTerm / dPrime;
      return parabolaGeometry.parabola(vertexLocalX: h, vertexLocalY: k, p: p, opensAlongX: true, rotation: theta);
    }
    final h = -dPrime / (2 * aPrime);
    final constantTerm = fPrime - (dPrime * dPrime) / (4 * aPrime);
    final p = -ePrime / (4 * aPrime);
    final k = -constantTerm / ePrime;
    return parabolaGeometry.parabola(vertexLocalX: h, vertexLocalY: k, p: p, opensAlongX: false, rotation: theta);
  }

  ConicResult _solveHyperbolaLike(ConicType type, double aPrime, double cPrime, double dPrime, double ePrime, double fPrime, double theta) {
    final h = -dPrime / (2 * aPrime);
    final k = -ePrime / (2 * cPrime);
    final constantTerm = fPrime - (dPrime * dPrime) / (4 * aPrime) - (ePrime * ePrime) / (4 * cPrime);
    final rhs = -constantTerm;
    final alongXValue = rhs / aPrime;
    final transverseAlongX = alongXValue > 0;
    final aSquared = transverseAlongX ? alongXValue : rhs / cPrime;
    final bSquared = transverseAlongX ? -(rhs / cPrime) : -(rhs / aPrime);
    return hyperbolaGeometry.hyperbola(
      centerLocalX: h,
      centerLocalY: k,
      a: math.sqrt(aSquared),
      b: math.sqrt(bSquared),
      transverseAlongX: transverseAlongX,
      rotation: theta,
      isRectangular: type == ConicType.rectangularHyperbola,
    );
  }

  String _originalEquationText(double a, double b, double c, double d, double e, double f) {
    return '${a}x² + ${b}xy + ${c}y² + ${d}x + ${e}y + $f = 0';
  }

  // --- Manual shape-picker entry points (always axis-aligned; rotation = 0) ---

  ConicResult manualCircle({required Point2D center, required double radius}) =>
      ellipseGeometry.circle(centerLocalX: 0, centerLocalY: 0, radius: radius, origin: center);

  ConicResult manualEllipse({required Point2D center, required double axisX, required double axisY}) =>
      ellipseGeometry.ellipse(centerLocalX: 0, centerLocalY: 0, axisX: axisX, axisY: axisY, origin: center);

  ConicResult manualParabola({required Point2D vertex, required double p, required bool opensAlongX}) =>
      parabolaGeometry.parabola(vertexLocalX: 0, vertexLocalY: 0, p: p, opensAlongX: opensAlongX, origin: vertex);

  ConicResult manualHyperbola({required Point2D center, required double a, required double b, required bool transverseAlongX}) =>
      hyperbolaGeometry.hyperbola(centerLocalX: 0, centerLocalY: 0, a: a, b: b, transverseAlongX: transverseAlongX, origin: center);

  ConicResult manualRectangularHyperbola({required Point2D center, required double a}) => hyperbolaGeometry.hyperbola(
    centerLocalX: 0,
    centerLocalY: 0,
    a: a,
    b: a,
    transverseAlongX: true,
    origin: center,
    isRectangular: true,
  );
}
