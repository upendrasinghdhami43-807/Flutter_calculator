import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/expression_engine/errors.dart';
import '../../core/expression_engine/evaluator.dart';
import '../../core/expression_engine/parser.dart';

class BasicCalculatorState {
  const BasicCalculatorState({
    this.expression = '',
    this.result = '0',
    this.error,
    this.isExpanded = false,
    this.angleUnit = AngleUnit.degrees,
  });

  final String expression;
  final String result;
  final String? error;
  final bool isExpanded;
  final AngleUnit angleUnit;

  BasicCalculatorState copyWith({
    String? expression,
    String? result,
    String? error,
    bool clearError = false,
    bool? isExpanded,
    AngleUnit? angleUnit,
  }) {
    return BasicCalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      error: clearError ? null : error ?? this.error,
      isExpanded: isExpanded ?? this.isExpanded,
      angleUnit: angleUnit ?? this.angleUnit,
    );
  }
}

class BasicCalculatorController extends Notifier<BasicCalculatorState> {
  @override
  BasicCalculatorState build() => const BasicCalculatorState();

  void input(String value) {
    state = state.copyWith(expression: '${state.expression}$value', clearError: true);
  }

  void clear() => state = BasicCalculatorState(angleUnit: state.angleUnit, isExpanded: state.isExpanded);

  void delete() {
    if (state.expression.isEmpty) return;
    state = state.copyWith(expression: state.expression.substring(0, state.expression.length - 1), clearError: true);
  }

  void toggleExpanded() => state = state.copyWith(isExpanded: !state.isExpanded);

  void cycleAngleUnit() {
    final next = switch (state.angleUnit) {
      AngleUnit.degrees => AngleUnit.radians,
      AngleUnit.radians => AngleUnit.gradians,
      AngleUnit.gradians => AngleUnit.degrees,
    };
    state = state.copyWith(angleUnit: next);
  }

  void evaluate() {
    if (state.expression.trim().isEmpty) return;
    try {
      final node = ExpressionParser().parse(state.expression);
      final value = ExpressionEvaluator(angleUnit: state.angleUnit).evaluate(node);
      if (!value.isFinite) throw const MathDomainException('The result is not a finite number.');
      state = state.copyWith(result: _format(value), clearError: true);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Enter a valid expression.');
    }
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

final basicCalculatorProvider = NotifierProvider<BasicCalculatorController, BasicCalculatorState>(BasicCalculatorController.new);
