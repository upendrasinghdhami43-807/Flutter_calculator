import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/linear_algebra/matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computes a square matrix determinant', () {
    final matrix = Matrix([
      [4, 7],
      [2, 6],
    ]);
    expect(matrix.determinant(), closeTo(10, 1e-10));
  });

  test('inverts a non-singular matrix', () {
    final inverse = Matrix([
      [4, 7],
      [2, 6],
    ]).inverse();
    expect(inverse.values[0][0], closeTo(0.6, 1e-10));
    expect(inverse.values[1][1], closeTo(0.4, 1e-10));
  });

  test('rejects inversion of a singular matrix', () {
    expect(
      () => Matrix([
        [1, 2],
        [2, 4],
      ]).inverse(),
      throwsA(isA<MathDomainException>()),
    );
  });
}
