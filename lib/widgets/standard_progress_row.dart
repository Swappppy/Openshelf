import 'package:flutter/material.dart';

class StandardProgressRow extends StatelessWidget {
  final int readCount;
  final int totalCount;
  final double progress;

  const StandardProgressRow({
    super.key,
    required this.readCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
          backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          '$readCount / $totalCount libros leídos',
          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9),
        ),
      ],
    );
  }
}
