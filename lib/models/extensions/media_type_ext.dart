import 'package:flutter/material.dart';
import '../../services/database/converters.dart';
import '../../l10n/l10n_extension.dart';

extension MediaTypeExt on MediaType {
  String label(BuildContext context) {
    switch (this) {
      case MediaType.reading: return context.l10n.mediaTypeReading;
      case MediaType.audio: return context.l10n.mediaTypeAudio;
      case MediaType.both: return context.l10n.mediaTypeBoth;
    }
  }

  IconData get icon {
    switch (this) {
      case MediaType.reading: return Icons.menu_book_outlined;
      case MediaType.audio: return Icons.headphones_outlined;
      case MediaType.both: return Icons.auto_stories_outlined;
    }
  }
}
