import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single Pro-mode keypad key with fx-991EX styling. Shows the primary
/// label plus, when present, a small SHIFT label (top-left, tertiary color)
/// and ALPHA label (top-right, error color). Minimum 44dp touch target.
class ScientificKey extends StatelessWidget {
  const ScientificKey({
    required this.label,
    required this.onTap,
    this.shiftLabel,
    this.alphaLabel,
    this.isAccent = false,
    this.isOperator = false,
    this.span = 1,
    this.fontSize,
    super.key,
  });

  final String label;
  final String? shiftLabel;
  final String? alphaLabel;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isOperator;
  final int span;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = isAccent
        ? colors.primary
        : isOperator
            ? colors.primaryContainer
            : colors.surfaceContainerHighest;
    final fgColor = isAccent
        ? colors.onPrimary
        : isOperator
            ? colors.onPrimaryContainer
            : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        elevation: 1,
        shadowColor: colors.shadow.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (shiftLabel != null)
                  Positioned(
                    top: 0,
                    left: 3,
                    child: Text(
                      shiftLabel!,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: colors.tertiary,
                      ),
                    ),
                  ),
                if (alphaLabel != null)
                  Positioned(
                    top: 0,
                    right: 3,
                    child: Text(
                      alphaLabel!,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: colors.error,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    top: (shiftLabel != null || alphaLabel != null) ? 6 : 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize ?? 15,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
