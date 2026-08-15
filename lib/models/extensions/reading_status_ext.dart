import 'package:flutter/material.dart';
import '../../services/database/converters.dart';
import '../../l10n/l10n_extension.dart';

extension ReadingStatusExt on ReadingStatus {
  String label(BuildContext context) {
    switch (this) {
      case ReadingStatus.wantToRead: return context.l10n.statusWantToRead;
      case ReadingStatus.reading: return context.l10n.statusReading;
      case ReadingStatus.read: return context.l10n.statusRead;
      case ReadingStatus.abandoned: return context.l10n.statusAbandoned;
      case ReadingStatus.paused: return context.l10n.statusPaused;
    }
  }

  IconData get icon {
    switch (this) {
      case ReadingStatus.wantToRead: return Icons.bookmark_outline;
      case ReadingStatus.reading: return Icons.auto_stories;
      case ReadingStatus.read: return Icons.check_circle_outline;
      case ReadingStatus.abandoned: return Icons.close;
      case ReadingStatus.paused: return Icons.pause_circle_outline;
    }
  }

  Color get color {
    switch (this) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.abandoned: return Colors.red;
      case ReadingStatus.paused: return const Color(0xFFB39DDB);
    }
  }
}
