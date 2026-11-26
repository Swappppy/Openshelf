import '../services/database.dart';
import 'pagination_helper.dart';

/// Progress of a book in the medium it is consumed in, as a pair of
/// integers in that medium's unit (pages or seconds).
class MediaProgress {
  final int current;
  final int total;
  final ReadingMedium medium;

  const MediaProgress(this.current, this.total, this.medium);

  double get fraction => total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
  bool get isAudio => medium == ReadingMedium.audio;

  /// Audio progress of [book]: the active read's audio pointer, or the full
  /// duration once the book is read. Null without a known duration.
  static MediaProgress? audio(Book book, List<ReadHistoryData> history, AudiobookInfoData? info) {
    final duration = info?.durationSeconds ?? 0;
    if (duration <= 0) return null;
    if (book.status == ReadingStatus.read) return MediaProgress(duration, duration, ReadingMedium.audio);
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final active = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final entry = history.where((h) => h.readNumber == active).firstOrNull;
    return MediaProgress((entry?.audioProgress ?? 0).clamp(0, duration), duration, ReadingMedium.audio);
  }
}

/// Unit shown next to every duration (hours).
const durationUnit = 'h';

/// Formats seconds as `hh:mm` (or `hh:mm:ss` with [withSeconds]).
String formatDuration(int seconds, {bool withSeconds = false}) {
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return withSeconds ? '$h:$m:$s' : '$h:$m';
}

/// Parses `h:mm:ss`, `h:mm` or a bare number of hours (`10` = 10:00) into seconds.
/// Returns null for anything else (including minutes/seconds above 59).
int? parseDuration(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final parts = text.split(':');
  if (parts.length > 3 || parts.any((p) => p.isEmpty)) return null;
  final nums = parts.map(int.tryParse).toList();
  if (nums.any((n) => n == null || n < 0)) return null;
  final v = nums.cast<int>();
  switch (v.length) {
    case 1:
      return v[0] * 3600;
    case 2:
      if (v[1] > 59) return null;
      return v[0] * 3600 + v[1] * 60;
    default:
      if (v[1] > 59 || v[2] > 59) return null;
      return v[0] * 3600 + v[1] * 60 + v[2];
  }
}
