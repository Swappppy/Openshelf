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

  /// Page progress of [book] (pointer of the active read, or all pages once
  /// read). Null without a page count.
  static MediaProgress? text(Book book, List<ReadHistoryData> history) {
    final total = book.totalPages ?? 0;
    if (total <= 0) return null;
    if (book.mediaType == MediaType.both && book.status == ReadingStatus.read) {
      // May have been finished by listening: show the real page pointer.
      final completed = history.where((h) => h.finishedAt != null).length;
      final active = PaginationHelper.getActiveSessionNumber(book.status, completed);
      final entry = history.where((h) => h.readNumber == active).firstOrNull;
      return MediaProgress((entry?.progress ?? 0).clamp(0, total), total, ReadingMedium.text);
    }
    return MediaProgress(PaginationHelper.getTotalReadPages(book, history), total, ReadingMedium.text);
  }

  /// What a card shows: the medium's own progress, and in mixed mode the
  /// further of the two (each medium resumes past where the other stopped,
  /// so the furthest pointer is how far the work has been covered).
  static MediaProgress? forCard(Book book, List<ReadHistoryData> history, AudiobookInfoData? info) {
    switch (book.mediaType) {
      case MediaType.reading:
        return text(book, history);
      case MediaType.audio:
        return audio(book, history, info);
      case MediaType.both:
        final t = text(book, history);
        final a = audio(book, history, info);
        if (t == null) return a;
        if (a == null) return t;
        return a.fraction > t.fraction ? a : t;
    }
  }

  /// Audio progress of [book]: the active read's audio pointer, or the full
  /// duration once the book is read. Null without a known duration.
  static MediaProgress? audio(Book book, List<ReadHistoryData> history, AudiobookInfoData? info) {
    final duration = info?.durationSeconds ?? 0;
    if (duration <= 0) return null;
    // A finished audiobook is fully listened. A finished mixed book may have
    // been completed by reading, so it shows its real audio pointer.
    if (book.status == ReadingStatus.read && book.mediaType == MediaType.audio) {
      return MediaProgress(duration, duration, ReadingMedium.audio);
    }
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

/// Stretches `[start, end)` covered in [medium] during read [readNumber],
/// rebuilt from the log (each entry is a run starting at its startPosition),
/// merged when they touch or overlap. Entries without a start (older ones, or
/// progress typed in the form) fall back to a single run from 0 to [pointer].
List<(int, int)> coveredRuns({
  required List<ReadingLogData> logs,
  required int readNumber,
  required ReadingMedium medium,
  required int pointer,
}) {
  final entries = logs.where((l) => l.readNumber == readNumber && l.medium == medium && l.pagesRead > 0).toList();
  if (entries.isEmpty || entries.any((l) => l.startPosition == null)) {
    return pointer > 0 ? [(0, pointer)] : const [];
  }
  return mergeRuns(entries.map((l) => (l.startPosition!, l.startPosition! + l.pagesRead)));
}

/// Sorts [runs] and merges the ones that touch or overlap.
List<(int, int)> mergeRuns(Iterable<(int, int)> runs) {
  final sorted = runs.where((r) => r.$2 > r.$1).toList()..sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[];
  for (final r in sorted) {
    if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
      final last = merged.removeLast();
      merged.add((last.$1, r.$2 > last.$2 ? r.$2 : last.$2));
    } else {
      merged.add(r);
    }
  }
  return merged;
}

/// Runs of sections filled from their start: section `i` spans
/// `bounds[i]` = (start, end) and is covered up to `progress[i]`. With
/// [only], just those sections.
List<(int, int)> segmentRuns(List<(int, int)> bounds, Map<int, int>? progress, {Set<int>? only}) => [
      for (var i = 0; i < bounds.length; i++)
        if (only == null || only.contains(i))
          (bounds[i].$1, bounds[i].$1 + (progress?[i] ?? 0).clamp(0, bounds[i].$2 - bounds[i].$1)),
    ];

/// Sections a partial reread carried over from the previous read: those not
/// named in [read]'s sections (labels as written by `startNewReading`).
Set<int> carriedSections(ReadHistoryData? read, List<PaginationSegment> sections, String Function(int) defaultLabel) {
  final chosen = read?.sections;
  if (chosen == null || chosen.isEmpty) return const {};
  return {
    for (var i = 0; i < sections.length; i++)
      if (!chosen.contains(sections[i].label ?? defaultLabel(i + 1))) i,
  };
}
