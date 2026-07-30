import 'package:flutter/material.dart';

import 'scientific_button.dart';
import '../scientific_controller.dart';

/// The Pro-mode key grid, fx-991EX style. 8 rows × 5 columns = 40 keys.
/// Trig/log/power/factorial functions carry SHIFT and ALPHA labels.
/// Number keys and operators use distinct color coding for quick scanning.
class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({required this.state, required this.controller, super.key});

  final ProCalculatorState state;
  final ScientificController controller;

  void _dispatch(VoidCallback normal, {VoidCallback? shift, VoidCallback? alpha}) {
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
    // 8 rows × 5 columns — every key is an Expanded widget inside a Row,
    // and every Row is an Expanded widget inside a Column.
    final rows = <List<Widget>>[
      // Row 1: Clear, Delete, Brackets, Comma
      [
        ScientificKey(label: 'AC', onTap: controller.clearAll),
        ScientificKey(label: 'DEL', onTap: controller.delete),
        ScientificKey(label: '(', onTap: () => controller.input('(')),
        ScientificKey(label: ')', onTap: () => controller.input(')')),
        ScientificKey(label: ',', onTap: () => controller.input(',')),
      ],
      // Row 2: Trig
      [
        ScientificKey(
          label: 'sin',
          shiftLabel: 'sin⁻¹',
          alphaLabel: 'D',
          onTap: () => _dispatch(
            () => controller.input('sin('),
            shift: () => controller.input('asin('),
            alpha: () => controller.recallVariable('d'),
          ),
        ),
        ScientificKey(
          label: 'cos',
          shiftLabel: 'cos⁻¹',
          alphaLabel: 'E',
          onTap: () => _dispatch(
            () => controller.input('cos('),
            shift: () => controller.input('acos('),
            alpha: () => controller.recallVariable('e'),
          ),
        ),
        ScientificKey(
          label: 'tan',
          shiftLabel: 'tan⁻¹',
          alphaLabel: 'F',
          onTap: () => _dispatch(
            () => controller.input('tan('),
            shift: () => controller.input('atan('),
            alpha: () => controller.recallVariable('f'),
          ),
        ),
        ScientificKey(
          label: 'π',
          shiftLabel: 'e',
          onTap: () => _dispatch(
            () => controller.input('pi'),
            shift: () => controller.input('e'),
          ),
        ),
        ScientificKey(
          label: 'Ans',
          onTap: () => controller.input('ans'),
        ),
      ],
      // Row 3: Log/Power
      [
        ScientificKey(
          label: 'log',
          shiftLabel: '10ˣ',
          onTap: () => _dispatch(
            () => controller.input('log('),
            shift: () => controller.input('10^('),
          ),
        ),
        ScientificKey(
          label: 'ln',
          shiftLabel: 'eˣ',
          onTap: () => _dispatch(
            () => controller.input('ln('),
            shift: () => controller.input('e^('),
          ),
        ),
        ScientificKey(
          label: 'x²',
          shiftLabel: 'x³',
          onTap: () => _dispatch(
            () => controller.input('^2'),
            shift: () => controller.input('^3'),
          ),
        ),
        ScientificKey(
          label: '√',
          shiftLabel: '∛',
          onTap: () => _dispatch(
            () => controller.input('sqrt('),
            shift: () => controller.input('root(3,'),
          ),
        ),
        ScientificKey(
          label: 'xʸ',
          shiftLabel: 'ʸ√x',
          onTap: () => _dispatch(
            () => controller.input('^'),
            shift: () => controller.input('root('),
          ),
        ),
      ],
      // Row 4: Factorial, Percent, |x|, x⁻¹, EXP
      [
        ScientificKey(
          label: 'x!',
          shiftLabel: 'nCr',
          alphaLabel: 'nPr',
          onTap: () => _dispatch(
            () => controller.input('!'),
            shift: () => controller.input('ncr('),
            alpha: () => controller.input('npr('),
          ),
        ),
        ScientificKey(
          label: '%',
          shiftLabel: '|x|',
          onTap: () => _dispatch(
            () => controller.input('%'),
            shift: () => controller.input('abs('),
          ),
        ),
        ScientificKey(
          label: 'x⁻¹',
          shiftLabel: 'Ran#',
          onTap: () => _dispatch(
            () => controller.input('^(-1)'),
            shift: () => controller.input('0'), // random placeholder
          ),
        ),
        ScientificKey(
          label: 'EXP',
          onTap: () => controller.input('*10^('),
        ),
        ScientificKey(
          label: 'exp',
          shiftLabel: 'hyp',
          onTap: () => _dispatch(
            () => controller.input('exp('),
            shift: () => controller.input('exp('), // hyp placeholder
          ),
        ),
      ],
      // Row 5: Divide and 7, 8, 9
      [
        ScientificKey(label: '÷', isOperator: true, onTap: () => controller.input('/')),
        ScientificKey(label: '7', fontSize: 18, onTap: () => controller.input('7')),
        ScientificKey(label: '8', fontSize: 18, onTap: () => controller.input('8')),
        ScientificKey(label: '9', fontSize: 18, onTap: () => controller.input('9')),
        ScientificKey(label: '×', isOperator: true, onTap: () => controller.input('*')),
      ],
      // Row 6: Subtract and 4, 5, 6
      [
        ScientificKey(label: '−', isOperator: true, onTap: () => controller.input('-')),
        ScientificKey(label: '4', fontSize: 18, onTap: () => controller.input('4')),
        ScientificKey(label: '5', fontSize: 18, onTap: () => controller.input('5')),
        ScientificKey(label: '6', fontSize: 18, onTap: () => controller.input('6')),
        ScientificKey(label: '+', isOperator: true, onTap: () => controller.input('+')),
      ],
      // Row 7: Memory and 1, 2, 3
      [
        _MemoryKey(state: state, controller: controller),
        ScientificKey(label: '1', fontSize: 18, onTap: () => controller.input('1')),
        ScientificKey(label: '2', fontSize: 18, onTap: () => controller.input('2')),
        ScientificKey(label: '3', fontSize: 18, onTap: () => controller.input('3')),
        ScientificKey(label: '(−)', onTap: () => controller.input('(-')),
      ],
      // Row 8: 0, dot, equals
      [
        ScientificKey(
          label: 'GCD',
          shiftLabel: 'LCM',
          onTap: () => _dispatch(
            () => controller.input('gcd('),
            shift: () => controller.input('lcm('),
          ),
          fontSize: 12,
        ),
        ScientificKey(label: '0', fontSize: 18, onTap: () => controller.input('0')),
        ScientificKey(label: '.', fontSize: 18, onTap: () => controller.input('.')),
        ScientificKey(label: '00', fontSize: 14, onTap: () => controller.input('00')),
        ScientificKey(label: '=', isAccent: true, onTap: controller.evaluate),
      ],
    ];

    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [for (final key in row) Expanded(child: key)],
            ),
          ),
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
        shiftLabel: 'M−',
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
