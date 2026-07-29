import 'package:flutter/material.dart';

/// The Pro-mode calculation display: expression, result/error, and small
/// memory/Ans indicators, matching the visual weight of `ResultDisplay` used
/// in Basic mode but with the extra status chips Pro mode needs.
class ProDisplay extends StatelessWidget {
  const ProDisplay({required this.expression, required this.result, required this.error, required this.hasMemory, super.key});

  final String expression;
  final String result;
  final String? error;
  final bool hasMemory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Pro calculator display',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: error == null ? colors.outlineVariant : colors.error),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasMemory)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('M', style: TextStyle(color: colors.tertiary, fontWeight: FontWeight.bold)),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(expression.isEmpty ? '0' : expression, style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                error ?? result,
                textAlign: TextAlign.end,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: error == null ? colors.primary : colors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
