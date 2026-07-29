import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

/// Persists calculation history (shared by Basic, Pro, and Advanced modes)
/// using `shared_preferences` as a simple local JSON-encoded list.
///
/// v1.0 originally specified Drift/SQLite for this service. That would add a
/// code-generation build step (`build_runner`) for a single flat list of
/// records, which is not warranted at this scale. `shared_preferences` gives
/// the same durability guarantee (persists across app restarts) with far
/// less machinery. This consolidation is called out in the phase report.
class HistoryService extends Notifier<List<HistoryEntry>> {
  static const _storageKey = 'supercalc.history.v1';
  static const _maxEntries = 200;

  @override
  List<HistoryEntry> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? const [];
    state = raw
        .map((entry) => HistoryEntry.fromJson(jsonDecode(entry) as Map<String, Object?>))
        .toList(growable: false);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state.map((entry) => jsonEncode(entry.toJson())).toList());
  }

  Future<void> add({required String mode, required String expression, required String result}) async {
    final entry = HistoryEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      mode: mode,
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    );
    final updated = [entry, ...state];
    state = updated.length > _maxEntries ? updated.sublist(0, _maxEntries) : updated;
    await _persist();
  }

  Future<void> togglePin(String id) async {
    state = [
      for (final entry in state)
        if (entry.id == id) entry.copyWith(isPinned: !entry.isPinned) else entry,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((entry) => entry.id != id).toList(growable: false);
    await _persist();
  }

  Future<void> clearUnpinned() async {
    state = state.where((entry) => entry.isPinned).toList(growable: false);
    await _persist();
  }
}

final historyServiceProvider = NotifierProvider<HistoryService, List<HistoryEntry>>(HistoryService.new);
