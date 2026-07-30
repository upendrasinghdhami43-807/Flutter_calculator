import '../expression_engine/differentiator.dart';
import '../expression_engine/evaluator.dart';
import '../expression_engine/expression_node.dart';
import '../expression_engine/parser.dart';
import '../numeric_methods/integration_numeric.dart';
import '../numeric_methods/root_finding.dart';

class CalculusEngine {
  const CalculusEngine();

  String derivative(String expression) {
    final node = const Differentiator().differentiate(ExpressionParser().parse(expression));
    return _formatNode(node);
  }

  double derivativeAt(String expression, double x) {
    final node = const Differentiator().differentiate(ExpressionParser().parse(expression));
    return const ExpressionEvaluator(angleUnit: AngleUnit.radians).evaluate(node, variables: {'x': x});
  }

  double integrate(String expression, double lower, double upper, {int intervals = 200}) {
    final node = ExpressionParser().parse(expression);
    const evaluator = ExpressionEvaluator(angleUnit: AngleUnit.radians);
    return const NumericIntegration().simpson((x) => evaluator.evaluate(node, variables: {'x': x}), lower, upper, intervals: intervals);
  }

  double root(String expression, double lower, double upper) {
    final node = ExpressionParser().parse(expression);
    const evaluator = ExpressionEvaluator(angleUnit: AngleUnit.radians);
    return const RootFinding().bisection((x) => evaluator.evaluate(node, variables: {'x': x}), lower, upper);
  }

  String _formatNode(ExpressionNode node) => switch (node) {
    NumberNode(:final value) => _formatNumber(value),
    VariableNode(:final name) => name,
    UnaryOpNode(:final operatorSymbol, :final operand) => '$operatorSymbol(${_formatNode(operand)})',
    BinaryOpNode(:final operatorSymbol, :final left, :final right) => '(${_formatNode(left)} $operatorSymbol ${_formatNode(right)})',
    FunctionCallNode(:final name, :final arguments) => '$name(${arguments.map(_formatNode).join(', ')})',
    FactorialNode(:final operand) => '${_formatNode(operand)}!',
  };

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
