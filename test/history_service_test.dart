import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calce/shared/services/history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late HistoryService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    service = container.read(historyServiceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => container.dispose());

  test('adds a calculation at the front of history', () async {
    await service.add(mode: 'Pro', expression: '2+2', result: '4');
    final entry = container.read(historyServiceProvider).single;
    expect(entry.mode, 'Pro');
    expect(entry.expression, '2+2');
    expect(entry.result, '4');
  });

  test('pins an entry without changing its calculation data', () async {
    await service.add(mode: 'Basic', expression: '3*3', result: '9');
    final entry = container.read(historyServiceProvider).single;
    await service.togglePin(entry.id);
    final pinned = container.read(historyServiceProvider).single;
    expect(pinned.isPinned, isTrue);
    expect(pinned.expression, '3*3');
  });

  test('clears only unpinned entries', () async {
    await service.add(mode: 'Basic', expression: '1+1', result: '2');
    final pinnedId = container.read(historyServiceProvider).single.id;
    await service.togglePin(pinnedId);
    await service.add(mode: 'Pro', expression: '2+2', result: '4');
    await service.clearUnpinned();
    final entries = container.read(historyServiceProvider);
    expect(entries, hasLength(1));
    expect(entries.single.id, pinnedId);
  });
}
