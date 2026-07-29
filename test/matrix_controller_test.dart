import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calce/features/advanced/matrix/matrix_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MatrixController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    controller = container.read(matrixControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  void populate(List<String> values) {
    for (var index = 0; index < values.length; index++) {
      controller.setValue(index, values[index]);
    }
  }

  test('computes the determinant of a 2×2 matrix', () {
    populate(['4', '7', '2', '6']);
    controller.execute(MatrixOperation.determinant);
    expect(container.read(matrixControllerProvider).result, 'det(A) = 10');
  });

  test('formats the inverse matrix', () {
    populate(['4', '7', '2', '6']);
    controller.execute(MatrixOperation.inverse);
    expect(container.read(matrixControllerProvider).result, contains('A⁻¹'));
    expect(container.read(matrixControllerProvider).result, contains('0.6'));
  });

  test('surfaces an invalid cell as a user-facing error', () {
    controller.setValue(0, 'not a number');
    controller.execute(MatrixOperation.rank);
    expect(container.read(matrixControllerProvider).error, 'Every matrix cell must contain a valid number.');
  });

  test('supports a 1x1 matrix', () {
    controller.setSize(rows: 1, columns: 1);
    controller.setValue(0, '7');
    controller.execute(MatrixOperation.determinant);
    expect(container.read(matrixControllerProvider).result, 'det(A) = 7');
  });

  test('saves A and B then applies an operation between their snapshots', () {
    populate(['1', '2', '3', '4']);
    controller.saveCurrentAs('A');
    populate(['5', '6', '7', '8']);
    controller.saveCurrentAs('B');
    controller.executeSaved(MatrixOperation.add, leftName: 'A', rightName: 'B');
    expect(container.read(matrixControllerProvider).result, contains('A + B'));
    expect(container.read(matrixControllerProvider).result, contains('[6, 8]'));
  });
}
