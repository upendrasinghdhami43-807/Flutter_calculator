import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_entry.dart';
import '../services/history_service.dart';

/// Shared calculation-history panel, opened as a modal bottom sheet from any
/// mode. Lets the user re-use a past expression, pin favorites, or delete
/// entries.
class HistoryPanel extends ConsumerWidget {
  const HistoryPanel({required this.modeFilter, this.onSelect, super.key});

  /// When non-null, only entries logged from this mode are shown (e.g.
  /// `'Pro'`). When null, every mode's history is shown.
  final String? modeFilter;
  final ValueChanged<HistoryEntry>? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEntries = ref.watch(historyServiceProvider);
    final entries = modeFilter == null ? allEntries : allEntries.where((e) => e.mode == modeFilter).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text('History', style: Theme.of(context).textTheme.titleLarge)),
                  TextButton(
                    onPressed: () => ref.read(historyServiceProvider.notifier).clearUnpinned(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No calculations yet.'))
                  : ListView.builder(
                      controller: controller,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          title: Text(entry.expression, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('= ${entry.result}  ·  ${entry.mode}'),
                          leading: IconButton(
                            icon: Icon(entry.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                            onPressed: () => ref.read(historyServiceProvider.notifier).togglePin(entry.id),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref.read(historyServiceProvider.notifier).remove(entry.id),
                          ),
                          onTap: onSelect == null
                              ? null
                              : () {
                                  onSelect!(entry);
                                  Navigator.of(context).pop();
                                },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> show(BuildContext context, {String? modeFilter, ValueChanged<HistoryEntry>? onSelect}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HistoryPanel(modeFilter: modeFilter, onSelect: onSelect),
    );
  }
}
