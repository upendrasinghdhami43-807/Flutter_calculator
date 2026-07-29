import 'dart:math' as math;

import '../expression_engine/errors.dart';
import 'matrix.dart';

/// Estimates real eigenvalues of a square matrix using the unshifted QR
/// algorithm. This converges reliably for matrices whose eigenvalues are
/// real and distinct (the common case for the 2x2/3x3 inputs this app
/// supports). Matrices with complex eigenvalue pairs are explicitly
/// reported as unsupported rather than returning a wrong answer.
///
/// 4x4 support is best-effort: the same algorithm is applied, but
/// convergence and accuracy are not guaranteed for every 4x4 input.
class EigenSolver {
  const EigenSolver();

  List<double> realEigenvalues(Matrix matrix, {int maxIterations = 500, double tolerance = 1e-9}) {
    if (matrix.rowCount != matrix.columnCount) {
      throw const MathDomainException('Eigenvalues require a square matrix.');
    }
    var current = matrix;
    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final decomposition = _qrDecompose(current);
      final next = decomposition.r.multiply(decomposition.q);
      current = next;
      if (_offDiagonalMagnitude(current) < tolerance) break;
    }
    if (_offDiagonalMagnitude(current) > 1e-4) {
      throw const MathDomainException(
        'This matrix appears to have complex eigenvalues, which are not supported yet.',
      );
    }
    return List.generate(current.rowCount, (index) => current.values[index][index]);
  }

  double _offDiagonalMagnitude(Matrix matrix) {
    var total = 0.0;
    for (var row = 1; row < matrix.rowCount; row++) {
      for (var column = 0; column < row; column++) {
        total += matrix.values[row][column].abs();
      }
    }
    return total;
  }

  ({Matrix q, Matrix r}) _qrDecompose(Matrix matrix) {
    final n = matrix.rowCount;
    final columns = List.generate(n, (col) => List.generate(n, (row) => matrix.values[row][col]));
    final orthogonal = <List<double>>[];
    final rValues = List.generate(n, (_) => List.filled(n, 0.0));
    for (var j = 0; j < n; j++) {
      final v = List<double>.from(columns[j]);
      for (var i = 0; i < j; i++) {
        final projection = _dot(orthogonal[i], columns[j]);
        rValues[i][j] = projection;
        for (var k = 0; k < n; k++) {
          v[k] -= projection * orthogonal[i][k];
        }
      }
      final norm = math.sqrt(_dot(v, v));
      if (norm < 1e-12) {
        orthogonal.add(List.filled(n, 0.0));
        continue;
      }
      orthogonal.add(v.map((value) => value / norm).toList());
      rValues[j][j] = norm;
    }
    final qValues = List.generate(n, (row) => List.generate(n, (col) => orthogonal[col][row]));
    return (q: Matrix(qValues), r: Matrix(rValues));
  }

  double _dot(List<double> a, List<double> b) {
    var total = 0.0;
    for (var i = 0; i < a.length; i++) {
      total += a[i] * b[i];
    }
    return total;
  }
}
