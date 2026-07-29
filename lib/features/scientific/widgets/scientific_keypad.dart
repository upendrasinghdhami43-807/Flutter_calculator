import 'package:flutter/material.dart';

import 'scientific_button.dart';
import '../scientific_controller.dart';

/// The Pro-mode key grid. 35 keys (7 rows × 5 columns) laid out fx-991-style:
/// trig/log/power/factorial functions each carry a SHIFT (inverse/related
/// function) label and, for the factorial and memory keys, an ALPHA label
/// too, so two or three functions share one physical slot — this keeps the
/// grid usable on a phone screen without a literal 8×6 layout.
class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({required this.state, required this.controller, super.key});

  final ProCalculatorState state;
  final ScientificController controller;

  void _tapOrShiftOrAlpha(VoidCallback normal, {VoidCallback? shift, VoidCallback? alpha}) {
    if (state.alphaActive && alpha != null) {
      alpha();
    } else if (state.shiftActive && shift != null) {
      shift();
    } else {
      normal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[
      [
        ScientificKey(label: 'AC', onTap: controller.clearAll),
        ScientificKey(label: 'DEL', onTap: controller.delete),
        ScientificKey(label: '(', onTap: () => controller.input('(')),
        ScientificKey(label: ')', onTap: () => controller.input(')')),
        ScientificKey(label: ',', onTap: () => controller.input(',')),
      ],
      [
        ScientificKey(
          label: 'sin',
          shiftLabel: 'asin',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('sin('), shift: () => controller.input('asin(')),
        ),
        ScientificKey(
          label: 'cos',
          shiftLabel: 'acos',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('cos('), shift: () => controller.input('acos(')),
        ),
        ScientificKey(
          label: 'tan',
          shiftLabel: 'atan',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('tan('), shift: () => controller.input('atan(')),
        ),
        ScientificKey(label: 'π', onTap: () => controller.input('pi')),
        ScientificKey(label: 'Ans', onTap: () => controller.input('ans')),
      ],
      [
        ScientificKey(
          label: 'log',
          shiftLabel: '10ˣ',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('log('), shift: () => controller.input('10^(')),
        ),
        ScientificKey(
          label: 'ln',
          shiftLabel: 'eˣ',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('ln('), shift: () => controller.input('e^(')),
        ),
        ScientificKey(
          label: 'x²',
          shiftLabel: 'x³',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('^2'), shift: () => controller.input('^3')),
        ),
        ScientificKey(
          label: '√',
          shiftLabel: '∛',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('sqrt('), shift: () => controller.input('root(3,')),
        ),
        ScientificKey(
          label: 'xʸ',
          shiftLabel: 'ʸ√x',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('^'), shift: () => controller.input('root(')),
        ),
      ],
      [
        ScientificKey(
          label: 'x!',
          shiftLabel: 'nCr',
          alphaLabel: 'nPr',
          onTap: () => _tapOrShiftOrAlpha(() => controller.input('!'), shift: () => controller.input('ncr('), alpha: () => controller.input('npr(')),
        ),
        ScientificKey(label: '%', onTap: () => controller.input('%')),
        ScientificKey(label: '7', onTap: () => controller.input('7')),
        ScientificKey(label: '8', onTap: () => controller.input('8')),
        ScientificKey(label: '9', onTap: () => controller.input('9')),
      ],
      [
        ScientificKey(label: '÷', onTap: () => controller.input('/')),
        ScientificKey(label: '4', onTap: () => controller.input('4')),
        ScientificKey(label: '5', onTap: () => controller.input('5')),
        ScientificKey(label: '6', onTap: () => controller.input('6')),
        ScientificKey(label: '×', onTap: () => controller.input('*')),
      ],
      [
        ScientificKey(label: '−', onTap: () => controller.input('-')),
        ScientificKey(label: '1', onTap: () => controller.input('1')),
        ScientificKey(label: '2', onTap: () => controller.input('2')),
        ScientificKey(label: '3', onTap: () => controller.input('3')),
        ScientificKey(label: '+', onTap: () => controller.input('+')),
      ],
      [
        _MemoryKey(state: state, controller: controller),
        ScientificKey(label: '0', onTap: () => controller.input('0')),
        ScientificKey(label: '.', onTap: () => controller.input('.')),
        ScientificKey(label: 'EXP', onTap: () => controller.input('*10^(')),
        ScientificKey(label: '=', isAccent: true, onTap: controller.evaluate),
      ],
    ];

    return Column(
      children: [
        for (final row in rows) Expanded(child: Row(children: [for (final key in row) Expanded(child: key)])),
      ],
    );
  }
}

class _MemoryKey extends StatelessWidget {
  const _MemoryKey({required this.state, required this.controller});

  final ProCalculatorState state;
  final ScientificController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: controller.memoryClear,
      child: ScientificKey(
        label: 'M+',
        shiftLabel: 'M-',
        alphaLabel: 'MR',
        onTap: () {
          if (state.alphaActive) {
            controller.memoryRecall();
          } else if (state.shiftActive) {
            controller.memorySubtract();
            controller.resetModifiers();
          } else {
            controller.memoryAdd();
          }
        },
      ),
    );
  }
}
