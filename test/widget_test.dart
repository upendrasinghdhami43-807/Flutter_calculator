import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_calce/features/basic_calculator/basic_calculator_screen.dart';

void main() {
  Future<void> pumpCalculator(WidgetTester tester) {
    return tester.pumpWidget(const ProviderScope(child: MaterialApp(home: BasicCalculatorScreen())));
  }

  testWidgets('reveals the scientific keypad layer', (tester) async {
    await pumpCalculator(tester);

    await tester.tap(find.text('More'));
    await tester.pump();

    expect(find.text('sin'), findsOneWidget);
    expect(find.text('Deg'), findsOneWidget);
  });
}