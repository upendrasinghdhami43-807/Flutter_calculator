import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculus/calculus_engine.dart';
import '../../../core/expression_engine/errors.dart';
import '../../../shared/services/history_service.dart';

enum CalculusTool { derivative, integral, root, limit }

class CalculusState {
  const CalculusState({
    this.tool = CalculusTool.derivative,
    this.expression = 'x^2',
    this.point = '1',
    this.lowerBound = '0',
    this.upperBound = '1',
    this.limitApproach = '0',
    this.result,
    this.error,
  });

  final CalculusTool tool;
  final String expression;
  final String point;
  final String lowerBound;
  final String upperBound;
  final String limitApproach;
  final String? result;
  final String? error;

  CalculusState copyWith({
    CalculusTool? tool,
    String? expression,
    String? point,
    String? lowerBound,
    String? upperBound,
    String? limitApproach,
    String? result,
    String? error,
    bool clearOutput = false,
    bool clearError = false,
  }) =>
      CalculusState(
        tool: tool ?? this.tool,
        expression: expression ?? this.expression,
        point: point ?? this.point,
        lowerBound: lowerBound ?? this.lowerBound,
        upperBound: upperBound ?? this.upperBound,
        limitApproach: limitApproach ?? this.limitApproach,
        result: clearOutput ? null : result ?? this.result,
        error: clearError ? null : error ?? this.error,
      );
}

class CalculusController extends Notifier<CalculusState> {
  @override
  CalculusState build() => const CalculusState();

  final _engine = const CalculusEngine();

  void setTool(CalculusTool tool) => state = state.copyWith(tool: tool, clearOutput: true, clearError: true);
  void setExpression(String value) => state = state.copyWith(expression: value, clearOutput: true, clearError: true);
  void setPoint(String value) => state = state.copyWith(point: value, clearOutput: true, clearError: true);
  void setLowerBound(String value) => state = state.copyWith(lowerBound: value, clearOutput: true, clearError: true);
  void setUpperBound(String value) => state = state.copyWith(upperBound: value, clearOutput: true, clearError: true);
  void setLimitApproach(String value) => state = state.copyWith(limitApproach: value, clearOutput: true, clearError: true);

  void compute() {
    try {
      final result = switch (state.tool) {
        CalculusTool.derivative => _computeDerivative(),
        CalculusTool.integral => _computeIntegral(),
        CalculusTool.root => _computeRoot(),
        CalculusTool.limit => _computeLimit(),
      };
      state = state.copyWith(result: result, clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'Calculus', expression: '${state.tool.name}: ${state.expression}', result: result);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Enter valid numbers for all parameters.');
    }
  }

  String _computeDerivative() {
    final symbolic = _engine.derivative(state.expression);
    final x = double.parse(state.point.trim());
    final numerical = _engine.derivativeAt(state.expression, x);
    return 'Symbolic derivative:\nd/dx [${state.expression}] = $symbolic\n\nAt x = ${_format(x)}:\nf\'(${_format(x)}) = ${_format(numerical)}';
  }

  String _computeIntegral() {
    final lower = double.parse(state.lowerBound.trim());
    final upper = double.parse(state.upperBound.trim());
    final value = _engine.integrate(state.expression, lower, upper);
    return 'Definite integral:\n∫₍${_format(lower)}₎^₍${_format(upper)}₎ [${state.expression}] dx\n\n= ${_format(value)}\n\nMethod: Simpson\'s 1/3 rule (200 intervals)';
  }

  String _computeRoot() {
    final lower = double.parse(state.lowerBound.trim());
    final upper = double.parse(state.upperBound.trim());
    final root = _engine.root(state.expression, lower, upper);
    return 'Root of f(x) = ${state.expression}\nin interval [${_format(lower)}, ${_format(upper)}]:\n\nx ≈ ${_format(root)}\n\nMethod: Bisection (tolerance = 1e-10)';
  }

  String _computeLimit() {
    final approach = double.parse(state.limitApproach.trim());
    final h = 1e-8;
    // Left and right limits
    final leftValues = <double>[];
    final rightValues = <double>[];
    for (var i = 1; i <= 5; i++) {
      final delta = h * i;
      try {
        leftValues.add(_engine.integrate(state.expression, approach - delta, approach - delta + 1e-12) * 1e12);
      } catch (_) {
        // Skip invalid evaluations
      }
      try {
        rightValues.add(_engine.integrate(state.expression, approach + delta, approach + delta + 1e-12) * 1e12);
      } catch (_) {
        // Skip invalid evaluations
      }
    }

    // Use numerical differentiation approach for limit
    try {
      // Evaluate f(x) at points approaching from both sides
      final leftLimit = _evaluateNear(approach - h);
      final rightLimit = _evaluateNear(approach + h);
      final directValue = _evaluateNear(approach);

      final buffer = StringBuffer();
      buffer.writeln('Limit of f(x) = ${state.expression}');
      buffer.writeln('as x → ${_format(approach)}:');
      buffer.writeln();

      if (directValue.isFinite) {
        buffer.writeln('f(${_format(approach)}) = ${_format(directValue)}');
      } else {
        buffer.writeln('f(${_format(approach)}) is undefined');
      }

      if (leftLimit.isFinite) {
        buffer.writeln('Left limit: ${_format(leftLimit)}');
      }
      if (rightLimit.isFinite) {
        buffer.writeln('Right limit: ${_format(rightLimit)}');
      }

      if (leftLimit.isFinite && rightLimit.isFinite) {
        if ((leftLimit - rightLimit).abs() < 1e-4) {
          buffer.writeln('\nlim f(x) = ${_format((leftLimit + rightLimit) / 2)}');
        } else {
          buffer.writeln('\nLimit does not exist (left ≠ right)');
        }
      }

      return buffer.toString().trim();
    } catch (_) {
      return 'Could not compute the limit numerically.';
    }
  }

  double _evaluateNear(double x) {
    // Use the calculus engine's integrate trick to evaluate a point
    // Actually, we can just parse and evaluate directly
    final result = _engine.integrate(state.expression, x, x + 1e-12) / 1e-12;
    return result;
  }

  String _format(double value) {
    if (!value.isFinite) return value.toString();
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

final calculusControllerProvider = NotifierProvider<CalculusController, CalculusState>(CalculusController.new);
