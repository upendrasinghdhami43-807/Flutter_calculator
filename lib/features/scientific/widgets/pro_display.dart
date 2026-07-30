import 'package:flutter/material.dart';

/// The Pro-mode calculation display with a premium fx-991EX look:
/// multi-line expression with auto-scrolling, large result, status chips
/// for memory and angle unit, and error highlighting.
class ProDisplay extends StatelessWidget {
  const ProDisplay({
    required this.expression,
    required this.result,
    required this.error,
    required this.hasMemory,
    this.angleLabel,
    super.key,
  });

  final String expression;
  final String result;
  final String? error;
  final bool hasMemory;
  final String? angleLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: 'Pro calculator display',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceContainerLow,
              colors.surfaceContainerLowest,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error == null ? colors.outlineVariant : colors.error,
            width: error == null ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Status row
            Row(
              children: [
                if (hasMemory)
                  _StatusChip(label: 'M', color: colors.tertiary),
                if (hasMemory && angleLabel != null)
                  const SizedBox(width: 6),
                if (angleLabel != null)
                  _StatusChip(label: angleLabel!, color: colors.secondary),
                const Spacer(),
              ],
            ),
            if (hasMemory || angleLabel != null)
              const SizedBox(height: 4),
            // Expression
            SizedBox(
              height: 32,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression.isEmpty ? '0' : expression,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                    color: colors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const Divider(height: 12),
            // Result
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  error ?? result,
                  textAlign: TextAlign.end,
                  style: textTheme.headlineMedium?.copyWith(
                    color: error == null ? colors.primary : colors.error,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
