import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/numeric_methods/integration_numeric.dart';
import 'package:flutter_calce/core/numeric_methods/root_finding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const roots = RootFinding();
  const integration = NumericIntegration();

  test('finds a bisection root', () {
    final root = roots.bisection((value) => value * value - 4, 0, 3);
    expect(root, closeTo(2, 1e-7));
  });

  test('integrates with Simpson rule', () {
    expect(integration.simpson((value) => value * value, 0, 1), closeTo(1 / 3, 1e-10));
  });

  test('rejects an invalid Simpson interval count', () {
    expect(
      () => integration.simpson((value) => value, 0, 1, intervals: 3),
      throwsA(isA<MathDomainException>()),
    );
  });
}