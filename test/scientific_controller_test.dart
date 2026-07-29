import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calce/features/scientific/scientific_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late ScientificController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    controller = container.read(scientificControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('evaluates a scientific expression and records Ans', () {
    controller.input('2^3+1');
    controller.evaluate();
    final state = container.read(scientificControllerProvider);
    expect(state.result, '9');
    expect(state.ans, 9);
  });

  test('SHIFT toggles the secondary function for the next key press', () {
    controller.toggleShift();
    controller.input('asin(');
    expect(container.read(scientificControllerProvider).shiftActive, isFalse);
    expect(container.read(scientificControllerProvider).expression, 'asin(');
  });

  test('memory add/recall round-trips through the M register', () {
    controller.input('5');
    controller.evaluate();
    controller.memoryAdd();
    controller.clearAll();
    controller.memoryRecall();
    expect(container.read(scientificControllerProvider).expression, '5');
    expect(container.read(scientificControllerProvider).memory, 5);
  });

  test('captures invalid calculation errors in state', () {
    controller.input('sqrt(-1)');
    controller.evaluate();
    expect(container.read(scientificControllerProvider).error, isNotNull);
  });
}
