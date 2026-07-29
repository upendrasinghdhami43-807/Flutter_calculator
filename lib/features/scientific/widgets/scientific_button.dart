import 'package:flutter/material.dart';

/// A single Pro-mode keypad key. Shows the primary label plus, when
/// present, a small SHIFT label (top-left) and ALPHA label (top-right) so
/// the user can see what pressing the key does in each mode — the actual
/// dispatch between primary/shift/alpha behavior is decided by the caller
/// via [onTap], which already knows the controller's current shift/alpha
/// state.
class ScientificKey extends StatelessWidget {
  const ScientificKey({required this.label, required this.onTap, this.shiftLabel, this.alphaLabel, this.isAccent = false, super.key});

  final String label;
  final String? shiftLabel;
  final String? alphaLabel;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isAccent ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (shiftLabel != null)
                  Positioned(top: 0, left: 3, child: Text(shiftLabel!, style: TextStyle(fontSize: 9, color: colors.tertiary))),
                if (alphaLabel != null)
                  Positioned(top: 0, right: 3, child: Text(alphaLabel!, style: TextStyle(fontSize: 9, color: colors.error))),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isAccent ? colors.onPrimary : colors.onSurface,
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
