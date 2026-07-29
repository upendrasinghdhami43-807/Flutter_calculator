import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'matrix_controller.dart';

class MatrixScreen extends ConsumerWidget {
  const MatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matrixControllerProvider);
    final controller = ref.read(matrixControllerProvider.notifier);

    return PopScope(
      canPop: state.result == null && state.error == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Matrix')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Matrix A', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _SizeSelector(state: state, controller: controller),
              const SizedBox(height: 16),
              _MatrixGrid(values: state.values, rows: state.rows, columns: state.columns, onChanged: controller.setValue),
              const SizedBox(height: 20),
              Text('Operations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _OperationGrid(
                onExecute: controller.execute,
                onNeedSecondary: () => _showSecondarySheet(context, state, controller),
              ),
              if (state.error != null || state.result != null) ...[
                const SizedBox(height: 20),
                _ResultPanel(result: state.result, error: state.error),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSecondarySheet(BuildContext context, MatrixToolState state, MatrixController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Matrix B', style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 12),
                _MatrixGrid(
                  values: state.secondaryValues,
                  rows: state.rows,
                  columns: state.columns,
                  onChanged: (index, value) => controller.setValue(index, value, secondary: true),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(onPressed: () {
                      Navigator.of(sheetContext).pop();
                      controller.execute(MatrixOperation.add);
                    }, child: const Text('A + B')),
                    FilledButton(onPressed: () {
                      Navigator.of(sheetContext).pop();
                      controller.execute(MatrixOperation.subtract);
                    }, child: const Text('A − B')),
                    FilledButton(onPressed: () {
                      Navigator.of(sheetContext).pop();
                      controller.execute(MatrixOperation.multiply);
                    }, child: const Text('A × B')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.state, required this.controller});

  final MatrixToolState state;
  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _DimensionPicker(label: 'Rows', value: state.rows, onChanged: (value) => controller.setSize(rows: value, columns: state.columns))),
        const SizedBox(width: 16),
        Expanded(child: _DimensionPicker(label: 'Columns', value: state.columns, onChanged: (value) => controller.setSize(rows: state.rows, columns: value))),
      ],
    );
  }
}

class _DimensionPicker extends StatelessWidget {
  const _DimensionPicker({required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [2, 3, 4].map((size) => DropdownMenuItem(value: size, child: Text('$size'))).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }
}

class _MatrixGrid extends StatelessWidget {
  const _MatrixGrid({required this.values, required this.rows, required this.columns, required this.onChanged});

  final List<String> values;
  final int rows;
  final int columns;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: values.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.7),
      itemBuilder: (context, index) => TextFormField(
        key: ValueKey('matrix-${rows}x$columns-$index-${values[index]}'),
        initialValue: values[index],
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: '${index ~/ columns + 1}, ${index % columns + 1}'),
        onChanged: (value) => onChanged(index, value),
      ),
    );
  }
}

class _OperationGrid extends StatelessWidget {
  const _OperationGrid({required this.onExecute, required this.onNeedSecondary});

  final ValueChanged<MatrixOperation> onExecute;
  final VoidCallback onNeedSecondary;

  @override
  Widget build(BuildContext context) {
    final operations = <({String label, MatrixOperation? operation})>[
      (label: 'det(A)', operation: MatrixOperation.determinant),
      (label: 'A⁻¹', operation: MatrixOperation.inverse),
      (label: 'Aᵀ', operation: MatrixOperation.transpose),
      (label: 'rank(A)', operation: MatrixOperation.rank),
      (label: 'eigenvalues', operation: MatrixOperation.eigenvalues),
      (label: 'A ± B / A × B', operation: null),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: operations.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3.3),
      itemBuilder: (context, index) {
        final item = operations[index];
        return OutlinedButton(
          onPressed: item.operation == null ? onNeedSecondary : () => onExecute(item.operation!),
          child: Text(item.label),
        );
      },
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({this.result, this.error});

  final String? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasError ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(error ?? result ?? '', style: TextStyle(color: hasError ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }
}
