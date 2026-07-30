import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/expression_engine/errors.dart';
import '../../../shared/services/history_service.dart';
import 'polynomial_solver.dart';
import 'system_solver.dart';

enum EquationTool { polynomial, system }

class EquationState {
  const EquationState({
    this.tool = EquationTool.polynomial,
    this.polynomialDegree = 2,
    this.systemSize = 2,
    this.polynomialCoefficients = const ['', '', ''],
    this.systemCoefficients = const ['', '', '', ''],
    this.systemConstants = const ['', ''],
    this.result,
    this.error,
  });

  final EquationTool tool;
  final int polynomialDegree;
  final int systemSize;
  final List<String> polynomialCoefficients;
  final List<String> systemCoefficients;
  final List<String> systemConstants;
  final String? result;
  final String? error;

  EquationState copyWith({
    EquationTool? tool,
    int? polynomialDegree,
    int? systemSize,
    List<String>? polynomialCoefficients,
    List<String>? systemCoefficients,
    List<String>? systemConstants,
    String? result,
    String? error,
    bool clearOutput = false,
    bool clearError = false,
  }) => EquationState(
    tool: tool ?? this.tool,
    polynomialDegree: polynomialDegree ?? this.polynomialDegree,
    systemSize: systemSize ?? this.systemSize,
    polynomialCoefficients: polynomialCoefficients ?? this.polynomialCoefficients,
    systemCoefficients: systemCoefficients ?? this.systemCoefficients,
    systemConstants: systemConstants ?? this.systemConstants,
    result: clearOutput ? null : result ?? this.result,
    error: clearError ? null : error ?? this.error,
  );
}

class EquationController extends Notifier<EquationState> {
  @override
  EquationState build() => const EquationState();

  void setTool(EquationTool tool) => state = state.copyWith(tool: tool, clearOutput: true, clearError: true);

  void setPolynomialDegree(int degree) {
    state = state.copyWith(polynomialDegree: degree, polynomialCoefficients: _resize(state.polynomialCoefficients, degree + 1), clearOutput: true, clearError: true);
  }

  void setSystemSize(int size) {
    state = state.copyWith(
      systemSize: size,
      systemCoefficients: _resize(state.systemCoefficients, size * size),
      systemConstants: _resize(state.systemConstants, size),
      clearOutput: true,
      clearError: true,
    );
  }

  void setPolynomialCoefficient(int index, String value) {
    final values = List<String>.from(state.polynomialCoefficients)..[index] = value;
    state = state.copyWith(polynomialCoefficients: values, clearOutput: true, clearError: true);
  }

  void setSystemCoefficient(int index, String value) {
    final values = List<String>.from(state.systemCoefficients)..[index] = value;
    state = state.copyWith(systemCoefficients: values, clearOutput: true, clearError: true);
  }

  void setSystemConstant(int index, String value) {
    final values = List<String>.from(state.systemConstants)..[index] = value;
    state = state.copyWith(systemConstants: values, clearOutput: true, clearError: true);
  }

  void solve() {
    try {
      final result = switch (state.tool) {
        EquationTool.polynomial => _solvePolynomial(),
        EquationTool.system => _solveSystem(),
      };
      state = state.copyWith(result: result, clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'Equation', expression: state.tool.name, result: result);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Every coefficient must contain a valid number.');
    }
  }

  String _solvePolynomial() {
    final coefficients = state.polynomialCoefficients.map((value) => double.parse(value.trim())).toList();
    final solver = const PolynomialEquationSolver();
    return solver.formatRoots(solver.solve(coefficients));
  }

  String _solveSystem() {
    final size = state.systemSize;
    final coefficients = List.generate(size, (row) => List.generate(size, (column) => double.parse(state.systemCoefficients[row * size + column].trim())));
    final constants = state.systemConstants.map((value) => double.parse(value.trim())).toList();
    return const SystemEquationSolver().solveAndFormat(coefficients, constants);
  }

  List<String> _resize(List<String> source, int count) => List.generate(count, (index) => index < source.length ? source[index] : '');
}

final equationControllerProvider = NotifierProvider<EquationController, EquationState>(EquationController.new);
