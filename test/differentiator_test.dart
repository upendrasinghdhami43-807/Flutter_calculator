import 'package:flutter_calce/core/expression_engine/differentiator.dart';
import 'package:flutter_calce/core/expression_engine/evaluator.dart';
import 'package:flutter_calce/core/expression_engine/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = ExpressionParser();
  const differentiator = Differentiator();
  const evaluator = ExpressionEvaluator(angleUnit: AngleUnit.radians);

  double derivativeAt(String expression, double x) {
    final node = differentiator.differentiate(parser.parse(expression));
    return evaluator.evaluate(node, variables: {'x': x});
  }

  test('differentiates a polynomial via the power and sum rules', () {
    // d/dx[x^3 + 2x] = 3x^2 + 2, at x=2 -> 14
    expect(derivativeAt('x^3+2*x', 2), closeTo(14, 1e-8));
  });

  test('differentiates sin(x) via the chain rule to cos(x)', () {
    expect(derivativeAt('sin(x)', 0), closeTo(1, 1e-8));
  });

  test('differentiates a product via the product rule', () {
    // d/dx[x * x] = 2x, at x = 5 -> 10
    expect(derivativeAt('x*x', 5), closeTo(10, 1e-8));
  });
}
