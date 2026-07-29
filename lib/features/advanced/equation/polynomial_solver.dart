import 'dart:math' as math;

import '../../../core/expression_engine/complex_number.dart';
import '../../../core/expression_engine/errors.dart';
import '../../../core/numeric_methods/polynomial_roots.dart';

/// UI-facing polynomial wrapper. It uses the quadratic formula for degree 2
/// so repeated/complex roots are stable and understandable, and delegates
/// degree 3/4 to the shared Durand-Kerner core implementation.
class PolynomialEquationSolver {
  const PolynomialEquationSolver({this.rootSolver = const PolynomialRoots()});

  final PolynomialRoots rootSolver;

  List<Complex> solve(List<double> coefficients) {
    if (coefficients.length < 3 || coefficients.length > 5) {
      throw const MathDomainException('Choose a quadratic, cubic, or quartic polynomial.');
    }
    if (coefficients.first.abs() < 1e-12) {
      throw const MathDomainException('The leading coefficient cannot be zero.');
    }
    return coefficients.length == 3 ? _solveQuadratic(coefficients) : rootSolver.durandKerner(coefficients);
  }

  List<Complex> _solveQuadratic(List<double> coefficients) {
    final a = coefficients[0];
    final b = coefficients[1];
    final c = coefficients[2];
    final discriminant = b * b - 4 * a * c;
    if (discriminant >= 0) {
      final squareRoot = math.sqrt(discriminant);
      return [Complex((-b + squareRoot) / (2 * a), 0), Complex((-b - squareRoot) / (2 * a), 0)];
    }
    final real = -b / (2 * a);
    final imaginary = math.sqrt(-discriminant) / (2 * a);
    return [Complex(real, imaginary), Complex(real, -imaginary)];
  }

  String formatRoots(List<Complex> roots) => roots.asMap().entries.map((entry) => 'x${entry.key + 1} = ${entry.value}').join('\n');
}
