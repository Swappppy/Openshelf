import 'package:flutter/material.dart';

class ImprintPlaceholder extends StatelessWidget {
  final double size;
  final double iconSize;
  final String? name;

  const ImprintPlaceholder({
    super.key,
    this.size = 80,
    this.iconSize = 32,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (name != null && name!.isNotEmpty) {
      final initials = name!
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .take(3)
          .map((w) => w[0].toUpperCase())
          .join();
      content = Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: size * 0.35,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      content = Icon(
        Icons.business_outlined,
        size: iconSize,
        color: colorScheme.outline,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
