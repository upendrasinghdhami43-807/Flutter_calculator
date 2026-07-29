import 'dart:math' as math;

import '../expression_engine/complex_number.dart';
import '../expression_engine/errors.dart';

/// Finds all roots (real or complex) of a polynomial with real
/// coefficients using the Durand-Kerner (Weierstrass) iterative method.
///
/// [coefficients] is ordered from the highest-degree term to the constant
/// term, e.g. `[1, 0, -4]` represents `x^2 - 4`.
class PolynomialRoots {
  const PolynomialRoots();

  List<Complex> durandKerner(List<double> coefficients, {int maxIterations = 300, double tolerance = 1e-10}) {
    final degree = coefficients.length - 1;
    if (degree < 1) {
      throw const MathDomainException('A polynomial must have degree at least 1.');
    }
    if (coefficients.first == 0) {
      throw const MathDomainException('The leading coefficient cannot be zero.');
    }
    final normalized = coefficients.map((value) => value / coefficients.first).toList();

    var roots = List.generate(degree, (index) {
      final angle = 2 * math.pi * index / degree + 0.4;
      return Complex.fromPolar(0.6 + index * 0.3, angle) + const Complex(0.9, 0.4);
    });

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      var maxDelta = 0.0;
      final next = List<Complex>.from(roots);
      for (var i = 0; i < degree; i++) {
        final numerator = _evaluate(normalized, roots[i]);
        var denominator = const Complex(1, 0);
        for (var j = 0; j < degree; j++) {
          if (j == i) continue;
          denominator = denominator * (roots[i] - roots[j]);
        }
        if (denominator.magnitude < 1e-14) continue;
        final delta = numerator / denominator;
        next[i] = roots[i] - delta;
        maxDelta = math.max(maxDelta, delta.magnitude);
      }
      roots = next;
      if (maxDelta < tolerance) break;
    }
    return roots;
  }

  Complex _evaluate(List<double> coefficients, Complex x) {
    var result = const Complex(0, 0);
    for (final coefficient in coefficients) {
      result = result * x + Complex(coefficient, 0);
    }
    return result;
  }
}
