import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({required this.expression, required this.result, required this.error, super.key});

  final String expression;
  final String result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Calculator display',
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
            Text(expression.isEmpty ? '0' : expression, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              error ?? result,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: error == null ? colors.primary : colors.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
