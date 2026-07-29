import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/expression_engine/evaluator.dart';
import 'package:flutter_calce/core/expression_engine/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluator = ExpressionEvaluator();
  final parser = ExpressionParser();

  test('honors arithmetic precedence', () {
    expect(evaluator.evaluate(parser.parse('2+3*4')), 14);
  });

  test('supports implicit multiplication and degree trigonometry', () {
    expect(evaluator.evaluate(parser.parse('2pi')), closeTo(6.283185307, 1e-8));
    expect(evaluator.evaluate(parser.parse('sin(90)')), closeTo(1, 1e-10));
  });

  test('reports division by zero as a typed domain error', () {
    expect(() => evaluator.evaluate(parser.parse('4/0')), throwsA(isA<MathDomainException>()));
  });
}
