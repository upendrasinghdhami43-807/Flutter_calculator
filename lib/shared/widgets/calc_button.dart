import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  const CalcButton({
    required this.label,
    required this.onPressed,
    this.isAccent = false,
    this.isMuted = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isAccent;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isAccent
        ? colors.primary
        : isMuted
            ? colors.secondaryContainer
            : colors.surfaceContainerHighest;
    final foreground = isAccent
        ? colors.onPrimary
        : isMuted
            ? colors.onSecondaryContainer
            : colors.onSurface;
    return SizedBox.expand(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.all(4),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
