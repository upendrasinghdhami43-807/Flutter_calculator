import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calce/features/advanced/equation/equation_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late EquationController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    controller = container.read(equationControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('solves a quadratic through the exact quadratic path', () {
    controller.setPolynomialCoefficient(0, '1');
    controller.setPolynomialCoefficient(1, '0');
    controller.setPolynomialCoefficient(2, '-4');
    controller.solve();
    final result = container.read(equationControllerProvider).result!;
    expect(result, contains('x1 = 2'));
    expect(result, contains('x2 = -2'));
  });

  test('solves a unique two-variable linear system', () {
    controller.setTool(EquationTool.system);
    for (final entry in <String>['2', '1', '1', '-1'].asMap().entries) {
      controller.setSystemCoefficient(entry.key, entry.value);
    }
    controller.setSystemConstant(0, '5');
    controller.setSystemConstant(1, '1');
    controller.solve();
    expect(container.read(equationControllerProvider).result, 'x1 = 2\nx2 = 1');
  });

  test('reports a non-numeric coefficient as a user-facing error', () {
    controller.setPolynomialCoefficient(0, 'abc');
    controller.solve();
    expect(container.read(equationControllerProvider).error, 'Every coefficient must contain a valid number.');
  });
}
