import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'equation_controller.dart';

class EquationScreen extends ConsumerWidget {
  const EquationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equationControllerProvider);
    final controller = ref.read(equationControllerProvider.notifier);

    return PopScope(
      canPop: state.result == null && state.error == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Equation Solver')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<EquationTool>(
                segments: const [
                  ButtonSegment(value: EquationTool.polynomial, icon: Icon(Icons.functions), label: Text('Polynomial')),
                  ButtonSegment(value: EquationTool.system, icon: Icon(Icons.linear_scale), label: Text('System')),
                ],
                selected: {state.tool},
                onSelectionChanged: (selection) => controller.setTool(selection.single),
              ),
              const SizedBox(height: 24),
              if (state.tool == EquationTool.polynomial)
                _PolynomialForm(state: state, controller: controller)
              else
                _SystemForm(state: state, controller: controller),
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: controller.solve, icon: const Icon(Icons.play_arrow), label: const Text('Solve')),
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
}

class _PolynomialForm extends StatelessWidget {
  const _PolynomialForm({required this.state, required this.controller});

  final EquationState state;
  final EquationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Solve axⁿ + ... + c = 0', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: state.polynomialDegree,
          decoration: const InputDecoration(labelText: 'Degree', border: OutlineInputBorder()),
          items: [2, 3, 4].map((degree) => DropdownMenuItem(value: degree, child: Text('$degree'))).toList(),
          onChanged: (degree) => controller.setPolynomialDegree(degree!),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.polynomialCoefficients.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.3),
          itemBuilder: (context, index) {
            final exponent = state.polynomialDegree - index;
            return TextFormField(
              key: ValueKey('poly-$index-${state.polynomialCoefficients[index]}'),
              initialValue: state.polynomialCoefficients[index],
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: exponent == 0 ? 'constant c' : exponent == 1 ? 'x coefficient' : 'x$exponent coefficient', border: const OutlineInputBorder()),
              onChanged: (value) => controller.setPolynomialCoefficient(index, value),
            );
          },
        ),
      ],
    );
  }
}

class _SystemForm extends StatelessWidget {
  const _SystemForm({required this.state, required this.controller});

  final EquationState state;
  final EquationController controller;

  @override
  Widget build(BuildContext context) {
    final size = state.systemSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Solve A · x = b', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: size,
          decoration: const InputDecoration(labelText: 'Variables', border: OutlineInputBorder()),
          items: [2, 3, 4].map((value) => DropdownMenuItem(value: value, child: Text('$value × $value'))).toList(),
          onChanged: (value) => controller.setSystemSize(value!),
        ),
        const SizedBox(height: 16),
        Text('Coefficient matrix A', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.systemCoefficients.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.7),
          itemBuilder: (context, index) => TextFormField(
            key: ValueKey('system-$index-${state.systemCoefficients[index]}'),
            initialValue: state.systemCoefficients[index],
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(labelText: 'a${index ~/ size + 1}${index % size + 1}', border: const OutlineInputBorder()),
            onChanged: (value) => controller.setSystemCoefficient(index, value),
          ),
        ),
        const SizedBox(height: 16),
        Text('Constants b', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < size; index++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == size - 1 ? 0 : 8),
                  child: TextFormField(
                    key: ValueKey('constant-$index-${state.systemConstants[index]}'),
                    initialValue: state.systemConstants[index],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(labelText: 'b${index + 1}', border: const OutlineInputBorder()),
                    onChanged: (value) => controller.setSystemConstant(index, value),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({this.result, this.error});

  final String? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final isError = error != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isError ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: SelectableText(error ?? result ?? '', style: TextStyle(color: isError ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }
}
