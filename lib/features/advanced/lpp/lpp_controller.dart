import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/expression_engine/errors.dart';
import '../../../core/numeric_methods/simplex_solver.dart';
import '../../../shared/services/history_service.dart';

class LppState {
  const LppState({
    this.maximize = true,
    this.numVariables = 2,
    this.numConstraints = 2,
    this.objectiveCoefficients = const ['1', '1'],
    this.constraintCoefficients = const ['1', '0', '0', '1'],
    this.constraintRhs = const ['4', '3'],
    this.constraintTypes = const ['<=', '<='],
    this.result,
    this.error,
  });

  final bool maximize;
  final int numVariables;
  final int numConstraints;
  final List<String> objectiveCoefficients;
  final List<String> constraintCoefficients;
  final List<String> constraintRhs;
  final List<String> constraintTypes;
  final String? result;
  final String? error;

  LppState copyWith({
    bool? maximize,
    int? numVariables,
    int? numConstraints,
    List<String>? objectiveCoefficients,
    List<String>? constraintCoefficients,
    List<String>? constraintRhs,
    List<String>? constraintTypes,
    String? result,
    String? error,
    bool clearOutput = false,
    bool clearError = false,
  }) =>
      LppState(
        maximize: maximize ?? this.maximize,
        numVariables: numVariables ?? this.numVariables,
        numConstraints: numConstraints ?? this.numConstraints,
        objectiveCoefficients: objectiveCoefficients ?? this.objectiveCoefficients,
        constraintCoefficients: constraintCoefficients ?? this.constraintCoefficients,
        constraintRhs: constraintRhs ?? this.constraintRhs,
        constraintTypes: constraintTypes ?? this.constraintTypes,
        result: clearOutput ? null : result ?? this.result,
        error: clearError ? null : error ?? this.error,
      );
}

class LppController extends Notifier<LppState> {
  @override
  LppState build() => const LppState();

  void setMaximize(bool value) => state = state.copyWith(maximize: value, clearOutput: true, clearError: true);

  void setNumVariables(int value) {
    final vars = value.clamp(1, 4);
    state = state.copyWith(
      numVariables: vars,
      objectiveCoefficients: _resize(state.objectiveCoefficients, vars),
      constraintCoefficients: _resize(state.constraintCoefficients, vars * state.numConstraints),
      clearOutput: true,
      clearError: true,
    );
  }

  void setNumConstraints(int value) {
    final cons = value.clamp(1, 6);
    state = state.copyWith(
      numConstraints: cons,
      constraintCoefficients: _resize(state.constraintCoefficients, state.numVariables * cons),
      constraintRhs: _resize(state.constraintRhs, cons),
      constraintTypes: List.generate(cons, (i) => i < state.constraintTypes.length ? state.constraintTypes[i] : '<='),
      clearOutput: true,
      clearError: true,
    );
  }

  void setObjectiveCoefficient(int index, String value) {
    final updated = List<String>.from(state.objectiveCoefficients)..[index] = value;
    state = state.copyWith(objectiveCoefficients: updated, clearOutput: true, clearError: true);
  }

  void setConstraintCoefficient(int index, String value) {
    final updated = List<String>.from(state.constraintCoefficients)..[index] = value;
    state = state.copyWith(constraintCoefficients: updated, clearOutput: true, clearError: true);
  }

  void setConstraintRhs(int index, String value) {
    final updated = List<String>.from(state.constraintRhs)..[index] = value;
    state = state.copyWith(constraintRhs: updated, clearOutput: true, clearError: true);
  }

  void setConstraintType(int index, String value) {
    final updated = List<String>.from(state.constraintTypes)..[index] = value;
    state = state.copyWith(constraintTypes: updated, clearOutput: true, clearError: true);
  }

  void solve() {
    try {
      final objective = state.objectiveCoefficients.map((v) => double.parse(v.trim())).toList();
      final constraints = List.generate(state.numConstraints, (i) {
        return List.generate(state.numVariables, (j) {
          return double.parse(state.constraintCoefficients[i * state.numVariables + j].trim());
        });
      });
      final rhs = state.constraintRhs.map((v) => double.parse(v.trim())).toList();

      final solver = const SimplexSolver();
      final result = solver.solve(
        objective: objective,
        constraints: constraints,
        rhs: rhs,
        constraintTypes: state.constraintTypes,
        maximize: state.maximize,
      );

      final buffer = StringBuffer();
      buffer.writeln('═══ LPP Result ═══');
      buffer.writeln();

      // Problem statement
      buffer.write(state.maximize ? 'Maximize' : 'Minimize');
      buffer.write(' Z = ');
      final varNames = ['x₁', 'x₂', 'x₃', 'x₄'];
      for (var i = 0; i < state.numVariables; i++) {
        if (i > 0) buffer.write(' + ');
        buffer.write('${state.objectiveCoefficients[i]}${varNames[i]}');
      }
      buffer.writeln();
      buffer.writeln();

      if (!result.feasible) {
        buffer.writeln('Status: ${result.message}');
      } else {
        buffer.writeln('Status: ${result.message}');
        buffer.writeln('Optimal value: Z = ${_format(result.optimalValue)}');
        buffer.writeln();
        for (var i = 0; i < result.variables.length; i++) {
          buffer.writeln('${varNames[i]} = ${_format(result.variables[i])}');
        }
      }

      state = state.copyWith(result: buffer.toString().trim(), clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'LPP', expression: 'LPP ${state.numVariables}var', result: 'Z = ${_format(result.optimalValue)}');
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Every coefficient must be a valid number.');
    }
  }

  List<String> _resize(List<String> source, int count) => List.generate(count, (i) => i < source.length ? source[i] : '0');

  String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toStringAsPrecision(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

final lppControllerProvider = NotifierProvider<LppController, LppState>(LppController.new);
