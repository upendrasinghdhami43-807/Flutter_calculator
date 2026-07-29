import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/history_panel.dart';
import 'scientific_controller.dart';
import 'widgets/mode_selector_sheet.dart';
import 'widgets/pro_display.dart';
import 'widgets/pro_top_bar.dart';
import 'widgets/scientific_keypad.dart';
import 'widgets/tools_sheet.dart';

class ScientificScreen extends ConsumerWidget {
  const ScientificScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scientificControllerProvider);
    final controller = ref.read(scientificControllerProvider.notifier);

    return PopScope(
      canPop: state.expression.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.clearAll();
      },
      child: Scaffold(
        appBar: ProTopBar(
          modeLabel: state.mode == ProMode.comp ? 'COMP' : 'CMPLX',
          angleUnit: state.angleUnit,
          shiftActive: state.shiftActive,
          alphaActive: state.alphaActive,
          onAngleUnitTap: controller.cycleAngleUnit,
          onModeTap: () => ModeSelectorSheet.show(context, currentMode: state.mode, onSelect: controller.setMode),
          onToolsTap: () => ToolsSheet.show(context, controller),
          onHistoryTap: () => HistoryPanel.show(
            context,
            modeFilter: 'Pro',
            onSelect: (entry) => controller.input(entry.expression),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ProDisplay(expression: state.expression, result: state.result, error: state.error, hasMemory: state.memory != 0),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ModifierButton(
                        label: 'SHIFT',
                        active: state.shiftActive,
                        color: Theme.of(context).colorScheme.tertiary,
                        onTap: controller.toggleShift,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModifierButton(
                        label: 'ALPHA',
                        active: state.alphaActive,
                        color: Theme.of(context).colorScheme.error,
                        onTap: controller.toggleAlpha,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: ScientificKeypad(state: state, controller: controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModifierButton extends StatelessWidget {
  const _ModifierButton({required this.label, required this.active, required this.color, required this.onTap});

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? color : null,
        foregroundColor: active ? Colors.white : color,
        side: BorderSide(color: color),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
