import 'package:flutter/material.dart';

import '../../../core/expression_engine/evaluator.dart';

/// Compact status/navigation bar for Pro mode — replaces the cluttered
/// AppBar with a clean row of chips and icon actions.
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
      titleSpacing: 8,
      title: Row(
        children: [
          Text('Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              modeLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 6),
          if (shiftActive)
            _StatusDot(label: 'S', color: colors.tertiary),
          if (alphaActive)
            _StatusDot(label: 'A', color: colors.error),
        ],
      ),
      actions: [
        _CompactAction(
          label: _angleUnitLabel,
          onTap: onAngleUnitTap,
          color: colors.secondary,
        ),
        IconButton(
          icon: const Icon(Icons.build_outlined, size: 20),
          tooltip: 'Tools',
          onPressed: onToolsTap,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.tune, size: 20),
          tooltip: 'Mode',
          onPressed: onModeTap,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.history, size: 20),
          tooltip: 'History',
          onPressed: onHistoryTap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: CircleAvatar(
        radius: 10,
        backgroundColor: color,
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({required this.label, required this.onTap, required this.color});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ),
    );
  }
}
