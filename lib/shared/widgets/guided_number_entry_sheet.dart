import 'package:flutter/material.dart';

/// A focused numeric-entry workflow for dense engineering forms. The user
/// enters one value with the built-in keypad, taps Next, and is advanced to
/// the following coefficient or matrix cell. Finish commits the final value.
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

class _GuidedNumberEntrySheetState extends State<GuidedNumberEntrySheet> {
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge)),
                  Text('${_index + 1} / ${widget.labels.length}', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 16),
              Text(widget.labels[_index], style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                readOnly: true,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.9,
                children: [
                  for (final key in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '-'])
                    OutlinedButton(onPressed: () => _append(key), child: Text(key, style: const TextStyle(fontSize: 18))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(tooltip: 'Backspace', onPressed: () {
                    final text = _controller.text;
                    if (text.isEmpty) return;
                    _controller.text = text.substring(0, text.length - 1);
                  }, icon: const Icon(Icons.backspace_outlined)),
                  TextButton(onPressed: () => _controller.clear(), child: const Text('Clear')),
                  const Spacer(),
                  OutlinedButton.icon(onPressed: _index == 0 ? null : _previous, icon: const Icon(Icons.arrow_back), label: const Text('Previous')),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: _next, icon: Icon(isLast ? Icons.check : Icons.arrow_forward), label: Text(isLast ? 'Finish' : 'Next')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
