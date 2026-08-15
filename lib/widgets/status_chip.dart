import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/extensions/reading_status_ext.dart';

/// A styled chip representing the reading status of a book.
/// Supports a full chip style for list views and a compact "dot" style for grid views.
class StatusChip extends StatelessWidget {
  final ReadingStatus status;
  final bool isGrid;

  const StatusChip({
    super.key,
    required this.status,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final label = status.label(context);

    if (isGrid) {
      // Compact style: A colored dot followed by small text.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    }

    // Full style: A pill-shaped background with the label.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
      ),
    );
  }
}

