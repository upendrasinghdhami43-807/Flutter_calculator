import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/guided_number_entry_sheet.dart';
import 'calculus_controller.dart';

class CalculusScreen extends ConsumerWidget {
  const CalculusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculusControllerProvider);
    final controller = ref.read(calculusControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculus Workspace')),
      body: SafeArea(
        child: Column(
          children: [
            // Tool selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SegmentedButton<CalculusTool>(
                segments: const [
                  ButtonSegment(value: CalculusTool.derivative, icon: Icon(Icons.trending_up, size: 18), label: Text('d/dx', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: CalculusTool.integral, icon: Icon(Icons.area_chart, size: 18), label: Text('∫dx', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: CalculusTool.root, icon: Icon(Icons.gps_fixed, size: 18), label: Text('Root', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: CalculusTool.limit, icon: Icon(Icons.arrow_right_alt, size: 18), label: Text('Lim', style: TextStyle(fontSize: 12))),
                ],
                selected: {state.tool},
                onSelectionChanged: (selection) => controller.setTool(selection.single),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Expression input
                  Text('Expression f(x)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: state.expression,
                    decoration: const InputDecoration(
                      labelText: 'f(x)',
                      hintText: 'x^2, sin(x), ln(x)...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.functions),
                    ),
                    autocorrect: false,
                    onChanged: controller.setExpression,
                  ),
                  const SizedBox(height: 8),
                  // Quick function chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final expr in const ['x^2', 'x^3', 'sin(x)', 'cos(x)', 'tan(x)', 'exp(x)', 'ln(x)', '1/x', 'sqrt(x)', 'x^2+2*x+1'])
                        ActionChip(
                          label: Text(expr, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => controller.setExpression(expr),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Parameters based on tool
                  _buildParameters(context, state, controller),

                  const SizedBox(height: 16),

                  // Compute buttons
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
                          onPressed: controller.compute,
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: Text(_computeLabel(state.tool)),
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
                        border: Border.all(
                          color: state.error != null ? colors.error.withValues(alpha: 0.3) : colors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SelectableText(
                        state.error ?? state.result ?? '',
                        style: TextStyle(
                          color: state.error != null ? colors.onErrorContainer : colors.onSecondaryContainer,
                          fontFamily: 'monospace',
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameters(BuildContext context, CalculusState state, CalculusController controller) {
    return switch (state.tool) {
      CalculusTool.derivative => _DerivativeParams(state: state, controller: controller),
      CalculusTool.integral => _IntegralParams(state: state, controller: controller),
      CalculusTool.root => _RootParams(state: state, controller: controller),
      CalculusTool.limit => _LimitParams(state: state, controller: controller),
    };
  }

  String _computeLabel(CalculusTool tool) => switch (tool) {
    CalculusTool.derivative => 'Differentiate',
    CalculusTool.integral => 'Integrate',
    CalculusTool.root => 'Find Root',
    CalculusTool.limit => 'Compute Limit',
  };

  void _openGuidedEntry(BuildContext context, CalculusState state, CalculusController controller) {
    final (labels, values, setters) = switch (state.tool) {
      CalculusTool.derivative => (
        ['Expression f(x)', 'Evaluate at x ='],
        [state.expression, state.point],
        [(String v) => controller.setExpression(v), (String v) => controller.setPoint(v)],
      ),
      CalculusTool.integral => (
        ['Expression f(x)', 'Lower bound a', 'Upper bound b'],
        [state.expression, state.lowerBound, state.upperBound],
        [(String v) => controller.setExpression(v), (String v) => controller.setLowerBound(v), (String v) => controller.setUpperBound(v)],
      ),
      CalculusTool.root => (
        ['Expression f(x)', 'Lower bound a', 'Upper bound b'],
        [state.expression, state.lowerBound, state.upperBound],
        [(String v) => controller.setExpression(v), (String v) => controller.setLowerBound(v), (String v) => controller.setUpperBound(v)],
      ),
      CalculusTool.limit => (
        ['Expression f(x)', 'x approaches'],
        [state.expression, state.limitApproach],
        [(String v) => controller.setExpression(v), (String v) => controller.setLimitApproach(v)],
      ),
    };

    GuidedNumberEntrySheet.show(
      context,
      title: 'Calculus parameters',
      labels: labels,
      values: values,
      onValue: (index, value) => setters[index](value),
      onFinished: controller.compute,
    );
  }
}

class _DerivativeParams extends StatelessWidget {
  const _DerivativeParams({required this.state, required this.controller});

  final CalculusState state;
  final CalculusController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evaluate derivative at', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.point,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: const InputDecoration(labelText: 'x =', border: OutlineInputBorder()),
          onChanged: controller.setPoint,
        ),
      ],
    );
  }
}

class _IntegralParams extends StatelessWidget {
  const _IntegralParams({required this.state, required this.controller});

  final CalculusState state;
  final CalculusController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Integration bounds', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.lowerBound,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Lower (a)', border: OutlineInputBorder()),
                onChanged: controller.setLowerBound,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: state.upperBound,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Upper (b)', border: OutlineInputBorder()),
                onChanged: controller.setUpperBound,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RootParams extends StatelessWidget {
  const _RootParams({required this.state, required this.controller});

  final CalculusState state;
  final CalculusController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search interval for root', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text('f(a) and f(b) must have opposite signs.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.lowerBound,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Lower (a)', border: OutlineInputBorder()),
                onChanged: controller.setLowerBound,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: state.upperBound,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Upper (b)', border: OutlineInputBorder()),
                onChanged: controller.setUpperBound,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LimitParams extends StatelessWidget {
  const _LimitParams({required this.state, required this.controller});

  final CalculusState state;
  final CalculusController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Limit as x approaches', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.limitApproach,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: const InputDecoration(labelText: 'x →', border: OutlineInputBorder()),
          onChanged: controller.setLimitApproach,
        ),
      ],
    );
  }
}
