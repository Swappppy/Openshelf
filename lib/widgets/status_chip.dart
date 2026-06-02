import 'package:flutter/material.dart';
import '../services/database.dart';
import '../l10n/l10n_extension.dart';

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
    final color = _color(status);
    final label = _label(context, status);

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

  String _label(BuildContext context, ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return context.l10n.statusWantToRead;
      case ReadingStatus.reading:
        return context.l10n.statusReading;
      case ReadingStatus.read:
        return context.l10n.statusRead;
      case ReadingStatus.abandoned:
        return context.l10n.statusAbandoned;
      case ReadingStatus.paused:
        return context.l10n.statusPaused;
    }
  }

  Color _color(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return Colors.orange;
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.read:
        return Colors.green;
      case ReadingStatus.abandoned:
        return Colors.red;
      case ReadingStatus.paused:
        return const Color(0xFFB39DDB);
    }
  }
}
