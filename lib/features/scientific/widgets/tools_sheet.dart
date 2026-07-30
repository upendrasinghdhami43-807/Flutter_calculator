import 'package:flutter/material.dart';

import '../scientific_controller.dart';

/// Tools bottom sheet — comprehensive function access for Pro mode.
/// Groups: Math functions, Conversion, Variable store/recall.
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

    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primary)),
          ),
          // Math functions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Math Functions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.calculate, size: 20),
            title: const Text('GCD(a, b)'),
            subtitle: const Text('Greatest common divisor'),
            onTap: () => insertAndClose('gcd('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.calculate_outlined, size: 20),
            title: const Text('LCM(a, b)'),
            subtitle: const Text('Least common multiple'),
            onTap: () => insertAndClose('lcm('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.south, size: 20),
            title: const Text('floor(x)'),
            subtitle: const Text('Round down to integer'),
            onTap: () => insertAndClose('floor('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.north, size: 20),
            title: const Text('ceil(x)'),
            subtitle: const Text('Round up to integer'),
            onTap: () => insertAndClose('ceil('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.straighten, size: 20),
            title: const Text('|x| — Absolute value'),
            onTap: () => insertAndClose('abs('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.filter_3, size: 20),
            title: const Text('nPr(n, r)'),
            subtitle: const Text('Permutations'),
            onTap: () => insertAndClose('npr('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.filter_2, size: 20),
            title: const Text('nCr(n, r)'),
            subtitle: const Text('Combinations'),
            onTap: () => insertAndClose('ncr('),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.swap_vert, size: 20),
            title: const Text('logb(base, x)'),
            subtitle: const Text('Logarithm with custom base'),
            onTap: () => insertAndClose('logb('),
          ),
          const Divider(),
          // Variable store/recall
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Variable Memory', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
          ),
          for (final variable in const ['a', 'b', 'c', 'd', 'e', 'f'])
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: colors.secondaryContainer,
                child: Text(variable.toUpperCase(), style: TextStyle(fontSize: 12, color: colors.onSecondaryContainer)),
              ),
              title: Text('Store → ${variable.toUpperCase()}'),
              trailing: TextButton(
                onPressed: () {
                  controller.recallVariable(variable);
                  Navigator.of(context).pop();
                },
                child: Text('Recall', style: TextStyle(color: colors.primary)),
              ),
              onTap: () {
                controller.storeVariable(variable);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
