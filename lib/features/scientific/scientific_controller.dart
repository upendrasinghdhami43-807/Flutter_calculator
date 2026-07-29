import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/expression_engine/errors.dart';
import '../../core/expression_engine/evaluator.dart';
import '../../core/expression_engine/parser.dart';
import '../../shared/services/history_service.dart';

/// The active top-level calculation mode for Pro (Scientific) mode. `comp`
/// is general-purpose calculation (covers trig/log/power/factorial/
/// combinatorics/fractions via the shared expression engine); `complex`
/// keeps the same input flow but formats results using the `Complex`
/// helper type. Matrix/Vector/Statistics/Base-N are intentionally not
/// duplicated here — `ModeSelectorSheet` routes to the shared Advanced-mode
/// screens for those, per the "don't duplicate solver logic" requirement.
enum ProMode { comp, complex }

class ProCalculatorState {
  const ProCalculatorState({
    this.expression = '',
    this.result = '0',
    this.error,
    this.shiftActive = false,
    this.alphaActive = false,
    this.angleUnit = AngleUnit.degrees,
    this.mode = ProMode.comp,
    this.memory = 0,
    this.ans = 0,
    this.variables = const {},
  });

  final String expression;
  final String result;
  final String? error;
  final bool shiftActive;
  final bool alphaActive;
  final AngleUnit angleUnit;
  final ProMode mode;
  final double memory;
  final double ans;
  final Map<String, double> variables;

  ProCalculatorState copyWith({
    String? expression,
    String? result,
    String? error,
    bool clearError = false,
    bool? shiftActive,
    bool? alphaActive,
    AngleUnit? angleUnit,
    ProMode? mode,
    double? memory,
    double? ans,
    Map<String, double>? variables,
  }) {
    return ProCalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      error: clearError ? null : error ?? this.error,
      shiftActive: shiftActive ?? this.shiftActive,
      alphaActive: alphaActive ?? this.alphaActive,
      angleUnit: angleUnit ?? this.angleUnit,
      mode: mode ?? this.mode,
      memory: memory ?? this.memory,
      ans: ans ?? this.ans,
      variables: variables ?? this.variables,
    );
  }
}

class ScientificController extends Notifier<ProCalculatorState> {
  @override
  ProCalculatorState build() => const ProCalculatorState();

  void input(String value) {
    state = state.copyWith(expression: '${state.expression}$value', clearError: true, shiftActive: false, alphaActive: false);
  }

  void toggleShift() => state = state.copyWith(shiftActive: !state.shiftActive, alphaActive: false);

  void toggleAlpha() => state = state.copyWith(alphaActive: !state.alphaActive, shiftActive: false);

  void resetModifiers() => state = state.copyWith(shiftActive: false, alphaActive: false);

  void clearAll() =>
      state = ProCalculatorState(angleUnit: state.angleUnit, mode: state.mode, memory: state.memory, ans: state.ans, variables: state.variables);

  void delete() {
    if (state.expression.isEmpty) return;
    state = state.copyWith(expression: state.expression.substring(0, state.expression.length - 1), clearError: true);
  }

  void cycleAngleUnit() {
    final next = switch (state.angleUnit) {
      AngleUnit.degrees => AngleUnit.radians,
      AngleUnit.radians => AngleUnit.gradians,
      AngleUnit.gradians => AngleUnit.degrees,
    };
    state = state.copyWith(angleUnit: next);
  }

  void setMode(ProMode mode) => state = state.copyWith(mode: mode);

  void memoryAdd() => state = state.copyWith(memory: state.memory + _lastResultAsDouble());

  void memorySubtract() => state = state.copyWith(memory: state.memory - _lastResultAsDouble());

  void memoryRecall() => input(_format(state.memory));

  void memoryClear() => state = state.copyWith(memory: 0);

  void storeVariable(String name) => state = state.copyWith(variables: {...state.variables, name.toLowerCase(): _lastResultAsDouble()});

  void recallVariable(String name) => input(_format(state.variables[name.toLowerCase()] ?? 0));

  double _lastResultAsDouble() => double.tryParse(state.result) ?? 0;

  void evaluate() {
    if (state.expression.trim().isEmpty) return;
    try {
      final node = ExpressionParser().parse(state.expression);
      final variables = {...state.variables, 'ans': state.ans};
      final value = ExpressionEvaluator(angleUnit: state.angleUnit).evaluate(node, variables: variables);
      if (!value.isFinite) throw const MathDomainException('The result is not a finite number.');
      final formatted = _format(value);
      state = state.copyWith(result: formatted, ans: value, clearError: true);
      ref.read(historyServiceProvider.notifier).add(mode: 'Pro', expression: state.expression, result: formatted);
    } on MathException catch (error) {
      state = state.copyWith(error: error.message);
    } on FormatException {
      state = state.copyWith(error: 'Enter a valid expression.');
    }
  }

  String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

final scientificControllerProvider = NotifierProvider<ScientificController, ProCalculatorState>(ScientificController.new);
