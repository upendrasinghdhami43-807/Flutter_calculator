import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/result_display.dart';
import 'basic_calculator_controller.dart';
import 'widgets/basic_keypad.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  const BasicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Calculator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ResultDisplay(expression: state.expression, result: state.result, error: state.error),
              const SizedBox(height: 16),
              Expanded(child: BasicKeypad()),
            ],
          ),
        ),
      ),
    );
  }
}