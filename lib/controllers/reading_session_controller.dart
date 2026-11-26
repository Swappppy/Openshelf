import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'reading_log_controller.dart';
import '../utils/pagination_helper.dart';
import '../utils/time_map.dart';

final readingSessionControllerProvider = Provider((ref) => ReadingSessionController(ref));

class ReadingSessionController {
  final Ref ref;
  ReadingSessionController(this.ref);

  AppDatabase get _db => ref.read(databaseProvider);

  /// Updates the book's current page and intelligently adjusts reading status.
  ///
  /// [startAt] (mixed mode) is where this reading session started, in pages
  /// already covered. The stretch before it was covered by the other medium,
  /// so only `newPage - startAt` is logged, as a run starting at [startAt].
  Future<void> updatePageProgress({
    required Book book,
    required int newPage,
    required Map<int, int> newSegProgress,
    PaginationConfig? newConfig,
    required String Function(int) sectionLabelGetter,
    int? startAt,
  }) => _db.transaction(() => _updatePageProgress(
        book: book,
        newPage: newPage,
        newSegProgress: newSegProgress,
        newConfig: newConfig,
        sectionLabelGetter: sectionLabelGetter,
        startAt: startAt,
      ));

  Future<void> _updatePageProgress({
    required Book book,
    required int newPage,
    required Map<int, int> newSegProgress,
    PaginationConfig? newConfig,
    required String Function(int) sectionLabelGetter,
    int? startAt,
  }) async {
    final total = book.totalPages ?? 0;
    final oldStatus = book.status;

    // Get current completed reads from history
    final history = await _db.readHistoryDao.getHistoryForBook(book.id);
    final completedReads = history.where((h) => h.finishedAt != null).length;
    
    // Determine which session we are updating based on status
    final int sessionIdx = (oldStatus == ReadingStatus.read) ? (completedReads > 0 ? completedReads : 1) : completedReads + 1;

    // 1. Use the new config (which contains the independent session data)
    final PaginationConfig activeConfig = newConfig ?? (book.paginationConfig ?? PaginationConfig());

    // 2. Calculate true total read pages from all segments for the current session
    final currentHistoryEntry = history.firstWhereOrNull((h) => h.readNumber == sessionIdx);
    int oldTotalRead = currentHistoryEntry?.progress ?? 0;
    int newTotalRead = newPage; // Already calculated in SegmentedPagePicker if segments exist

    // Mixed mode: the read is finished while EITHER medium is at its end.
    final audioDone = await _audioFinished(book, currentHistoryEntry);
    final hasAudio = (currentHistoryEntry?.audioProgress ?? 0) > 0;
    // Where this session's run starts (see [startAt]); a start beyond the
    // new page is ignored and treated as a normal correction.
    final runStart = (startAt != null && startAt <= newTotalRead) ? startAt : oldTotalRead;

    bool allSegmentsFinished;
    if (activeConfig.segments.isNotEmpty) {
      allSegmentsFinished = activeConfig.segments.asMap().entries.every((entry) {
        final i = entry.key;
        final s = entry.value;
        final progress = newSegProgress[i] ?? 0;
        return progress >= (s.endPhysical - s.startPhysical + 1);
      });
    } else {
      allSegmentsFinished = (total > 0 && newTotalRead >= total);
    }

    ReadingStatus newStatus = oldStatus;
    DateTime? newFinishedAt = book.finishedAt;
    DateTime? newStartedAt = book.startedAt;
    int targetPage = newTotalRead; // Use the sum of pages read in the session

    if (newTotalRead == 0 && !hasAudio) {
      // Resetting progress to 0 undoes the session being edited. The book then
      // reflects whatever reads remain (e.g. an earlier completed read keeps
      // it as "read") instead of always becoming "want to read".
      await _db.readHistoryDao.deleteReadByNumber(book.id, sessionIdx);
      final remaining = await _db.readHistoryDao.getHistoryForBook(book.id);
      final derived = _stateFromHistory(book, remaining);
      newStatus = derived.status;
      newStartedAt = derived.startedAt;
      newFinishedAt = derived.finishedAt;
      targetPage = derived.currentPage;
    } else if (allSegmentsFinished) {
      // Automatic completion: Transition to 'Read' status
      if (oldStatus != ReadingStatus.read) {
        newStatus = ReadingStatus.read;
        newFinishedAt = DateTime.now();
        targetPage = total; // Cap current page to total
        
        // Update ReadHistory entries
        if (currentHistoryEntry != null) {
          await _db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
            finishedAt: Value(newFinishedAt),
            progress: newTotalRead,
            segmentProgress: Value(newSegProgress),
          ));
        } else {
          await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
            bookId: book.id,
            readNumber: sessionIdx,
            startedAt: Value(newStartedAt ?? DateTime.now()),
            finishedAt: Value(newFinishedAt),
            progress: Value(targetPage),
            segmentProgress: Value(newSegProgress),
          ));
        }
      } else if (currentHistoryEntry != null && book.mediaType == MediaType.both) {
        // Already finished by the audio side: just record the pages.
        await _db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
          progress: newTotalRead,
          segmentProgress: Value(newSegProgress),
        ));
      }
    } else {
      if (oldStatus == ReadingStatus.read) {
        // If we were at 100% and reduced progress in ANY section. In mixed
        // mode the read stays finished while the audio is complete.
        if (newTotalRead < total && !audioDone) {
          newStatus = ReadingStatus.reading;
          newFinishedAt = null;

          // Sync ReadHistory: remove finishedAt from the session that was just "unfinished"
          if (currentHistoryEntry != null) {
             await _db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
               finishedAt: const Value(null),
               progress: newTotalRead,
               segmentProgress: Value(newSegProgress),
             ));
          }
        } else if (audioDone && currentHistoryEntry != null) {
          // Still finished (audio complete); the page pointer just moves.
          await _db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
            progress: newTotalRead,
            segmentProgress: Value(newSegProgress),
          ));
        }
      } else if (oldStatus == ReadingStatus.wantToRead || oldStatus == ReadingStatus.abandoned || oldStatus == ReadingStatus.paused || (oldStatus == ReadingStatus.reading && oldTotalRead == 0)) {
        // If we move from 0 (or inactive status) to something in any section, start the reading session logic
        if (newTotalRead > 0) {
          newStatus = ReadingStatus.reading;
          if (newStartedAt == null) {
            newStartedAt = DateTime.now();
            
            final existing = await _db.readHistoryDao.getRead(book.id, sessionIdx);
            if (existing == null) {
              await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
                bookId: book.id,
                readNumber: sessionIdx,
                startedAt: Value(newStartedAt),
                finishedAt: const Value(null),
                progress: Value(newTotalRead),
                segmentProgress: Value(newSegProgress),
              ));
            } else {
               await _db.readHistoryDao.updateRead(existing.copyWith(
                 progress: newTotalRead,
                 segmentProgress: Value(newSegProgress),
               ));
            }
          } else {
             final existing = await _db.readHistoryDao.getRead(book.id, sessionIdx);
             if (existing != null) {
                await _db.readHistoryDao.updateRead(existing.copyWith(
                  progress: newTotalRead,
                  segmentProgress: Value(newSegProgress),
                ));
             }
          }
        }
      } else {
         // Reading status, just update progress
         final existing = await _db.readHistoryDao.getRead(book.id, sessionIdx);
         if (existing != null) {
            await _db.readHistoryDao.updateRead(existing.copyWith(
              progress: newTotalRead,
              segmentProgress: Value(newSegProgress),
            ));
         }
      }
    }

    final updated = book.copyWith(
      currentPage: Value(targetPage),
      status: newStatus,
      paginationConfig: Value(activeConfig),
      finishedAt: Value(newFinishedAt),
      startedAt: Value(newStartedAt),
    );

    await _db.bookDao.updateBook(updated);

    if (book.mediaType == MediaType.both) {
      // Mixed mode: one run per changed section, at its real position, so
      // the two media stay complementary even with sections read out of order.
      final segs = activeConfig.segments;
      await _logRuns(
        book.id,
        sessionIdx,
        ReadingMedium.text,
        sectionRuns(
          sections: segs.isEmpty ? [(0, total)] : [for (final s in segs) (s.startPhysical - 1, s.endPhysical)],
          oldProgress: segs.isEmpty ? {0: oldTotalRead} : (currentHistoryEntry?.segmentProgress ?? const {}),
          newProgress: segs.isEmpty ? {0: newTotalRead} : newSegProgress,
          startAt: startAt,
        ),
        (i) => segs.isEmpty ? null : (segs[i].label ?? sectionLabelGetter(i + 1)),
      );
    } else if (newTotalRead != runStart) {
      // Determine which sections changed
      final changedSectionLabels = <String>[];
      if (activeConfig.segments.isNotEmpty && book.paginationConfig != null) {
        final Map<int, int> oldSegProgress = currentHistoryEntry?.segmentProgress ?? {};

        for (int i = 0; i < activeConfig.segments.length; i++) {
          final newSeg = activeConfig.segments[i];
          final newVal = newSegProgress[i] ?? 0;
          final oldVal = oldSegProgress[i] ?? 0;
          
          if (newVal != oldVal) {
            changedSectionLabels.add(newSeg.label ?? sectionLabelGetter(i + 1));
          }
        }
      }

      await ref.read(readingLogControllerProvider.notifier).logPages(
        book.id, 
        newTotalRead - runStart,
        sections: changedSectionLabels.isEmpty ? null : changedSectionLabels,
        readNumber: sessionIdx,
        startPosition: runStart,
      );
    }
  }

  /// Audio counterpart of [updatePageProgress]. [newSegProgress] holds the
  /// seconds covered from the start of each audio section (see
  /// `audioSegmentsFor`; a single section for a plain audiobook), and status,
  /// history and the listening log follow the same rules as pages.
  ///
  /// [startAt] (mixed mode) is where this listening session started, as an
  /// absolute second; see [updatePageProgress].
  Future<void> updateAudioProgress({
    required Book book,
    required Map<int, int> newSegProgress,
    required int duration,
    int? startAt,
    String Function(int)? sectionLabelGetter,
  }) => _db.transaction(() async {
        final audioConfig = (await _db.audiobookInfoDao.getForBook(book.id))?.paginationConfig;
        final sections = audioSegmentsFor(book, duration, audioConfig: audioConfig);
        final bounds = [for (final s in sections) (s.startPhysical - 1, s.endPhysical)];
        final lengths = [for (final b in bounds) b.$2 - b.$1];
        final segProgress = {
          for (var i = 0; i < sections.length; i++) i: (newSegProgress[i] ?? 0).clamp(0, lengths[i] < 0 ? 0 : lengths[i]),
        };
        final position = segProgress.values.fold(0, (a, b) => a + b);
        final allFull = duration > 0 && [for (var i = 0; i < lengths.length; i++) segProgress[i]! >= lengths[i]].every((f) => f);

        final oldStatus = book.status;
        final history = await _db.readHistoryDao.getHistoryForBook(book.id);
        final completedReads = history.where((h) => h.finishedAt != null).length;
        final sessionIdx = (oldStatus == ReadingStatus.read) ? (completedReads > 0 ? completedReads : 1) : completedReads + 1;
        final entry = history.firstWhereOrNull((h) => h.readNumber == sessionIdx);
        final oldPosition = entry?.audioProgress ?? 0;
        final oldSegProgress = entry?.audioSegmentProgress ?? (sections.length == 1 ? {0: oldPosition} : const <int, int>{});
        // Mixed mode: the reading side may already complete the read.
        final pagesDone = book.mediaType == MediaType.both &&
            (book.totalPages ?? 0) > 0 &&
            (entry?.progress ?? 0) >= book.totalPages!;

        var newStatus = oldStatus;
        DateTime? newStartedAt = book.startedAt;
        DateTime? newFinishedAt = book.finishedAt;

        if (position == 0 && (entry?.progress ?? 0) == 0) {
          // Back to zero with no reading progress either: undo this read.
          await _db.readHistoryDao.deleteReadByNumber(book.id, sessionIdx);
          final derived = _stateFromHistory(book, await _db.readHistoryDao.getHistoryForBook(book.id));
          newStatus = derived.status;
          newStartedAt = derived.startedAt;
          newFinishedAt = derived.finishedAt;
        } else if (allFull) {
          if (oldStatus != ReadingStatus.read) {
            newStatus = ReadingStatus.read;
            newFinishedAt = DateTime.now();
          }
          newStartedAt ??= DateTime.now();
          await _upsertAudioRead(book.id, sessionIdx, entry, position, segProgress,
              startedAt: newStartedAt, finishedAt: newFinishedAt);
        } else {
          if (pagesDone) {
            // Finished by the reading side; the audio pointer just moves.
          } else if (oldStatus == ReadingStatus.read) {
            newStatus = ReadingStatus.reading;
            newFinishedAt = null;
          } else if (oldStatus != ReadingStatus.reading || oldPosition == 0) {
            newStatus = ReadingStatus.reading;
          }
          newStartedAt ??= DateTime.now();
          await _upsertAudioRead(book.id, sessionIdx, entry, position, segProgress,
              startedAt: newStartedAt, finishedAt: pagesDone ? entry?.finishedAt : null);
        }

        await _db.bookDao.updateBook(book.copyWith(
          status: newStatus,
          startedAt: Value(newStartedAt),
          finishedAt: Value(newFinishedAt),
        ));

        await _logRuns(
          book.id,
          sessionIdx,
          ReadingMedium.audio,
          sectionRuns(sections: bounds, oldProgress: oldSegProgress, newProgress: segProgress, startAt: startAt),
          (i) => sections.length == 1 ? null : (sections[i].label ?? sectionLabelGetter?.call(i + 1)),
        );
      });

  /// Logs each run as its own entry (see `sectionRuns`). Decreases carry no
  /// start, so they reduce the latest entry instead of creating a run.
  Future<void> _logRuns(int bookId, int readNumber, ReadingMedium medium,
      List<({int start, int delta, int section})> runs, String? Function(int section) label) async {
    for (final r in runs) {
      final l = label(r.section);
      await ref.read(readingLogControllerProvider.notifier).logPages(
        bookId,
        r.delta,
        sections: l == null ? null : [l],
        readNumber: readNumber,
        medium: medium,
        startPosition: r.delta > 0 ? r.start : null,
      );
    }
  }

  /// Whether the audio side of [entry] is complete (mixed mode only).
  Future<bool> _audioFinished(Book book, ReadHistoryData? entry) async {
    if (book.mediaType != MediaType.both || entry == null) return false;
    final duration = (await _db.audiobookInfoDao.getForBook(book.id))?.durationSeconds ?? 0;
    return duration > 0 && entry.audioProgress >= duration;
  }

  /// Latest log entry of the active read of [book]: its medium decides
  /// whether a new session needs a starting point, and where it ended feeds
  /// the suggested start (mixed mode).
  Future<ReadingLogData?> lastEntryOfActiveRead(Book book) async {
    final history = await _db.readHistoryDao.getHistoryForBook(book.id);
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final readNumber = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    return _db.logDao.lastEntryForRead(book.id, readNumber);
  }

  Future<void> _upsertAudioRead(int bookId, int readNumber, ReadHistoryData? entry, int position,
      Map<int, int> segProgress, {DateTime? startedAt, DateTime? finishedAt}) async {
    if (entry != null) {
      await _db.readHistoryDao.updateRead(entry.copyWith(
        audioProgress: position,
        audioSegmentProgress: Value(segProgress),
        finishedAt: Value(finishedAt),
        startedAt: Value(entry.startedAt ?? startedAt),
      ));
    } else {
      await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: readNumber,
        startedAt: Value(startedAt),
        finishedAt: Value(finishedAt),
        audioProgress: Value(position),
        audioSegmentProgress: Value(segProgress),
      ));
    }
  }

  Future<void> startNewReading({
    required Book book,
    List<int>? selectedIndices,
    required String Function(int) sectionLabelGetter,
  }) async {
    final history = await _db.readHistoryDao.getHistoryForBook(book.id);
    final int newReadNumber = history.isEmpty 
        ? 1 
        : history.map((h) => h.readNumber).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    final bookId = book.id;
    final config = book.paginationConfig;

    if (book.mediaType != MediaType.reading) {
      // A new listen (or mixed read) starts at zero in both media; progress
      // is logged as it advances, in whichever medium comes first.
      await _db.bookDao.updateBook(book.copyWith(
        status: ReadingStatus.reading,
        startedAt: Value(now),
        finishedAt: const Value(null),
      ));
      await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: newReadNumber,
        startedAt: Value(now),
        finishedAt: const Value(null),
      ));
      return;
    }

    // 1. Prepare segments progress
    final newSegProgress = <int, int>{};
    if (book.paginationConfig != null && book.paginationConfig!.segments.isNotEmpty) {
      // Get previous progress from the last history entry
      final lastEntry = history.lastOrNull;
      final Map<int, int> lastSegProgress = lastEntry?.segmentProgress ?? {};

      for (int i = 0; i < book.paginationConfig!.segments.length; i++) {
        bool isReReading = selectedIndices == null || selectedIndices.contains(i);
        if (isReReading) {
          // Reset progress for segments that are part of the new reading session
          bool isFirstReRead = selectedIndices == null ? i == 0 : i == selectedIndices.first;
          newSegProgress[i] = isFirstReRead ? 1 : 0;
        } else {
          // If not re-reading, maintain previous progress
          newSegProgress[i] = lastSegProgress[i] ?? 0;
        }
      }
    }

    // 2. Prepare sessions - total progress for the session.
    int totalReadInNewSess = 0;
    int justReadDelta = 0;
    if (newSegProgress.isNotEmpty) {
      for (int i = 0; i < book.paginationConfig!.segments.length; i++) {
        final val = newSegProgress[i] ?? 0;
        totalReadInNewSess += val;
        final isReReading = selectedIndices == null || selectedIndices.contains(i);
        if (isReReading) {
          justReadDelta += val;
        }
      }
    } else {
      totalReadInNewSess = 1;
      justReadDelta = 1;
    }

    // 3. Update Book
    final updated = book.copyWith(
      currentPage: Value(totalReadInNewSess),
      status: ReadingStatus.reading,
      startedAt: Value(now),
      finishedAt: const Value(null),
    );
    await _db.bookDao.updateBook(updated);

    // 4. Create ReadHistory entry
    final selectedLabels = <String>[];
    if (selectedIndices != null && config != null) {
      for (final idx in selectedIndices) {
        if (idx < config.segments.length) {
          selectedLabels.add(config.segments[idx].label ?? sectionLabelGetter(idx + 1));
        }
      }
    }

    await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
      bookId: bookId,
      readNumber: newReadNumber,
      startedAt: Value(now),
      finishedAt: const Value(null),
      sections: Value(selectedLabels.isEmpty ? null : selectedLabels),
      progress: Value(totalReadInNewSess),
      segmentProgress: Value(newSegProgress.isEmpty ? null : newSegProgress),
    ));

    // 5. Log first page(s) - only the delta actually read by this action.
    if (justReadDelta > 0) {
      await ref.read(readingLogControllerProvider.notifier).logPages(
        bookId, 
        justReadDelta,
        sections: selectedLabels.isEmpty ? null : selectedLabels,
        readNumber: newReadNumber,
        startPosition: totalReadInNewSess - justReadDelta,
      );
    }
  }

  Future<void> updateHistoryEntry(ReadHistoryData history, {DateTime? startedAt, DateTime? finishedAt, int? readNumber}) async {
    await _db.transaction(() async {
      final finishDateChanged = history.finishedAt != finishedAt;
      final targetReadNum = readNumber ?? history.readNumber;

      await _db.readHistoryDao.updateRead(history.copyWith(
        startedAt: Value(startedAt),
        finishedAt: Value(finishedAt),
        readNumber: readNumber,
      ));

      if (finishDateChanged && finishedAt != null) {
        await _db.logDao.moveBackfill(history.bookId, targetReadNum, finishedAt);
      }

      final remaining = await _db.readHistoryDao.getHistoryForBook(history.bookId);
      final book = await _db.bookDao.getBook(history.bookId);
      if (book == null || remaining.isEmpty) return;

      if (book.status == ReadingStatus.read || book.status == ReadingStatus.reading) {
        // Read/reading follow the history (e.g. giving the open read a
        // finish date completes it).
        final derived = _stateFromHistory(book, remaining);
        await _db.bookDao.updateBook(book.copyWith(
          status: derived.status,
          currentPage: Value(derived.currentPage),
          startedAt: Value(derived.startedAt),
          finishedAt: Value(derived.finishedAt),
        ));
      } else {
        // Paused/abandoned/want-to-read keep their status and page; only the
        // book's dates follow its latest read.
        final latest = remaining.last;
        await _db.bookDao.updateBook(book.copyWith(
          startedAt: Value(latest.startedAt),
          finishedAt: Value(latest.finishedAt),
        ));
      }
    });
  }

  Future<void> deleteHistoryEntry(Book book, int readNumber) => _db.transaction(() async {
        await _db.readHistoryDao.deleteReadByNumber(book.id, readNumber);
        await _db.logDao.deleteForRead(book.id, readNumber);

        // Renumber subsequent entries
        final remaining = await _db.readHistoryDao.getHistoryForBook(book.id);
        for (int i = 0; i < remaining.length; i++) {
          final oldNum = remaining[i].readNumber;
          final newNum = i + 1;
          if (oldNum != newNum) {
            await _db.readHistoryDao.updateRead(remaining[i].copyWith(readNumber: newNum));
            await _db.logDao.renumberRead(book.id, oldNum, newNum);
          }
        }

        final derived = _stateFromHistory(book, remaining);
        await _db.bookDao.updateBook(book.copyWith(
          status: derived.status,
          currentPage: Value(derived.currentPage),
          startedAt: Value(derived.startedAt),
          finishedAt: Value(derived.finishedAt),
        ));
      });

  /// Book status implied by its reading history: an unfinished read means
  /// "reading", otherwise the last finished read means "read", otherwise
  /// "want to read".
  ({ReadingStatus status, int currentPage, DateTime? startedAt, DateTime? finishedAt}) _stateFromHistory(
      Book book, List<ReadHistoryData> history) {
    final ongoing = history.lastWhereOrNull((h) => h.finishedAt == null);
    if (ongoing != null) {
      return (status: ReadingStatus.reading, currentPage: ongoing.progress, startedAt: ongoing.startedAt, finishedAt: null);
    }
    final lastFinished = history.lastWhereOrNull((h) => h.finishedAt != null);
    if (lastFinished != null) {
      return (status: ReadingStatus.read, currentPage: book.totalPages ?? 0, startedAt: lastFinished.startedAt, finishedAt: lastFinished.finishedAt);
    }
    return (status: ReadingStatus.wantToRead, currentPage: 0, startedAt: null, finishedAt: null);
  }
}
