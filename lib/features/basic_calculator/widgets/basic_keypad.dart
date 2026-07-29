import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/expression_engine/evaluator.dart';
import '../../../shared/widgets/calc_button.dart';
import '../basic_calculator_controller.dart';

class BasicKeypad extends ConsumerWidget {
  const BasicKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorProvider);
    final controller = ref.read(basicCalculatorProvider.notifier);
    final buttons = <Widget>[
      CalcButton(label: state.isExpanded ? 'Hide' : 'More', isMuted: true, onPressed: controller.toggleExpanded),
      CalcButton(label: 'AC', isMuted: true, onPressed: controller.clear),
      CalcButton(label: 'DEL', isMuted: true, onPressed: controller.delete),
      CalcButton(label: '/', isAccent: true, onPressed: () => controller.input('/')),
      if (state.isExpanded) ...[
        CalcButton(label: 'sin', isMuted: true, onPressed: () => controller.input('sin(')),
        CalcButton(label: 'cos', isMuted: true, onPressed: () => controller.input('cos(')),
        CalcButton(label: 'tan', isMuted: true, onPressed: () => controller.input('tan(')),
        CalcButton(label: _angleLabel(state.angleUnit), isMuted: true, onPressed: controller.cycleAngleUnit),
      ],
      CalcButton(label: '7', onPressed: () => controller.input('7')),
      CalcButton(label: '8', onPressed: () => controller.input('8')),
      CalcButton(label: '9', onPressed: () => controller.input('9')),
      CalcButton(label: '*', isAccent: true, onPressed: () => controller.input('*')),
      if (state.isExpanded) ...[
        CalcButton(label: 'log', isMuted: true, onPressed: () => controller.input('log(')),
        CalcButton(label: 'ln', isMuted: true, onPressed: () => controller.input('ln(')),
        CalcButton(label: 'pi', isMuted: true, onPressed: () => controller.input('pi')),
        CalcButton(label: 'e', isMuted: true, onPressed: () => controller.input('e')),
      ],
      CalcButton(label: '4', onPressed: () => controller.input('4')),
      CalcButton(label: '5', onPressed: () => controller.input('5')),
      CalcButton(label: '6', onPressed: () => controller.input('6')),
      CalcButton(label: '-', isAccent: true, onPressed: () => controller.input('-')),
      CalcButton(label: '1', onPressed: () => controller.input('1')),
      CalcButton(label: '2', onPressed: () => controller.input('2')),
      CalcButton(label: '3', onPressed: () => controller.input('3')),
      CalcButton(label: '+', isAccent: true, onPressed: () => controller.input('+')),
      CalcButton(label: '(', isMuted: true, onPressed: () => controller.input('(')),
      CalcButton(label: '0', onPressed: () => controller.input('0')),
      CalcButton(label: '.', onPressed: () => controller.input('.')),
      CalcButton(label: '=', isAccent: true, onPressed: controller.evaluate),
    ];
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: buttons,
    );
  }

  String _angleLabel(AngleUnit angleUnit) => switch (angleUnit) {
    AngleUnit.degrees => 'Deg',
    AngleUnit.radians => 'Rad',
    AngleUnit.gradians => 'Grad',
  };
}
