import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/guided_number_entry_sheet.dart';
import 'lpp_controller.dart';

class LppScreen extends ConsumerWidget {
  const LppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lppControllerProvider);
    final controller = ref.read(lppControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final varNames = ['x₁', 'x₂', 'x₃', 'x₄'];

    return Scaffold(
      appBar: AppBar(title: const Text('LPP Solver')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Linear Programming Problem', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Enter objective function and constraints, then solve.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),

            // Maximize / Minimize toggle
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, icon: Icon(Icons.trending_up, size: 18), label: Text('Maximize')),
                ButtonSegment(value: false, icon: Icon(Icons.trending_down, size: 18), label: Text('Minimize')),
              ],
              selected: {state.maximize},
              onSelectionChanged: (s) => controller.setMaximize(s.single),
            ),
            const SizedBox(height: 16),

            // Size selectors
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: state.numVariables,
                    decoration: const InputDecoration(labelText: 'Variables', border: OutlineInputBorder()),
                    items: [1, 2, 3, 4].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                    onChanged: (v) => controller.setNumVariables(v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: state.numConstraints,
                    decoration: const InputDecoration(labelText: 'Constraints', border: OutlineInputBorder()),
                    items: [1, 2, 3, 4, 5, 6].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                    onChanged: (v) => controller.setNumConstraints(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Objective function
            Text('Objective Function', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${state.maximize ? "Max" : "Min"} Z = ${List.generate(state.numVariables, (i) => '${state.objectiveCoefficients[i]}${varNames[i]}').join(' + ')}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < state.numVariables; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('obj-$i-${state.objectiveCoefficients[i]}'),
                      initialValue: state.objectiveCoefficients[i],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(labelText: varNames[i], border: const OutlineInputBorder()),
                      onChanged: (v) => controller.setObjectiveCoefficient(i, v),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Constraints
            Text('Constraints', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var c = 0; c < state.numConstraints; c++) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Constraint ${c + 1}', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var j = 0; j < state.numVariables; j++) ...[
                            if (j > 0) const SizedBox(width: 4),
                            Expanded(
                              child: TextFormField(
                                key: ValueKey('con-$c-$j-${state.constraintCoefficients[c * state.numVariables + j]}'),
                                initialValue: state.constraintCoefficients[c * state.numVariables + j],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: varNames[j],
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (v) => controller.setConstraintCoefficient(c * state.numVariables + j, v),
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 52,
                            child: DropdownButtonFormField<String>(
                              initialValue: state.constraintTypes[c],
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
                              items: const ['<=', '>=', '='].map((v) => DropdownMenuItem(value: v, child: Text(v, style: TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) => controller.setConstraintType(c, v!),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              key: ValueKey('rhs-$c-${state.constraintRhs[c]}'),
                              initialValue: state.constraintRhs[c],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(labelText: 'RHS', border: OutlineInputBorder(), isDense: true),
                              style: const TextStyle(fontSize: 14),
                              onChanged: (v) => controller.setConstraintRhs(c, v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openGuidedEntry(context, state, controller),
                    icon: const Icon(Icons.dialpad_outlined, size: 18),
                    label: const Text('Fast entry'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.solve,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Solve'),
                  ),
                ),
              ],
            ),

            // Result
            if (state.error != null || state.result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.error != null ? colors.errorContainer : colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  state.error ?? state.result ?? '',
                  style: TextStyle(
                    color: state.error != null ? colors.onErrorContainer : colors.onSecondaryContainer,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openGuidedEntry(BuildContext context, LppState state, LppController controller) {
    final varNames = ['x₁', 'x₂', 'x₃', 'x₄'];
    final labels = <String>[];
    final values = <String>[];

    // Objective coefficients
    for (var i = 0; i < state.numVariables; i++) {
      labels.add('Objective: ${varNames[i]} coefficient');
      values.add(state.objectiveCoefficients[i]);
    }

    // Constraint coefficients and RHS
    for (var c = 0; c < state.numConstraints; c++) {
      for (var j = 0; j < state.numVariables; j++) {
        labels.add('Constraint ${c + 1}: ${varNames[j]}');
        values.add(state.constraintCoefficients[c * state.numVariables + j]);
      }
      labels.add('Constraint ${c + 1}: RHS');
      values.add(state.constraintRhs[c]);
    }

    GuidedNumberEntrySheet.show(
      context,
      title: 'LPP coefficients',
      labels: labels,
      values: values,
      onValue: (index, value) {
        if (index < state.numVariables) {
          controller.setObjectiveCoefficient(index, value);
        } else {
          final constraintIndex = index - state.numVariables;
          final rowSize = state.numVariables + 1; // coefficients + RHS
          final constraintRow = constraintIndex ~/ rowSize;
          final colInRow = constraintIndex % rowSize;
          if (colInRow < state.numVariables) {
            controller.setConstraintCoefficient(constraintRow * state.numVariables + colInRow, value);
          } else {
            controller.setConstraintRhs(constraintRow, value);
          }
        }
      },
      onFinished: controller.solve,
    );
  }
}
