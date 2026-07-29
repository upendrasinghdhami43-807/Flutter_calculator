import '../expression_engine/errors.dart';
import '../expression_engine/evaluator.dart';
import '../expression_engine/parser.dart';

class FunctionGraphPoint {
  const FunctionGraphPoint(this.x, this.y);

  final double x;
  final double y;
}

/// Samples a scalar expression y = f(x) using SuperCalc's shared parser and
/// evaluator. Discontinuous or invalid ranges are split into independent
/// segments so vertical asymptotes are never rendered as false connections.
class FunctionGraphEngine {
  const FunctionGraphEngine({this.angleUnit = AngleUnit.radians});

  final AngleUnit angleUnit;

  List<List<FunctionGraphPoint>> sample(
    String expression, {
    double minimumX = -12,
    double maximumX = 12,
    int sampleCount = 960,
  }) {
    if (sampleCount < 2 || minimumX >= maximumX) {
      throw const MathDomainException('Choose a valid graph range and at least two samples.');
    }
    final node = ExpressionParser().parse(expression);
    final evaluator = ExpressionEvaluator(angleUnit: angleUnit);
    final segments = <List<FunctionGraphPoint>>[];
    var segment = <FunctionGraphPoint>[];
    FunctionGraphPoint? previous;
    for (var index = 0; index <= sampleCount; index++) {
      final x = minimumX + (maximumX - minimumX) * index / sampleCount;
      try {
        final y = evaluator.evaluate(node, variables: {'x': x});
        final isValid = y.isFinite && y.abs() < 10000;
        final isJump = previous != null && (y - previous.y).abs() > 120;
        if (!isValid || isJump) {
          if (segment.length > 1) segments.add(segment);
          segment = <FunctionGraphPoint>[];
          previous = null;
          continue;
        }
        final point = FunctionGraphPoint(x, y);
        segment.add(point);
        previous = point;
      } on MathException {
        if (segment.length > 1) segments.add(segment);
        segment = <FunctionGraphPoint>[];
        previous = null;
      }
    }
    if (segment.length > 1) segments.add(segment);
    if (segments.isEmpty) {
      throw const MathDomainException('The expression has no drawable values in this graph range.');
    }
    return segments;
  }

  FunctionGraphPoint valueAt(String expression, double x) {
    final node = ExpressionParser().parse(expression);
    final y = ExpressionEvaluator(angleUnit: angleUnit).evaluate(node, variables: {'x': x});
    if (!y.isFinite) throw const MathDomainException('The expression is not finite at this x coordinate.');
    return FunctionGraphPoint(x, y);
  }
}
