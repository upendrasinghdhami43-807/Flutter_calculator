import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/expression_engine/evaluator.dart';
import '../../shared/widgets/history_panel.dart';
import 'scientific_controller.dart';
import 'widgets/mode_selector_sheet.dart';
import 'widgets/pro_display.dart';
import 'widgets/pro_top_bar.dart';
import 'widgets/scientific_keypad.dart';
import 'widgets/tools_sheet.dart';

class ScientificScreen extends ConsumerWidget {
  const ScientificScreen({super.key});

  String _angleLabel(AngleUnit unit) => switch (unit) {
    AngleUnit.degrees => 'DEG',
    AngleUnit.radians => 'RAD',
    AngleUnit.gradians => 'GRAD',
  };

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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              children: [
                // Display takes ~25% of vertical space
                ProDisplay(
                  expression: state.expression,
                  result: state.result,
                  error: state.error,
                  hasMemory: state.memory != 0,
                  angleLabel: _angleLabel(state.angleUnit),
                ),
                const SizedBox(height: 6),
                // SHIFT / ALPHA modifier row
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModifierButton(
                          label: 'SHIFT',
                          active: state.shiftActive,
                          color: Theme.of(context).colorScheme.tertiary,
                          onTap: controller.toggleShift,
                        ),
                      ),
                      const SizedBox(width: 6),
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
                ),
                const SizedBox(height: 4),
                // Keypad takes remaining space
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
    return Material(
      color: active ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : color,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
