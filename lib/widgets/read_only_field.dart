import 'package:flutter/material.dart';
import 'section_header.dart';

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(label: label),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
