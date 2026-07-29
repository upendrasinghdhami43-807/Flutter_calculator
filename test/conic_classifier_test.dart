import 'package:flutter_calce/core/conics/conic_result.dart';
import 'package:flutter_calce/core/conics/conic_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = ConicSolver();

  test('x² + y² − 4 = 0 is a circle of radius 2 centered at the origin', () {
    final result = solver.solveGeneral(1, 0, 1, 0, 0, -4);
    expect(result.type, ConicType.circle);
    expect(result.radius, closeTo(2, 1e-8));
    expect(result.center.x, closeTo(0, 1e-8));
    expect(result.center.y, closeTo(0, 1e-8));
  });

  test('x² − 4y = 0 is a parabola opening upward with vertex at the origin', () {
    final result = solver.solveGeneral(1, 0, 0, 0, -4, 0);
    expect(result.type, ConicType.parabola);
    expect(result.vertices.single.x, closeTo(0, 1e-8));
    expect(result.vertices.single.y, closeTo(0, 1e-8));
    expect(result.foci.single.x, closeTo(0, 1e-8));
    expect(result.foci.single.y, closeTo(1, 1e-8));
  });

  test('9x² + 4y² − 36 = 0 is an ellipse with semi-major axis 3 along y', () {
    final result = solver.solveGeneral(9, 0, 4, 0, 0, -36);
    expect(result.type, ConicType.ellipse);
    expect(result.semiMajorAxis, closeTo(3, 1e-8));
    expect(result.semiMinorAxis, closeTo(2, 1e-8));
    expect(result.eccentricity, closeTo(2.23606797749979 / 3, 1e-6));
  });

  test('x² − y² − 1 = 0 is a rectangular hyperbola with vertices at (±1, 0)', () {
    final result = solver.solveGeneral(1, 0, -1, 0, 0, -1);
    expect(result.type, ConicType.rectangularHyperbola);
    expect(result.semiMajorAxis, closeTo(1, 1e-8));
    expect(result.semiMinorAxis, closeTo(1, 1e-8));
    final xs = result.vertices.map((v) => v.x).toList()..sort();
    expect(xs.first, closeTo(-1, 1e-8));
    expect(xs.last, closeTo(1, 1e-8));
  });

  test('a degenerate equation is reported instead of a curve', () {
    // x² - y² = 0 -> (x-y)(x+y)=0, a pair of intersecting lines.
    final result = solver.solveGeneral(1, 0, -1, 0, 0, 0);
    expect(result.isDegenerate, isTrue);
    expect(result.degeneracyMessage, isNotNull);
  });
}
