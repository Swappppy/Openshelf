import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const TagChip({
    super.key,
    required this.label,
    this.colorHex,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = colorHex != null
        ? Color(int.parse('0xFF$colorHex'))
        : Theme.of(context).colorScheme.secondaryContainer;
    final textColor = colorHex != null
        ? _contrastColor(baseColor)
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorHex != null ? baseColor : textColor,
                height: 1,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: colorHex != null
                      ? baseColor.withValues(alpha: 0.7)
                      : textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }
}