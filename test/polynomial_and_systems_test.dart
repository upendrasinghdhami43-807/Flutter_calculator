import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/linear_algebra/linear_system_solver.dart';
import 'package:flutter_calce/core/numeric_methods/polynomial_roots.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PolynomialRoots', () {
    const solver = PolynomialRoots();

    test('finds the two real roots of x² − 4', () {
      final roots = solver.durandKerner([1, 0, -4]);
      final realParts = roots.map((r) => r.real).toList()..sort();
      expect(realParts.first, closeTo(-2, 1e-6));
      expect(realParts.last, closeTo(2, 1e-6));
    });

    test('finds a complex-conjugate pair for x² + 1', () {
      final roots = solver.durandKerner([1, 0, 1]);
      for (final root in roots) {
        expect(root.real.abs(), lessThan(1e-6));
        expect(root.imaginary.abs(), closeTo(1, 1e-6));
      }
    });

    test('rejects a leading coefficient of zero', () {
      expect(() => solver.durandKerner([0, 1, -4]), throwsA(isA<MathDomainException>()));
    });
  });

  group('LinearSystemSolver', () {
    const solver = LinearSystemSolver();

    test('solves a unique 2-variable system', () {
      final solution = solver.solve([
        [2, 1],
        [1, -1],
      ], [5, 1]);
      expect(solution.type, SystemSolutionType.unique);
      expect(solution.values[0], closeTo(2, 1e-9));
      expect(solution.values[1], closeTo(1, 1e-9));
    });

    test('reports an inconsistent system as having no solution', () {
      final solution = solver.solve([
        [1, 1],
        [1, 1],
      ], [2, 5]);
      expect(solution.type, SystemSolutionType.none);
    });

    test('reports a dependent system as having infinite solutions', () {
      final solution = solver.solve([
        [1, 1],
        [2, 2],
      ], [2, 4]);
      expect(solution.type, SystemSolutionType.infinite);
    });
  });
}
