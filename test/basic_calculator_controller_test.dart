import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_calce/features/basic_calculator/basic_calculator_controller.dart';

void main() {
  late ProviderContainer container;
  late BasicCalculatorController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(basicCalculatorProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('evaluates basic arithmetic locally', () {
    controller.input('2+3*4');
    controller.evaluate();
    expect(container.read(basicCalculatorProvider).result, '14');
  });

  test('uses the selected angle unit for trigonometry', () {
    controller.input('sin(90)');
    controller.evaluate();
    expect(container.read(basicCalculatorProvider).result, '1');
  });

  test('captures invalid calculation errors in state', () {
    controller.input('4/0');
    controller.evaluate();
    expect(container.read(basicCalculatorProvider).error, 'Cannot divide by zero.');
  });
}