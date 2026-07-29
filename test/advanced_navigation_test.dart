import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_calce/main.dart';

void main() {
  testWidgets('Home pushes Advanced tools and the back stack returns to the workbench', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SuperCalcApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('Engineering workbench'), findsOneWidget);

    await tester.tap(find.text('Matrix'));
    await tester.pumpAndSettle();
    expect(find.text('Matrix A'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Engineering workbench'), findsOneWidget);
  });
}
