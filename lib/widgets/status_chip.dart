import 'package:flutter/material.dart';
import '../services/database.dart';
import '../l10n/l10n_extension.dart';

class StatusChip extends StatelessWidget {
  final ReadingStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          _label(context, status),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
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
    }
  }
}