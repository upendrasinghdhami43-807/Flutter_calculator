import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/expression_engine/errors.dart';
import '../../../core/linear_algebra/eigen.dart';
import '../../../core/linear_algebra/matrix.dart';
import '../../../shared/services/history_service.dart';

enum MatrixOperation { determinant, inverse, transpose, rank, eigenvalues, add, subtract, multiply }

class SavedMatrix {
  const SavedMatrix({required this.rows, required this.columns, required this.values});

  final int rows;
  final int columns;
  final List<String> values;

  Matrix toMatrix() => Matrix(List.generate(rows, (row) {
        return List.generate(columns, (column) => double.parse(values[row * columns + column].trim()));
      }));
}

class MatrixToolState {
  const MatrixToolState({
    this.rows = 2,
    this.columns = 2,
    this.values = const ['0', '0', '0', '0'],
    this.secondaryValues = const ['0', '0', '0', '0'],
    this.savedMatrices = const {},
    this.result,
    this.error,
  });

  final int rows;
  final int columns;
  final List<String> values;
  final List<String> secondaryValues;
  final Map<String, SavedMatrix> savedMatrices;
  final String? result;
  final String? error;

  MatrixToolState copyWith({
    int? rows,
    int? columns,
    List<String>? values,
    List<String>? secondaryValues,
    Map<String, SavedMatrix>? savedMatrices,
    String? result,
    String? error,
    bool clearOutput = false,
    bool clearError = false,
  }) {
    return MatrixToolState(
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      values: values ?? this.values,
      secondaryValues: secondaryValues ?? this.secondaryValues,
      savedMatrices: savedMatrices ?? this.savedMatrices,
      result: clearOutput ? null : result ?? this.result,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class MatrixController extends Notifier<MatrixToolState> {
  static const _minimumSize = 1;
  static const _maximumSize = 4;

  @override
  MatrixToolState build() => const MatrixToolState();

  void setSize({required int rows, required int columns}) {
    final safeRows = rows.clamp(_minimumSize, _maximumSize);
    final safeColumns = columns.clamp(_minimumSize, _maximumSize);
    final count = safeRows * safeColumns;
    state = MatrixToolState(
      rows: safeRows,
      columns: safeColumns,
      values: _resize(state.values, count),
      secondaryValues: _resize(state.secondaryValues, count),
      savedMatrices: state.savedMatrices,
    );
  }

  void setValue(int index, String value, {bool secondary = false}) {
    final updated = List<String>.from(secondary ? state.secondaryValues : state.values);
    updated[index] = value;
    state = secondary
        ? state.copyWith(secondaryValues: updated, clearOutput: true, clearError: true)
        : state.copyWith(values: updated, clearOutput: true, clearError: true);
  }

  void execute(MatrixOperation operation) {
    try {
      final primary = _readMatrix(state.values);
      final result = switch (operation) {
        MatrixOperation.determinant => 'det(A) = ${_format(primary.determinant())}',
        MatrixOperation.inverse => _formatMatrix('A⁻¹', primary.inverse()),
        MatrixOperation.transpose => _formatMatrix('Aᵀ', primary.transpose()),
        MatrixOperation.rank => 'rank(A) = ${primary.rank()}',
        MatrixOperation.eigenvalues => _formatValues('Eigenvalues', const EigenSolver().realEigenvalues(primary)),
        MatrixOperation.add => _formatMatrix('A + B', primary + _readMatrix(state.secondaryValues)),
        MatrixOperation.subtract => _formatMatrix('A − B', primary - _readMatrix(state.secondaryValues)),
        MatrixOperation.multiply => _formatMatrix('A × B', primary.multiply(_readMatrix(state.secondaryValues))),
      };
      state = state.copyWith(result: result, clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'Matrix', expression: operation.name, result: result);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Every matrix cell must contain a valid number.');
    }
  }

  void saveCurrentAs(String name) {
    final normalized = name.toUpperCase();
    if (!const {'A', 'B', 'C'}.contains(normalized)) return;
    final saved = Map<String, SavedMatrix>.from(state.savedMatrices)
      ..[normalized] = SavedMatrix(rows: state.rows, columns: state.columns, values: List<String>.from(state.values));
    state = state.copyWith(savedMatrices: saved, clearError: true);
  }

  void loadSaved(String name) {
    final saved = state.savedMatrices[name.toUpperCase()];
    if (saved == null) return;
    state = MatrixToolState(
      rows: saved.rows,
      columns: saved.columns,
      values: List<String>.from(saved.values),
      secondaryValues: state.secondaryValues,
      savedMatrices: state.savedMatrices,
    );
  }

  void removeSaved(String name) {
    final saved = Map<String, SavedMatrix>.from(state.savedMatrices)..remove(name.toUpperCase());
    state = state.copyWith(savedMatrices: saved);
  }

  void executeSaved(MatrixOperation operation, {required String leftName, required String rightName}) {
    try {
      final left = _readSaved(leftName);
      final right = _readSaved(rightName);
      final label = '$leftName ${_symbol(operation)} $rightName';
      final result = switch (operation) {
        MatrixOperation.add => _formatMatrix(label, left + right),
        MatrixOperation.subtract => _formatMatrix(label, left - right),
        MatrixOperation.multiply => _formatMatrix(label, left.multiply(right)),
        _ => throw const MathDomainException('Choose addition, subtraction, or multiplication for saved matrices.'),
      };
      state = state.copyWith(result: result, clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'Matrix', expression: label, result: result);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Every saved matrix cell must contain a valid number.');
    }
  }

  Matrix _readSaved(String name) {
    final saved = state.savedMatrices[name.toUpperCase()];
    if (saved == null) throw MathDomainException('Save matrix ${name.toUpperCase()} before using it in an operation.');
    return saved.toMatrix();
  }

  String _symbol(MatrixOperation operation) => switch (operation) {
    MatrixOperation.add => '+',
    MatrixOperation.subtract => '−',
    MatrixOperation.multiply => '×',
    _ => '?',
  };

  Matrix _readMatrix(List<String> source) {
    final values = List.generate(state.rows, (row) {
      return List.generate(state.columns, (column) => double.parse(source[row * state.columns + column].trim()));
    });
    return Matrix(values);
  }

  List<String> _resize(List<String> source, int count) => List.generate(count, (index) => index < source.length ? source[index] : '0');

  String _formatMatrix(String label, Matrix matrix) {
    final rows = matrix.values.map((row) => '[${row.map(_format).join(', ')}]').join('\n');
    return '$label =\n$rows';
  }

  String _formatValues(String label, List<double> values) => '$label: ${values.map(_format).join(', ')}';

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

final matrixControllerProvider = NotifierProvider<MatrixController, MatrixToolState>(MatrixController.new);
