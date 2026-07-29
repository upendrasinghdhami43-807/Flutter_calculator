import 'package:flutter/material.dart';

import '../scientific_controller.dart';

/// The long-tail SHIFT-function "Tools" bottom sheet: GCD/LCM/floor/ceil and
/// variable store/recall (A/B/C). This is a deliberate, flagged
/// consolidation of the many individual shift-function grid slots the fx-991
/// hardware layout dedicates a physical key to — on a phone screen those are
/// folded into one sheet instead of a literal 8×6 button grid.
class ToolsSheet extends StatelessWidget {
  const ToolsSheet({required this.controller, super.key});

  final ScientificController controller;

  static Future<void> show(BuildContext context, ScientificController controller) {
    return showModalBottomSheet(context: context, builder: (_) => ToolsSheet(controller: controller));
  }

  @override
  Widget build(BuildContext context) {
    void insertAndClose(String text) {
      controller.input(text);
      Navigator.of(context).pop();
    }

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ListTile(leading: const Icon(Icons.calculate), title: const Text('GCD(a, b)'), onTap: () => insertAndClose('gcd(')),
          ListTile(leading: const Icon(Icons.calculate_outlined), title: const Text('LCM(a, b)'), onTap: () => insertAndClose('lcm(')),
          ListTile(leading: const Icon(Icons.south), title: const Text('Floor'), onTap: () => insertAndClose('floor(')),
          ListTile(leading: const Icon(Icons.north), title: const Text('Ceiling'), onTap: () => insertAndClose('ceil(')),
          ListTile(leading: const Icon(Icons.filter_3), title: const Text('nPr(n, r)'), onTap: () => insertAndClose('npr(')),
          ListTile(leading: const Icon(Icons.filter_2), title: const Text('nCr(n, r)'), onTap: () => insertAndClose('ncr(')),
          const Divider(),
          for (final variable in const ['a', 'b', 'c'])
            ListTile(
              leading: const Icon(Icons.save_outlined),
              title: Text('Store answer to ${variable.toUpperCase()}'),
              trailing: TextButton(
                onPressed: () {
                  controller.recallVariable(variable);
                  Navigator.of(context).pop();
                },
                child: Text('Recall $variable'.toUpperCase()),
              ),
              onTap: () {
                controller.storeVariable(variable);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
