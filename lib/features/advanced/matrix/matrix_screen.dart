import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/guided_number_entry_sheet.dart';
import 'matrix_controller.dart';

class MatrixScreen extends ConsumerStatefulWidget {
  const MatrixScreen({super.key});

  @override
  ConsumerState<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends ConsumerState<MatrixScreen> {
  var _leftName = 'A';
  var _rightName = 'B';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matrixControllerProvider);
    final controller = ref.read(matrixControllerProvider.notifier);


    return PopScope(
      canPop: state.result == null && state.error == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Matrix Workbench')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Build a matrix', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Use fast entry for quick input, then save into A, B, or C.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),

              // Quick size presets
              Text('Quick size', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final size in const [(1, 1), (2, 2), (3, 3), (4, 4), (2, 3), (3, 2)])
                    ChoiceChip(
                      label: Text('${size.$1}×${size.$2}'),
                      selected: state.rows == size.$1 && state.columns == size.$2,
                      onSelected: (_) => controller.setSize(rows: size.$1, columns: size.$2),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Custom size dropdowns
              Row(
                children: [
                  Expanded(child: _DimensionPicker(label: 'Rows', value: state.rows, onChanged: (v) => controller.setSize(rows: v, columns: state.columns))),
                  const SizedBox(width: 12),
                  Expanded(child: _DimensionPicker(label: 'Cols', value: state.columns, onChanged: (v) => controller.setSize(rows: state.rows, columns: v))),
                ],
              ),
              const SizedBox(height: 16),

              // Matrix grid
              _MatrixGrid(values: state.values, rows: state.rows, columns: state.columns, onChanged: controller.setValue),
              const SizedBox(height: 12),

              // Actions - Fast entry is primary
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => _openGuidedEntry(context, state, controller),
                      icon: const Icon(Icons.dialpad_outlined, size: 18),
                      label: const Text('Fast entry'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MenuAnchor(
                      builder: (context, menuController, _) => OutlinedButton.icon(
                        onPressed: menuController.open,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save'),
                      ),
                      menuChildren: [
                        for (final name in const ['A', 'B', 'C'])
                          MenuItemButton(
                            onPressed: () {
                              controller.saveCurrentAs(name);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved as Matrix $name.')));
                            },
                            child: Text('Save as $name'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Saved matrices with preview
              Text('Saved matrices', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _SavedMatricesPanel(state: state, controller: controller),
              const SizedBox(height: 20),

              // Single-matrix operations
              Text('Single-matrix operations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _OperationGrid(onExecute: controller.execute),
              const SizedBox(height: 20),

              // A/B/C operations
              Text('Saved matrix operations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Apply operations to saved matrices.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MatrixNamePicker(label: 'Left', value: _leftName, onChanged: (v) => setState(() => _leftName = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _MatrixNamePicker(label: 'Right', value: _rightName, onChanged: (v) => setState(() => _rightName = v))),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => controller.executeSaved(MatrixOperation.add, leftName: _leftName, rightName: _rightName),
                    child: Text('$_leftName + $_rightName'),
                  ),
                  OutlinedButton(
                    onPressed: () => controller.executeSaved(MatrixOperation.subtract, leftName: _leftName, rightName: _rightName),
                    child: Text('$_leftName − $_rightName'),
                  ),
                  FilledButton(
                    onPressed: () => controller.executeSaved(MatrixOperation.multiply, leftName: _leftName, rightName: _rightName),
                    child: Text('$_leftName × $_rightName'),
                  ),
                ],
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

  void _openGuidedEntry(BuildContext context, MatrixToolState state, MatrixController controller) {
    GuidedNumberEntrySheet.show(
      context,
      title: 'Matrix ${state.rows}×${state.columns}',
      labels: List.generate(state.values.length, (i) => 'Cell [${i ~/ state.columns + 1}, ${i % state.columns + 1}]'),
      values: state.values,
      onValue: controller.setValue,
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
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      items: [1, 2, 3, 4].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
      onChanged: (v) => onChanged(v!),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: columns == 1 ? 3.0 : 1.7,
      ),
      itemBuilder: (context, index) => TextFormField(
        key: ValueKey('m-${rows}x$columns-$index-${values[index]}'),
        initialValue: values[index],
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: '${index ~/ columns + 1},${index % columns + 1}',
          isDense: true,
        ),
        onChanged: (v) => onChanged(index, v),
      ),
    );
  }
}

class _OperationGrid extends StatelessWidget {
  const _OperationGrid({required this.onExecute});

  final ValueChanged<MatrixOperation> onExecute;

  @override
  Widget build(BuildContext context) {
    final operations = <({String label, MatrixOperation operation})>[
      (label: 'det(A)', operation: MatrixOperation.determinant),
      (label: 'A⁻¹', operation: MatrixOperation.inverse),
      (label: 'Aᵀ', operation: MatrixOperation.transpose),
      (label: 'rank(A)', operation: MatrixOperation.rank),
      (label: 'Eigenvalues', operation: MatrixOperation.eigenvalues),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in operations)
          OutlinedButton(
            onPressed: () => onExecute(item.operation),
            child: Text(item.label),
          ),
      ],
    );
  }
}

class _SavedMatricesPanel extends StatelessWidget {
  const _SavedMatricesPanel({required this.state, required this.controller});

  final MatrixToolState state;
  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final name in const ['A', 'B', 'C'])
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: state.savedMatrices.containsKey(name) ? colors.primary : colors.surfaceContainerHighest,
                        child: Text(name, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: state.savedMatrices.containsKey(name) ? colors.onPrimary : colors.onSurface,
                        )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.savedMatrices.containsKey(name)
                              ? 'Matrix $name — ${state.savedMatrices[name]!.rows}×${state.savedMatrices[name]!.columns}'
                              : 'Matrix $name — empty',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (state.savedMatrices.containsKey(name)) ...[
                        IconButton(
                          tooltip: 'Load $name',
                          onPressed: () => controller.loadSaved(name),
                          icon: const Icon(Icons.download_outlined, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          tooltip: 'Remove $name',
                          onPressed: () => controller.removeSaved(name),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                  // Mini preview
                  if (state.savedMatrices.containsKey(name)) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatPreview(state.savedMatrices[name]!),
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: colors.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatPreview(SavedMatrix matrix) {
    final lines = <String>[];
    for (var r = 0; r < matrix.rows; r++) {
      final row = <String>[];
      for (var c = 0; c < matrix.columns; c++) {
        row.add(matrix.values[r * matrix.columns + c]);
      }
      lines.add('[ ${row.join('  ')} ]');
    }
    return lines.join('\n');
  }
}

class _MatrixNamePicker extends StatelessWidget {
  const _MatrixNamePicker({required this.label, required this.value, required this.onChanged});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    items: const ['A', 'B', 'C'].map((n) => DropdownMenuItem(value: n, child: Text('Matrix $n'))).toList(),
    onChanged: (v) => onChanged(v!),
  );
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({this.result, this.error});

  final String? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        error ?? result ?? '',
        style: TextStyle(
          color: hasError ? colors.onErrorContainer : colors.onSecondaryContainer,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }
}
