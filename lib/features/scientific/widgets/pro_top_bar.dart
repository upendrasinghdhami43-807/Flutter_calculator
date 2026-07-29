import 'package:flutter/material.dart';

import '../../../core/expression_engine/evaluator.dart';

/// The status/navigation bar for Pro mode: current calculation mode badge,
/// angle unit (tap to cycle), SHIFT/ALPHA active indicators, and quick
/// access to MODE, Tools, and History.
class ProTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ProTopBar({
    required this.modeLabel,
    required this.angleUnit,
    required this.shiftActive,
    required this.alphaActive,
    required this.onAngleUnitTap,
    required this.onModeTap,
    required this.onToolsTap,
    required this.onHistoryTap,
    super.key,
  });

  final String modeLabel;
  final AngleUnit angleUnit;
  final bool shiftActive;
  final bool alphaActive;
  final VoidCallback onAngleUnitTap;
  final VoidCallback onModeTap;
  final VoidCallback onToolsTap;
  final VoidCallback onHistoryTap;

  String get _angleUnitLabel => switch (angleUnit) {
    AngleUnit.degrees => 'DEG',
    AngleUnit.radians => 'RAD',
    AngleUnit.gradians => 'GRAD',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pro'),
          const SizedBox(width: 8),
          Chip(label: Text(modeLabel), visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ],
      ),
      actions: [
        if (shiftActive) Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _Indicator(text: 'S', color: colors.tertiary)),
        if (alphaActive) Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _Indicator(text: 'A', color: colors.error)),
        TextButton(onPressed: onAngleUnitTap, child: Text(_angleUnitLabel)),
        IconButton(icon: const Icon(Icons.build_outlined), tooltip: 'Tools', onPressed: onToolsTap),
        IconButton(icon: const Icon(Icons.tune), tooltip: 'Mode', onPressed: onModeTap),
        IconButton(icon: const Icon(Icons.history), tooltip: 'History', onPressed: onHistoryTap),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 11, backgroundColor: color, child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)));
  }
}
