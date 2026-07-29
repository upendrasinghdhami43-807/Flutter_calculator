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
              const SizedBox(height: 6),
              Text('Enter values directly or use the fast number pad, then save the matrix into A, B, or C.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              _SizeSelector(state: state, controller: controller),
              const SizedBox(height: 16),
              _MatrixGrid(values: state.values, rows: state.rows, columns: state.columns, onChanged: controller.setValue),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _openGuidedEntry(context, state, controller), icon: const Icon(Icons.dialpad_outlined), label: const Text('Fast entry'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MenuAnchor(
                      builder: (context, menuController, _) => FilledButton.icon(onPressed: menuController.open, icon: const Icon(Icons.save_outlined), label: const Text('Save as')),
                      menuChildren: [
                        for (final name in const ['A', 'B', 'C'])
                          MenuItemButton(
                            onPressed: () {
                              controller.saveCurrentAs(name);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved current matrix as $name.')));
                            },
                            child: Text('Save as $name'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Saved matrices', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _SavedMatricesPanel(state: state, controller: controller),
              const SizedBox(height: 20),
              Text('Single-matrix operations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _OperationGrid(onExecute: controller.execute),
              const SizedBox(height: 20),
              Text('A/B/C operations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Apply an operation directly to saved matrices.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MatrixNamePicker(label: 'Left', value: _leftName, onChanged: (value) => setState(() => _leftName = value))),
                  const SizedBox(width: 12),
                  Expanded(child: _MatrixNamePicker(label: 'Right', value: _rightName, onChanged: (value) => setState(() => _rightName = value))),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () => controller.executeSaved(MatrixOperation.add, leftName: _leftName, rightName: _rightName), child: Text('$_leftName + $_rightName')),
                  OutlinedButton(onPressed: () => controller.executeSaved(MatrixOperation.subtract, leftName: _leftName, rightName: _rightName), child: Text('$_leftName − $_rightName')),
                  FilledButton(onPressed: () => controller.executeSaved(MatrixOperation.multiply, leftName: _leftName, rightName: _rightName), child: Text('$_leftName × $_rightName')),
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
      title: 'Fast matrix entry',
      labels: List.generate(state.values.length, (index) => 'Matrix cell [${index ~/ state.columns + 1}, ${index % state.columns + 1}]'),
      values: state.values,
      onValue: controller.setValue,
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
      items: [1, 2, 3, 4].map((size) => DropdownMenuItem(value: size, child: Text('$size'))).toList(),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: operations.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3.3),
      itemBuilder: (context, index) {
        final item = operations[index];
        return OutlinedButton(
          onPressed: () => onExecute(item.operation),
          child: Text(item.label),
        );
      },
    );
  }
}

class _SavedMatricesPanel extends StatelessWidget {
  const _SavedMatricesPanel({required this.state, required this.controller});

  final MatrixToolState state;
  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final name in const ['A', 'B', 'C'])
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(name)),
              title: Text(state.savedMatrices.containsKey(name) ? 'Matrix $name' : 'Matrix $name is empty'),
              subtitle: Text(state.savedMatrices.containsKey(name) ? '${state.savedMatrices[name]!.rows} × ${state.savedMatrices[name]!.columns} saved' : 'Save the current editor into this slot.'),
              trailing: state.savedMatrices.containsKey(name)
                  ? Wrap(
                      spacing: 2,
                      children: [
                        IconButton(tooltip: 'Load $name', onPressed: () => controller.loadSaved(name), icon: const Icon(Icons.download_outlined)),
                        IconButton(tooltip: 'Remove $name', onPressed: () => controller.removeSaved(name), icon: const Icon(Icons.delete_outline)),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
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
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    items: const ['A', 'B', 'C'].map((name) => DropdownMenuItem(value: name, child: Text('Matrix $name'))).toList(),
    onChanged: (value) => onChanged(value!),
  );
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
