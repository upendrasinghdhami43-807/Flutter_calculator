import 'dart:math' as math;

import 'errors.dart';
import 'expression_node.dart';

enum AngleUnit { degrees, radians, gradians }

class ExpressionEvaluator {
  const ExpressionEvaluator({this.angleUnit = AngleUnit.degrees});

  final AngleUnit angleUnit;

  double evaluate(ExpressionNode node, {Map<String, double> variables = const {}}) {
    return switch (node) {
      NumberNode(:final value) => value,
      VariableNode(:final name) => _variableValue(name, variables),
      UnaryOpNode(:final operatorSymbol, :final operand) => _unary(operatorSymbol, evaluate(operand, variables: variables)),
      BinaryOpNode(:final operatorSymbol, :final left, :final right) =>
        _binary(operatorSymbol, evaluate(left, variables: variables), evaluate(right, variables: variables)),
      FunctionCallNode(:final name, :final argument) => _function(name, evaluate(argument, variables: variables)),
    };
  }

  double _variableValue(String name, Map<String, double> variables) {
    if (name == 'pi') return math.pi;
    if (name == 'e') return math.e;
    final value = variables[name];
    if (value == null) throw MathEvaluationException('Unknown variable: $name');
    return value;
  }

  double _unary(String operatorSymbol, double value) => switch (operatorSymbol) {
    '-' => -value,
    '+' => value,
    _ => throw MathEvaluationException('Unsupported unary operator: $operatorSymbol'),
  };

  double _binary(String operatorSymbol, double left, double right) {
    if ((operatorSymbol == '/' || operatorSymbol == '%') && right == 0) {
      throw const MathDomainException('Cannot divide by zero.');
    }
    return switch (operatorSymbol) {
      '+' => left + right,
      '-' => left - right,
      '*' => left * right,
      '/' => left / right,
      '%' => left % right,
      '^' => math.pow(left, right).toDouble(),
      _ => throw MathEvaluationException('Unsupported operator: $operatorSymbol'),
    };
  }

  double _function(String name, double value) {
    return switch (name) {
      'sin' => math.sin(_toRadians(value)),
      'cos' => math.cos(_toRadians(value)),
      'tan' => math.tan(_toRadians(value)),
      'asin' => _fromRadians(_inverseDomain(math.asin, value, 'asin')),
      'acos' => _fromRadians(_inverseDomain(math.acos, value, 'acos')),
      'atan' => _fromRadians(math.atan(value)),
      'sqrt' => _squareRoot(value),
      'log' => _log10(value),
      'ln' => _naturalLog(value),
      'abs' => value.abs(),
      'exp' => math.exp(value),
      _ => throw MathEvaluationException('Unknown function: $name'),
    };
  }

  double _squareRoot(double value) {
    if (value < 0) throw const MathDomainException('Square root requires a non-negative value.');
    return math.sqrt(value);
  }

  double _naturalLog(double value) {
    if (value <= 0) throw const MathDomainException('Logarithm requires a positive value.');
    return math.log(value);
  }

  double _log10(double value) => _naturalLog(value) / math.ln10;

  double _inverseDomain(double Function(double) function, double value, String name) {
    if (value < -1 || value > 1) throw MathDomainException('$name requires a value from -1 to 1.');
    return function(value);
  }

  double _toRadians(double value) => switch (angleUnit) {
    AngleUnit.degrees => value * math.pi / 180,
    AngleUnit.radians => value,
    AngleUnit.gradians => value * math.pi / 200,
  };

  double _fromRadians(double value) => switch (angleUnit) {
    AngleUnit.degrees => value * 180 / math.pi,
    AngleUnit.radians => value,
    AngleUnit.gradians => value * 200 / math.pi,
  };
}
