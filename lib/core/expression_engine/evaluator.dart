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
      FunctionCallNode(:final name, :final arguments) =>
        _function(name, arguments.map((argument) => evaluate(argument, variables: variables)).toList()),
      FactorialNode(:final operand) => _factorial(evaluate(operand, variables: variables)),
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

  double _function(String name, List<double> arguments) {
    if (arguments.length == 1) {
      final value = arguments[0];
      return switch (name) {
        'sin' => math.sin(_toRadians(value)),
        'cos' => math.cos(_toRadians(value)),
        'tan' => math.tan(_toRadians(value)),
        'asin' => _fromRadians(_inverseDomain(math.asin, value, 'asin')),
        'acos' => _fromRadians(_inverseDomain(math.acos, value, 'acos')),
        'atan' => _fromRadians(math.atan(value)),
        'sec' => _sec(value),
        'cosec' => _cosec(value),
        'cot' => _cot(value),
        'sqrt' => _squareRoot(value),
        'log' => _log10(value),
        'ln' => _naturalLog(value),
        'abs' => value.abs(),
        'exp' => math.exp(value),
        _ => throw MathEvaluationException('Unknown function: $name'),
      };
    }
    if (arguments.length == 2) {
      return switch (name) {
        'npr' => _permutations(arguments[0], arguments[1]),
        'ncr' => _combinations(arguments[0], arguments[1]),
        'root' => _nthRoot(arguments[0], arguments[1]),
        'logb' => _logBase(arguments[0], arguments[1]),
        _ => throw MathEvaluationException('Unknown function: $name'),
      };
    }
    throw MathEvaluationException('$name does not accept ${arguments.length} arguments.');
  }

  double _sec(double value) {
    final cosine = math.cos(_toRadians(value));
    if (cosine.abs() < 1e-12) throw const MathDomainException('sec is undefined at this angle.');
    return 1 / cosine;
  }

  double _cosec(double value) {
    final sine = math.sin(_toRadians(value));
    if (sine.abs() < 1e-12) throw const MathDomainException('cosec is undefined at this angle.');
    return 1 / sine;
  }

  double _cot(double value) {
    final sine = math.sin(_toRadians(value));
    if (sine.abs() < 1e-12) throw const MathDomainException('cot is undefined at this angle.');
    return math.cos(_toRadians(value)) / sine;
  }

  double _factorial(double value) {
    if (value < 0 || value != value.roundToDouble()) {
      throw const MathDomainException('Factorial requires a non-negative whole number.');
    }
    var result = 1.0;
    for (var i = 2; i <= value; i++) {
      result *= i;
    }
    return result;
  }

  double _permutations(double n, double r) {
    _validateCombinatoric(n, r);
    return _factorial(n) / _factorial(n - r);
  }

  double _combinations(double n, double r) {
    _validateCombinatoric(n, r);
    return _factorial(n) / (_factorial(r) * _factorial(n - r));
  }

  void _validateCombinatoric(double n, double r) {
    if (r < 0 || r > n) throw const MathDomainException('r must be between 0 and n.');
  }

  double _nthRoot(double n, double value) {
    if (n == 0) throw const MathDomainException('Root degree cannot be zero.');
    if (value < 0 && n % 2 == 0) {
      throw const MathDomainException('Even root of a negative number is not real.');
    }
    final sign = value < 0 ? -1.0 : 1.0;
    return sign * math.pow(value.abs(), 1 / n);
  }

  double _logBase(double base, double value) {
    if (base <= 0 || base == 1) throw const MathDomainException('Log base must be positive and not equal to 1.');
    if (value <= 0) throw const MathDomainException('Logarithm requires a positive value.');
    return math.log(value) / math.log(base);
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
