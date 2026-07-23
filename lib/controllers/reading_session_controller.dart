import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'reading_log_controller.dart';

final readingSessionControllerProvider = Provider((ref) => ReadingSessionController(ref));

class ReadingSessionController {
  final Ref ref;
  ReadingSessionController(this.ref);

  AppDatabase get _db => ref.read(databaseProvider);

  /// Updates the book's current page and intelligently adjusts reading status.
  Future<void> updatePageProgress({
    required Book book,
    required int newPage,
    required Map<int, int> newSegProgress,
    PaginationConfig? newConfig,
    required String Function(int) sectionLabelGetter,
  }) async {
    final total = book.totalPages ?? 0;
    final oldStatus = book.status;

    // Get current completed reads from history
    final history = await _db.readHistoryDao.watchHistoryForBook(book.id).first;
    final completedReads = history.where((h) => h.finishedAt != null).length;
    
    // Determine which session we are updating based on status
    final int sessionIdx = (oldStatus == ReadingStatus.read) ? (completedReads > 0 ? completedReads : 1) : completedReads + 1;

    // 1. Use the new config (which contains the independent session data)
    final PaginationConfig activeConfig = newConfig ?? (book.paginationConfig ?? PaginationConfig());

    // 2. Calculate true total read pages from all segments for the current session
    final currentHistoryEntry = history.firstWhereOrNull((h) => h.readNumber == sessionIdx);
    int oldTotalRead = currentHistoryEntry?.progress ?? 0;
    int newTotalRead = newPage; // Already calculated in SegmentedPagePicker if segments exist

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

    if (newTotalRead == 0) {
      newStatus = ReadingStatus.wantToRead;
      newFinishedAt = null;
      newStartedAt = null;

      // Delete the session we just reset to 0 in ReadHistory
      await _db.readHistoryDao.deleteReadByNumber(book.id, sessionIdx);
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
      }
    } else {
      if (oldStatus == ReadingStatus.read) {
        // If we were at 100% and reduced progress in ANY section
        if (newTotalRead < total) {
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

    // Use the delta of true total read pages for the log
    if (newTotalRead != oldTotalRead) {
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
        newTotalRead - oldTotalRead,
        changedSectionLabels.isEmpty ? null : changedSectionLabels,
      );
    }
  }

  Future<void> startNewReading({
    required Book book,
    List<int>? selectedIndices,
    required String Function(int) sectionLabelGetter,
  }) async {
    final history = await _db.readHistoryDao.watchHistoryForBook(book.id).first;
    final int newReadNumber = history.isEmpty 
        ? 1 
        : history.map((h) => h.readNumber).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    final bookId = book.id;
    final config = book.paginationConfig;

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
        selectedLabels.isEmpty ? null : selectedLabels,
      );
    }
  }

  Future<void> updateHistoryEntry(ReadHistoryData history, {DateTime? startedAt, DateTime? finishedAt, int? readNumber}) async {
    await _db.readHistoryDao.updateRead(history.copyWith(
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      readNumber: readNumber,
    ));
  }

  Future<void> deleteHistoryEntry(Book book, int readNumber) async {
    // Delete the entry
    await _db.readHistoryDao.deleteReadByNumber(book.id, readNumber);
    
    // Renumber subsequent entries
    final remainingHistory = await _db.readHistoryDao.watchHistoryForBook(book.id).first;
    
    ReadHistoryData? lastFinished;
    ReadHistoryData? ongoing;

    for (int i = 0; i < remainingHistory.length; i++) {
      final h = remainingHistory[i];
      final newNumber = i + 1;
      
      if (h.readNumber != newNumber) {
        await _db.readHistoryDao.updateRead(h.copyWith(readNumber: newNumber));
      }
      
      if (h.finishedAt != null) {
        lastFinished = h;
      } else {
        ongoing = h;
      }
    }

    // Update the book's status based on remaining history
    ReadingStatus newStatus = book.status;
    int newCurrentPage = 0;
    DateTime? newStartedAt;
    DateTime? newFinishedAt;

    if (ongoing != null) {
      newStatus = ReadingStatus.reading;
      newStartedAt = ongoing.startedAt;
      newFinishedAt = null;
      newCurrentPage = ongoing.progress;
    } else if (lastFinished != null) {
      newStatus = ReadingStatus.read;
      newStartedAt = lastFinished.startedAt;
      newFinishedAt = lastFinished.finishedAt;
      newCurrentPage = book.totalPages ?? 0;
    } else {
      newStatus = ReadingStatus.wantToRead;
      newStartedAt = null;
      newFinishedAt = null;
      newCurrentPage = 0;
    }

    final updated = book.copyWith(
      status: newStatus,
      currentPage: Value(newCurrentPage),
      startedAt: Value(newStartedAt),
      finishedAt: Value(newFinishedAt),
    );
    
    await _db.bookDao.updateBook(updated);
  }
}
