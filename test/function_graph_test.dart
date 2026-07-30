import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/graphing/function_graph.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = FunctionGraphEngine();

  test('samples sin(x) in radians and includes the origin', () {
    final segments = engine.sample('sin(x)', minimumX: -1, maximumX: 1, sampleCount: 100);
    expect(segments, isNotEmpty);
    final atOrigin = engine.valueAt('sin(x)', 0);
    expect(atOrigin.y, closeTo(0, 1e-10));
  });

  test('samples exponential and logarithmic expressions', () {
    final exponential = engine.valueAt('exp(x)', 1);
    final logarithm = engine.valueAt('ln(x)', 1);
    expect(exponential.y, closeTo(2.718281828, 1e-6));
    expect(logarithm.y, closeTo(0, 1e-10));
  });

  test('rejects a graph range with no drawable values', () {
    expect(() => engine.sample('ln(x)', minimumX: -5, maximumX: -1), throwsA(isA<MathDomainException>()));
  });
}
