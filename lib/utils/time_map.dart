import '../services/database.dart';

/// Correspondence between page positions and audio time for a mixed book.
///
/// Positions are "covered" units: page position `p` means pages 1..p are
/// behind (0 = the start, totalPages = the end); time is in seconds.
/// The map is piecewise linear between anchors: the two ends of the book
/// plus every section boundary or marker whose time the user has set.
/// Between two anchors the proportion is local, so an error in one stretch
/// (front matter, notes, credits) never spreads to the rest of the book.
class TimeMap {
  final int totalPages;
  final int duration;

  /// Sorted (page position, seconds) anchors, strictly increasing in both.
  final List<(int, int)> anchors;

  TimeMap._(this.totalPages, this.duration, this.anchors);

  factory TimeMap({
    required int totalPages,
    required int duration,
    List<PaginationSegment> segments = const [],
    List<PaginationMarker> markers = const [],
  }) {
    final raw = <(int, int)>[
      for (final s in segments) ...[
        if (s.startSeconds != null) (s.startPhysical - 1, s.startSeconds!),
        if (s.endSeconds != null) (s.endPhysical, s.endSeconds!),
      ],
      for (final m in markers)
        if (m.seconds != null) (m.physicalPage - 1, m.seconds!),
    ]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));

    // Keep anchors inside the book and monotonic in both axes; a
    // contradictory anchor (later page, earlier time) is ignored.
    final anchors = <(int, int)>[(0, 0)];
    for (final a in raw) {
      final last = anchors.last;
      if (a.$1 <= last.$1 || a.$2 <= last.$2) continue;
      if (a.$1 >= totalPages || a.$2 >= duration) continue;
      anchors.add(a);
    }
    anchors.add((totalPages, duration));
    return TimeMap._(totalPages, duration, anchors);
  }

  bool get isValid => totalPages > 0 && duration > 0;

  /// Seconds that correspond to page position [page].
  int toSeconds(int page) => _interpolate(page.clamp(0, totalPages), (a) => a.$1, (a) => a.$2);

  /// Page position that corresponds to [seconds].
  int toPages(int seconds) => _interpolate(seconds.clamp(0, duration), (a) => a.$2, (a) => a.$1);

  int _interpolate(int x, int Function((int, int)) from, int Function((int, int)) to) {
    if (!isValid) return 0;
    for (var i = 1; i < anchors.length; i++) {
      final a = anchors[i - 1], b = anchors[i];
      if (x <= from(b)) {
        final span = from(b) - from(a);
        if (span <= 0) return to(a);
        return (to(a) + (x - from(a)) * (to(b) - to(a)) / span).round();
      }
    }
    return to(anchors.last);
  }

  /// Time range of [segment]: its anchors where set, interpolated otherwise.
  (int, int) segmentSeconds(PaginationSegment segment) => (
        segment.startSeconds ?? toSeconds(segment.startPhysical - 1),
        segment.endSeconds ?? toSeconds(segment.endPhysical),
      );

  /// Audio position of [marker]: its anchor or the interpolated page.
  int markerSeconds(PaginationMarker marker) => marker.seconds ?? toSeconds(marker.physicalPage - 1);
}

/// Audio sections of [book] in seconds, as segments whose "physical" range is
/// time (`startPhysical = startSecond + 1`, `endPhysical = endSecond`), so the
/// page widgets and helpers can draw and pick them unchanged. A mixed book
/// shares its page sections (mapped with [TimeMap]); a plain audiobook uses
/// its own [audioConfig] (stored in AudiobookInfo); otherwise one section
/// spans the whole duration.
List<PaginationSegment> audioSegmentsFor(Book book, int duration, {PaginationConfig? audioConfig}) {
  final whole = [PaginationSegment(startPhysical: 1, endPhysical: duration, type: PageNumberingType.arabic)];
  if (book.mediaType == MediaType.audio) {
    final own = audioConfig?.segments ?? const <PaginationSegment>[];
    if (own.isEmpty || duration <= 0) return whole;
    return [
      for (final s in own)
        if (s.startPhysical - 1 < duration)
          s.copyWith(endPhysical: s.endPhysical > duration ? duration : s.endPhysical),
    ];
  }
  final segments = book.paginationConfig?.segments ?? const <PaginationSegment>[];
  final pages = book.totalPages ?? 0;
  if (book.mediaType != MediaType.both || segments.isEmpty || pages <= 0 || duration <= 0) {
    return whole;
  }
  final map = TimeMap(totalPages: pages, duration: duration, segments: segments, markers: book.paginationConfig!.markers);
  return [
    for (final s in segments)
      () {
        final (start, end) = map.segmentSeconds(s);
        return PaginationSegment(
          startPhysical: start + 1,
          endPhysical: end < start ? start : end,
          type: PageNumberingType.arabic,
          label: s.label,
          color: s.color,
        );
      }(),
  ];
}

