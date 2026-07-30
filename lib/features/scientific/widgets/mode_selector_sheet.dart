import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../scientific_controller.dart';

/// The MODE bottom sheet. COMP and Complex are handled directly in Pro
/// mode; advanced tools route to their dedicated screens.
class ModeSelectorSheet extends StatelessWidget {
  const ModeSelectorSheet({required this.currentMode, required this.onSelect, super.key});

  final ProMode currentMode;
  final ValueChanged<ProMode> onSelect;

  static Future<void> show(BuildContext context, {required ProMode currentMode, required ValueChanged<ProMode> onSelect}) {
    return showModalBottomSheet(context: context, builder: (_) => ModeSelectorSheet(currentMode: currentMode, onSelect: onSelect));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Select Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primary)),
          ),
          // Primary modes
          _ModeItem(
            icon: currentMode == ProMode.comp ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            title: 'COMP — General Calculation',
            subtitle: 'Trig, log, power, factorial, combinatorics, fractions.',
            onTap: () {
              onSelect(ProMode.comp);
              Navigator.of(context).pop();
            },
          ),
          _ModeItem(
            icon: currentMode == ProMode.complex ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            title: 'CMPLX — Complex Numbers',
            subtitle: 'Format the result as a complex number.',
            onTap: () {
              onSelect(ProMode.complex);
              Navigator.of(context).pop();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Advanced Tools', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
          ),
          _ModeItem(
            icon: Icons.grid_on,
            title: 'MATRIX',
            subtitle: 'Determinant, inverse, rank, eigenvalues.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/matrix');
            },
          ),
          _ModeItem(
            icon: Icons.functions,
            title: 'EQUATION',
            subtitle: 'Polynomial roots and linear systems.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/equation');
            },
          ),
          _ModeItem(
            icon: Icons.area_chart_outlined,
            title: 'CALCULUS',
            subtitle: 'Derivatives, integrals, roots, and limits.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/calculus');
            },
          ),
          _ModeItem(
            icon: Icons.show_chart,
            title: 'GRAPH',
            subtitle: 'Function graphs and conic sections.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/graph-finder');
            },
          ),
          _ModeItem(
            icon: Icons.account_tree_outlined,
            title: 'LPP',
            subtitle: 'Linear programming problems.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/lpp');
            },
          ),
          _ModeItem(
            icon: Icons.view_in_ar_outlined,
            title: '3D GRAPH',
            subtitle: 'Three-dimensional surfaces and shapes.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/advanced/graph-3d');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  const _ModeItem({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}
