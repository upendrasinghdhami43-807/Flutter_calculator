import 'package:flutter/material.dart';

/// A focused numeric-entry workflow for dense engineering forms. The user
/// enters one value with the built-in keypad, taps Next, and is advanced to
/// the following coefficient or matrix cell. Finish commits the final value.
/// Features: progress bar, animated transitions, skip button, keyboard support.
class GuidedNumberEntrySheet extends StatefulWidget {
  const GuidedNumberEntrySheet({
    required this.title,
    required this.labels,
    required this.values,
    required this.onValue,
    this.onFinished,
    super.key,
  });

  final String title;
  final List<String> labels;
  final List<String> values;
  final void Function(int index, String value) onValue;
  final VoidCallback? onFinished;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<String> labels,
    required List<String> values,
    required void Function(int index, String value) onValue,
    VoidCallback? onFinished,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GuidedNumberEntrySheet(title: title, labels: labels, values: values, onValue: onValue, onFinished: onFinished),
    );
  }

  @override
  State<GuidedNumberEntrySheet> createState() => _GuidedNumberEntrySheetState();
}

class _GuidedNumberEntrySheetState extends State<GuidedNumberEntrySheet> with SingleTickerProviderStateMixin {
  late final List<String> _values;
  late final TextEditingController _controller;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _values = List<String>.from(widget.values);
    _controller = TextEditingController(text: _values.firstOrNull ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitCurrent() {
    _values[_index] = _controller.text;
    widget.onValue(_index, _controller.text);
  }

  void _next() {
    _commitCurrent();
    if (_index == widget.labels.length - 1) {
      widget.onFinished?.call();
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _controller.text = _values[_index];
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _previous() {
    _commitCurrent();
    if (_index == 0) return;
    setState(() {
      _index--;
      _controller.text = _values[_index];
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _skip() {
    // Move to next without changing value
    if (_index == widget.labels.length - 1) {
      widget.onFinished?.call();
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _controller.text = _values[_index];
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _append(String value) {
    final current = _controller.text;
    if (value == '.' && current.contains('.')) return;
    if (value == '-' && current.isNotEmpty) return;
    _controller.text = '$current$value';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == widget.labels.length - 1;
    final progress = ((_index + 1) / widget.labels.length);
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_index + 1} / ${widget.labels.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 14),
              // Current label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.labels[_index],
                  key: ValueKey(_index),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Value input
              TextField(
                controller: _controller,
                readOnly: true,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colors.surfaceContainerLowest,
                ),
              ),
              const SizedBox(height: 10),
              // Number pad
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 2.0,
                children: [
                  for (final key in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '-'])
                    _NumPadKey(label: key, onTap: () => _append(key)),
                  _NumPadActionKey(label: 'Clear', onTap: () => _controller.clear()),
                  _NumPadActionKey(label: 'Skip', onTap: _skip),
                  _NumPadActionKey(label: '⌫', onTap: () {
                    final text = _controller.text;
                    if (text.isEmpty) return;
                    _controller.text = text.substring(0, text.length - 1);
                  }),
                ],
              ),
              const SizedBox(height: 10),
              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous
                  if (_index > 0)
                    OutlinedButton.icon(
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Prev', style: TextStyle(fontSize: 12)),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // Next / Finish
                  FilledButton.icon(
                    onPressed: _next,
                    icon: Icon(isLast ? Icons.check : Icons.arrow_forward, size: 16),
                    label: Text(isLast ? 'Finish' : 'Next', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumPadKey extends StatelessWidget {
  const _NumPadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _NumPadActionKey extends StatelessWidget {
  const _NumPadActionKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