/// Markers positioned in the audio (seconds, same convention): a plain
/// audiobook's own ones, or a mixed book's page markers translated.
List<PaginationMarker> audioMarkersFor(Book book, int duration, {PaginationConfig? audioConfig}) {
  if (book.mediaType == MediaType.audio) {
    return [
      for (final m in audioConfig?.markers ?? const <PaginationMarker>[])
        if (m.physicalPage - 1 <= duration) m,
    ];
  }
  final config = book.paginationConfig;
  final pages = book.totalPages ?? 0;
  if (book.mediaType != MediaType.both || config == null || config.markers.isEmpty || pages <= 0 || duration <= 0) {
    return const [];
  }
  final map = TimeMap(totalPages: pages, duration: duration, segments: config.segments, markers: config.markers);
  return [
    for (final m in config.markers)
      PaginationMarker(physicalPage: map.markerSeconds(m) + 1, label: m.label, color: m.color),
  ];
}

/// Runs to log when progress changes section by section. [sections] are the
/// `[start, end)` bounds of each section in absolute positions; progress maps
/// hold what is covered from each section's start. A section is resumed from
/// its previous progress, except the one containing [startAt] (mixed mode
/// hand-off), whose run starts there. Each changed section yields one run,
/// so sections read out of order are drawn where they really are.
List<({int start, int delta, int section})> sectionRuns({
  required List<(int, int)> sections,
  required Map<int, int> oldProgress,
  required Map<int, int> newProgress,
  int? startAt,
}) {
  final runs = <({int start, int delta, int section})>[];
  for (var i = 0; i < sections.length; i++) {
    final (base, end) = sections[i];
    final oldV = oldProgress[i] ?? 0;
    final newV = newProgress[i] ?? 0;
    final newEnd = base + newV;
    final handOff = startAt != null && startAt >= base && startAt <= end && startAt <= newEnd;
    final start = handOff ? startAt : base + oldV;
    final delta = newEnd - start;
    if (delta != 0 && (handOff || newV != oldV)) runs.add((start: start, delta: delta, section: i));
  }
  return runs;
}

/// Mixed -> audio: the shared page sections and markers translated to time
/// (anchors included), as a plain audiobook's own configuration.
PaginationConfig audioConfigFromPages(Book mixedBook, int duration) => PaginationConfig(
      segments: audioSegmentsFor(mixedBook.copyWith(mediaType: MediaType.both), duration),
      markers: audioMarkersFor(mixedBook.copyWith(mediaType: MediaType.both), duration),
    );

/// Audio -> mixed: page sections built from an audiobook's own sections. The
/// audio times are exact, so every boundary becomes a time anchor; the page
/// ranges are a proportional first estimate for the user to adjust.
PaginationConfig pageConfigFromAudio(PaginationConfig audio, {required int totalPages, required int duration}) {
  int toPage(int seconds) => (seconds / duration * totalPages).round();
  final segments = <PaginationSegment>[];
  for (var i = 0; i < audio.segments.length; i++) {
    final s = audio.segments[i];
    final startSecond = s.startPhysical - 1;
    final start = segments.isEmpty ? 1 : segments.last.endPhysical + 1;
    final isLast = i == audio.segments.length - 1;
    var end = isLast ? totalPages : toPage(s.endPhysical);
    if (end < start) end = start;
    if (end > totalPages) end = totalPages;
    if (start > totalPages) break;
    segments.add(PaginationSegment(
      startPhysical: start,
      endPhysical: end,
      type: PageNumberingType.arabic,
      offset: start - 1,
      label: s.label,
      color: s.color,
      startSeconds: startSecond > 0 ? startSecond : null,
      endSeconds: isLast ? null : s.endPhysical,
    ));
  }
  return PaginationConfig(
    segments: segments,
    markers: [
      for (final m in audio.markers)
        PaginationMarker(
          physicalPage: (toPage(m.physicalPage - 1) + 1).clamp(1, totalPages),
          label: m.label,
          color: m.color,
          seconds: m.physicalPage - 1,
        ),
    ],
  );
}

