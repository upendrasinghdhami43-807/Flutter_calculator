import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../scientific_controller.dart';

/// The MODE bottom sheet. COMP and Complex are handled directly in Pro
/// mode; Matrix/Equation/Vector/Statistics/Base-N intentionally are NOT
/// re-implemented here — they route to the shared Advanced-mode screens so
/// the solver logic is written exactly once (per the spec's explicit
/// "do not duplicate solver logic" requirement).
class ModeSelectorSheet extends StatelessWidget {
  const ModeSelectorSheet({required this.currentMode, required this.onSelect, super.key});

  final ProMode currentMode;
  final ValueChanged<ProMode> onSelect;

  static Future<void> show(BuildContext context, {required ProMode currentMode, required ValueChanged<ProMode> onSelect}) {
    return showModalBottomSheet(context: context, builder: (_) => ModeSelectorSheet(currentMode: currentMode, onSelect: onSelect));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Select mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ListTile(
            leading: Icon(currentMode == ProMode.comp ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            title: const Text('COMP — General calculation'),
            subtitle: const Text('Trig, log, power, factorial, combinatorics, fractions.'),
            onTap: () {
              onSelect(ProMode.comp);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(currentMode == ProMode.complex ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            title: const Text('CMPLX — Complex numbers'),
            subtitle: const Text('Format the result as a complex number.'),
            onTap: () {
              onSelect(ProMode.complex);
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.grid_on),
            title: const Text('MATRIX'),
            subtitle: const Text('Opens the Advanced Matrix tool.'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/matrix');
            },
          ),
          ListTile(
            leading: const Icon(Icons.functions),
            title: const Text('EQUATION'),
            subtitle: const Text('Opens the Advanced Equation solver.'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/equation');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
