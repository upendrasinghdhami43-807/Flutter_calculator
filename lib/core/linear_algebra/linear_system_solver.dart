import '../expression_engine/errors.dart';

enum SystemSolutionType { unique, none, infinite }

class SystemSolution {
  const SystemSolution(this.type, this.values);

  final SystemSolutionType type;
  final List<double> values;
}

/// Solves a square system of linear equations `A x = b` via Gauss-Jordan
/// elimination with partial pivoting, gracefully reporting no-solution and
/// infinite-solution cases instead of throwing.
class LinearSystemSolver {
  const LinearSystemSolver();

  SystemSolution solve(List<List<double>> coefficients, List<double> constants) {
    final rowCount = coefficients.length;
    if (rowCount == 0 || coefficients.any((row) => row.length != rowCount) || constants.length != rowCount) {
      throw const MathDomainException('The system must have a square coefficient matrix matching the constants.');
    }
    final augmented = List.generate(rowCount, (row) => [...coefficients[row], constants[row]]);

    var pivotRow = 0;
    for (var column = 0; column < rowCount && pivotRow < rowCount; column++) {
      var largest = pivotRow;
      for (var row = pivotRow + 1; row < rowCount; row++) {
        if (augmented[row][column].abs() > augmented[largest][column].abs()) largest = row;
      }
      if (augmented[largest][column].abs() < 1e-10) continue;
      final swap = augmented[pivotRow];
      augmented[pivotRow] = augmented[largest];
      augmented[largest] = swap;

      final pivotValue = augmented[pivotRow][column];
      for (var c = 0; c <= rowCount; c++) {
        augmented[pivotRow][c] /= pivotValue;
      }
      for (var row = 0; row < rowCount; row++) {
        if (row == pivotRow) continue;
        final factor = augmented[row][column];
        for (var c = 0; c <= rowCount; c++) {
          augmented[row][c] -= factor * augmented[pivotRow][c];
        }
      }
      pivotRow++;
    }

    for (var row = pivotRow; row < rowCount; row++) {
      final allZeroCoefficients = augmented[row].sublist(0, rowCount).every((value) => value.abs() < 1e-9);
      final constantIsZero = augmented[row][rowCount].abs() < 1e-9;
      if (allZeroCoefficients && !constantIsZero) {
        return const SystemSolution(SystemSolutionType.none, []);
      }
    }
    if (pivotRow < rowCount) {
      return const SystemSolution(SystemSolutionType.infinite, []);
    }
    return SystemSolution(SystemSolutionType.unique, List.generate(rowCount, (row) => augmented[row][rowCount]));
  }
}
