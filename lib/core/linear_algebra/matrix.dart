import '../expression_engine/errors.dart';

class Matrix {
  Matrix(List<List<double>> values)
      : _values = values.map(List<double>.from).toList(growable: false) {
    if (_values.isEmpty || _values.first.isEmpty || _values.any((row) => row.length != columnCount)) {
      throw const MathDomainException('Matrix values must form a non-empty rectangle.');
    }
  }

  final List<List<double>> _values;

  int get rowCount => _values.length;
  int get columnCount => _values.first.length;
  double operator [](List<int> index) => _values[index[0]][index[1]];
  List<List<double>> get values => _values.map(List<double>.from).toList(growable: false);

  Matrix operator +(Matrix other) => _combine(other, (left, right) => left + right);
  Matrix operator -(Matrix other) => _combine(other, (left, right) => left - right);

  Matrix multiply(Matrix other) {
    if (columnCount != other.rowCount) {
      throw const MathDomainException('Matrix dimensions are incompatible for multiplication.');
    }
    return Matrix(List.generate(rowCount, (row) => List.generate(other.columnCount, (column) {
      return List.generate(columnCount, (index) => _values[row][index] * other._values[index][column])
          .reduce((sum, value) => sum + value);
    })));
  }

  Matrix transpose() => Matrix(List.generate(columnCount, (column) => List.generate(rowCount, (row) => _values[row][column])));

  int rank() {
    final data = values;
    var rank = 0;
    for (var column = 0; column < columnCount && rank < rowCount; column++) {
      var pivot = -1;
      for (var row = rank; row < rowCount; row++) {
        if (data[row][column].abs() > 1e-9) {
          pivot = row;
          break;
        }
      }
      if (pivot == -1) continue;
      final swap = data[rank];
      data[rank] = data[pivot];
      data[pivot] = swap;
      final pivotValue = data[rank][column];
      for (var row = rank + 1; row < rowCount; row++) {
        final factor = data[row][column] / pivotValue;
        for (var c = column; c < columnCount; c++) {
          data[row][c] -= factor * data[rank][c];
        }
      }
      rank++;
    }
    return rank;
  }

  double determinant() {
    if (rowCount != columnCount) throw const MathDomainException('Determinant requires a square matrix.');
    final data = values;
    var sign = 1.0;
    var determinant = 1.0;
    for (var pivot = 0; pivot < rowCount; pivot++) {
      var largest = pivot;
      for (var row = pivot + 1; row < rowCount; row++) {
        if (data[row][pivot].abs() > data[largest][pivot].abs()) largest = row;
      }
      if (data[largest][pivot].abs() < 1e-12) return 0;
      if (largest != pivot) {
        final temporary = data[pivot];
        data[pivot] = data[largest];
        data[largest] = temporary;
        sign = -sign;
      }
      final pivotValue = data[pivot][pivot];
      determinant *= pivotValue;
      for (var row = pivot + 1; row < rowCount; row++) {
        final factor = data[row][pivot] / pivotValue;
        for (var column = pivot + 1; column < columnCount; column++) {
          data[row][column] -= factor * data[pivot][column];
        }
      }
    }
    return determinant * sign;
  }

  Matrix inverse() {
    if (rowCount != columnCount) throw const MathDomainException('Inverse requires a square matrix.');
    final augmented = List.generate(rowCount, (row) => [..._values[row], ...List.generate(columnCount, (column) => row == column ? 1.0 : 0.0)]);
    for (var pivot = 0; pivot < rowCount; pivot++) {
      var largest = pivot;
      for (var row = pivot + 1; row < rowCount; row++) {
        if (augmented[row][pivot].abs() > augmented[largest][pivot].abs()) largest = row;
      }
      if (augmented[largest][pivot].abs() < 1e-12) throw const MathDomainException('Matrix is singular and cannot be inverted.');
      final temporary = augmented[pivot];
      augmented[pivot] = augmented[largest];
      augmented[largest] = temporary;
      final pivotValue = augmented[pivot][pivot];
      for (var column = 0; column < 2 * columnCount; column++) {
        augmented[pivot][column] /= pivotValue;
      }
      for (var row = 0; row < rowCount; row++) {
        if (row == pivot) continue;
        final factor = augmented[row][pivot];
        for (var column = 0; column < 2 * columnCount; column++) {
          augmented[row][column] -= factor * augmented[pivot][column];
        }
      }
    }
    return Matrix(List.generate(rowCount, (row) => augmented[row].sublist(columnCount)));
  }

  Matrix _combine(Matrix other, double Function(double, double) operation) {
    if (rowCount != other.rowCount || columnCount != other.columnCount) {
      throw const MathDomainException('Matrix dimensions must match.');
    }
    return Matrix(List.generate(rowCount, (row) => List.generate(columnCount, (column) => operation(_values[row][column], other._values[row][column]))));
  }
}