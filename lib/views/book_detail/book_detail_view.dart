import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/reading_log_controller.dart';
import '../../controllers/book_operations_controller.dart';
import '../../controllers/read_history_controller.dart';
import '../book_form/book_form_view.dart';
import '../../l10n/l10n_extension.dart';
import '../shelves/shelf_books_view.dart';
import '../../widgets/segmented_progress_bar.dart';
import '../../utils/pagination_helper.dart';
import '../../widgets/segmented_page_picker.dart';

/// Comprehensive detailed view for a specific book.
/// Provides access to all metadata, reading progress, and management options (edit/delete).
class BookDetailView extends ConsumerWidget {
  final Book book;
  const BookDetailView({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for real-time updates of this specific book.
    final bookAsync = ref.watch(bookByIdProvider(book.id));

    return bookAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      ),
      data: (current) {
        if (current == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.bookDetailNotFound)),
          );
        }
        return _BookDetailScaffold(book: current);
      },
    );
  }
}

class _BookDetailScaffold extends ConsumerStatefulWidget {
  final Book book;
  const _BookDetailScaffold({required this.book});

  @override
  ConsumerState<_BookDetailScaffold> createState() =>
      _BookDetailScaffoldState();
}

class _BookDetailScaffoldState extends ConsumerState<_BookDetailScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Updates the book's current page and intelligently adjusts reading status.
  Future<void> _updatePage(int newPage, Map<int, int> newSegProgress, [PaginationConfig? newConfig]) async {
    final book = widget.book;
    final total = book.totalPages ?? 0;
    final oldStatus = book.status;
    final l10n = context.l10n; // Capture l10n at the beginning
    final db = ref.read(databaseProvider);

    // Get current completed reads from history
    final history = await db.readHistoryDao.watchHistoryForBook(book.id).first;
    final completedReads = history.where((h) => h.finishedAt != null).length;
    
    // Determine which session we are updating based on status
    final int sessionIdx = (oldStatus == ReadingStatus.read) ? (completedReads > 0 ? completedReads : 1) : completedReads + 1;

    // 1. Use the new config (which contains the independent session data)
    final PaginationConfig activeConfig = newConfig ?? (book.paginationConfig ?? PaginationConfig());

    // 2. Calculate true total read pages from all segments for the current session
    final currentHistoryEntry = history.firstWhereOrNull((h) => h.readNumber == sessionIdx);
    int oldTotalRead = currentHistoryEntry?.progress ?? 0;
    int newTotalRead = newPage; // Already calculated in SegmentedPagePicker if segments exist

    bool allSegmentsFinished = (total > 0 && newTotalRead >= total);

    ReadingStatus newStatus = oldStatus;
    DateTime? newFinishedAt = book.finishedAt;
    DateTime? newStartedAt = book.startedAt;
    int targetPage = newTotalRead; // Use the sum of pages read in the session

    if (newTotalRead == 0) {
      newStatus = ReadingStatus.wantToRead;
      newFinishedAt = null;
      newStartedAt = null;

      // Delete the session we just reset to 0 in ReadHistory
      await db.readHistoryDao.deleteReadByNumber(book.id, sessionIdx);
    } else if (allSegmentsFinished) {
      // Automatic completion: Transition to 'Read' status
      if (oldStatus != ReadingStatus.read) {
        newStatus = ReadingStatus.read;
        newFinishedAt = DateTime.now();
        targetPage = total; // Cap current page to total
        
    // Update ReadHistory entries
    final currentHistoryEntry = history.firstWhereOrNull((h) => h.readNumber == sessionIdx);
    if (currentHistoryEntry != null) {
      await db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
        finishedAt: Value(newFinishedAt),
        progress: newTotalRead,
        segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
      ));
    } else {
       await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
         bookId: book.id,
         readNumber: sessionIdx,
         startedAt: Value(newStartedAt ?? DateTime.now()),
         finishedAt: Value(newFinishedAt),
         progress: Value(targetPage),
         segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
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
             await db.readHistoryDao.updateRead(currentHistoryEntry.copyWith(
               finishedAt: const Value(null),
               progress: newTotalRead,
               segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
             ));
          }
        }
      } else if (oldStatus == ReadingStatus.wantToRead || oldStatus == ReadingStatus.abandoned || oldStatus == ReadingStatus.paused || (oldStatus == ReadingStatus.reading && oldTotalRead == 0)) {
        // If we move from 0 (or inactive status) to something in any section, start the reading session logic
        if (newTotalRead > 0) {
          newStatus = ReadingStatus.reading;
          if (newStartedAt == null) {
            newStartedAt = DateTime.now();
            
            final existing = await db.readHistoryDao.getRead(book.id, sessionIdx);
            if (existing == null) {
              await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
                bookId: book.id,
                readNumber: sessionIdx,
                startedAt: Value(newStartedAt),
                finishedAt: const Value(null),
                progress: Value(newTotalRead),
                segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
              ));
            } else {
               await db.readHistoryDao.updateRead(existing.copyWith(
                 progress: newTotalRead,
                 segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
               ));
            }
          } else {
             final existing = await db.readHistoryDao.getRead(book.id, sessionIdx);
             if (existing != null) {
                await db.readHistoryDao.updateRead(existing.copyWith(
                  progress: newTotalRead,
                  segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
                ));
             }
          }
        }
      } else {
         // Reading status, just update progress
         final existing = await db.readHistoryDao.getRead(book.id, sessionIdx);
         if (existing != null) {
            await db.readHistoryDao.updateRead(existing.copyWith(
              progress: newTotalRead,
              segmentProgress: Value(jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
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

    await ref.read(databaseProvider).bookDao.updateBook(updated);

    // Use the delta of true total read pages for the log
    if (newTotalRead != oldTotalRead) {
      // Determine which sections changed
      final changedSectionLabels = <String>[];
      if (activeConfig.segments.isNotEmpty && book.paginationConfig != null) {
        Map<int, int> oldSegProgress = {};
        if (currentHistoryEntry?.segmentProgress != null) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(currentHistoryEntry!.segmentProgress!);
            oldSegProgress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
          } catch (_) {}
        }

        for (int i = 0; i < activeConfig.segments.length; i++) {
          final newSeg = activeConfig.segments[i];
          final newVal = newSegProgress[i] ?? 0;
          final oldVal = oldSegProgress[i] ?? 0;
          
          if (newVal != oldVal) {
            changedSectionLabels.add(newSeg.label ?? l10n.paginationSectionLabel(i + 1));
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

  Future<void> _startNewReading([List<int>? selectedIndices]) async {
    final l10n = context.l10n; // Capture l10n early
    final book = widget.book;
    final db = ref.read(databaseProvider);
    final history = await db.readHistoryDao.watchHistoryForBook(book.id).first;
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
      Map<int, int> lastSegProgress = {};
      if (lastEntry?.segmentProgress != null) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(lastEntry!.segmentProgress!);
          lastSegProgress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
        } catch (_) {}
      }

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

    // 2. Prepare sessions - total progress for the session
    int totalReadInNewSess = 0;
    if (newSegProgress.isNotEmpty) {
      for (final val in newSegProgress.values) {
        totalReadInNewSess += val;
      }
    } else {
      totalReadInNewSess = 1;
    }

    // 3. Update Book
    final updated = book.copyWith(
      currentPage: Value(totalReadInNewSess),
      status: ReadingStatus.reading,
      startedAt: Value(now),
      finishedAt: const Value(null),
    );
    await ref.read(databaseProvider).bookDao.updateBook(updated);

    // 4. Create ReadHistory entry
    final selectedLabels = <String>[];
    if (selectedIndices != null && config != null) {
      for (final idx in selectedIndices) {
        if (idx < config.segments.length) {
          selectedLabels.add(config.segments[idx].label ?? l10n.paginationSectionLabel(idx + 1));
        }
      }
    }

    await ref.read(databaseProvider).readHistoryDao.insertRead(ReadHistoryCompanion.insert(
      bookId: bookId,
      readNumber: newReadNumber,
      startedAt: Value(now),
      finishedAt: const Value(null),
      sections: Value(selectedLabels.isEmpty ? null : jsonEncode(selectedLabels)),
      progress: Value(totalReadInNewSess),
      segmentProgress: Value(newSegProgress.isEmpty ? null : jsonEncode(newSegProgress.map((k, v) => MapEntry(k.toString(), v)))),
    ));

    // 5. Log first page(s)
    if (totalReadInNewSess > 0) {
      await ref.read(readingLogControllerProvider.notifier).logPages(
        bookId, 
        totalReadInNewSess,
        selectedLabels.isEmpty ? null : selectedLabels,
      );
    }
  }

  void _showStartNewReadingDialog() {
    final book = widget.book;
    final segments = book.paginationConfig?.segments ?? [];

    if (segments.isEmpty) {
      _startNewReading();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        bool selectSections = false;
        final selectedIndices = <int>[];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n.bookDetailStartNewReadingButton),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioGroup<bool>(
                      groupValue: selectSections,
                      onChanged: (v) => setState(() => selectSections = v!),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<bool>(
                            title: Text(context.l10n.bookDetailNewReadingWholeBook),
                            value: false,
                          ),
                          RadioListTile<bool>(
                            title: Text(context.l10n.bookDetailNewReadingSections),
                            value: true,
                          ),
                        ],
                      ),
                    ),
                    if (selectSections) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          context.l10n.bookDetailNewReadingSelectSections,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      ...segments.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return CheckboxListTile(
                          title: Text(s.label ?? 'Sección ${i + 1}'),
                          value: selectedIndices.contains(i),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedIndices.add(i);
                                selectedIndices.sort();
                              } else {
                                selectedIndices.remove(i);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: selectSections && selectedIndices.isEmpty
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _startNewReading(selectSections ? selectedIndices : null);
                        },
                  child: Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateReadHistory(ReadHistoryData history, {DateTime? startedAt, DateTime? finishedAt, int? readNumber}) async {
    final db = ref.read(databaseProvider);
    await db.readHistoryDao.updateRead(history.copyWith(
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      readNumber: readNumber,
    ));
  }

  Future<void> _deleteReadHistory(int readNumber) async {
    final book = widget.book;
    final db = ref.read(databaseProvider);
    
    // Delete the entry
    await db.readHistoryDao.deleteReadByNumber(book.id, readNumber);
    
    // Renumber subsequent entries
    final remainingHistory = await db.readHistoryDao.watchHistoryForBook(book.id).first;
    
    ReadHistoryData? lastFinished;
    ReadHistoryData? ongoing;

    for (int i = 0; i < remainingHistory.length; i++) {
      final h = remainingHistory[i];
      final newNumber = i + 1;
      
      if (h.readNumber != newNumber) {
        await db.readHistoryDao.updateRead(h.copyWith(readNumber: newNumber));
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
    
    await db.bookDao.updateBook(updated);
  }

  void _showEditHistoryDialog(ReadHistoryData h) {
    DateTime? startedAt = h.startedAt;
    DateTime? finishedAt = h.finishedAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.l10n.bookDetailReadEditDialogTitle(h.readNumber)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(context.l10n.bookDetailFieldStarted),
                  subtitle: Text(startedAt != null ? '${startedAt!.day}/${startedAt!.month}/${startedAt!.year}' : '—'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startedAt ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => startedAt = picked);
                  },
                ),
                ListTile(
                  title: Text(context.l10n.bookDetailFieldFinished),
                  subtitle: Text(finishedAt != null ? '${finishedAt!.day}/${finishedAt!.month}/${finishedAt!.year}' : '—'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: finishedAt ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => finishedAt = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
              FilledButton(
                onPressed: () {
                  _updateReadHistory(h, startedAt: startedAt, finishedAt: finishedAt);
                  Navigator.pop(ctx);
                },
                child: Text(context.l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHistoryOptions(ReadHistoryData h) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                _showEditHistoryDialog(h);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.l10n.delete),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: Text(context.l10n.delete),
                    content: Text(context.l10n.bookDetailReadDeleteConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx2), child: Text(context.l10n.cancel)),
                      FilledButton(
                        onPressed: () {
                          _deleteReadHistory(h.readNumber);
                          Navigator.pop(ctx2);
                        },
                        child: Text(context.l10n.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNotes(String notes) async {
    final updated = widget.book.copyWith(notes: Value(notes));
    await ref.read(databaseProvider).bookDao.updateBook(updated);
  }

  void _showPagePicker(BuildContext context) async {
    final book = widget.book;
    if (book.totalPages == null) return;

    final db = ref.read(databaseProvider);
    final history = await db.readHistoryDao.watchHistoryForBook(book.id).first;
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

    if (!context.mounted) return;

    Map<int, int> initialSegProgress = {};
    if (activeSession?.segmentProgress != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(activeSession!.segmentProgress!);
        initialSegProgress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SegmentedPagePicker(
          totalPages: book.totalPages!,
          status: book.status,
          initialProgress: activeSession?.progress ?? 0,
          initialSegmentProgress: initialSegProgress,
          config: book.paginationConfig,
          onSave: (phys, newSegProgress, newConfig) async {
            await _updatePage(phys, newSegProgress, newConfig);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showNotesEditor(BuildContext context) {
    final controller =
    TextEditingController(text: widget.book.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.bookDetailNotesTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.bookDetailNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                _updateNotes(controller.text);
                Navigator.pop(ctx);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookFormView(existingBook: book),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => _confirmDuplicate(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _BookHeader(book: book),
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(icon: const Icon(Icons.menu_book_outlined), text: context.l10n.tabMain),
              Tab(icon: const Icon(Icons.label_outline), text: context.l10n.tabDetails),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MainTab(
                  book: book,
                  onTapPages: () => _showPagePicker(context),
                ),
                _DetailsTab(
                  book: book,
                  onTapNotes: () => _showNotesEditor(context),
                  onStartNewReading: _showStartNewReadingDialog,
                  onLongPressHistory: _showHistoryOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.bookDetailDeleteTitle),
        content: Text(context.l10n.bookDetailDeleteConfirm(widget.book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(databaseProvider).bookDao.deleteBook(widget.book.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to library
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _confirmDuplicate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.bookDetailDuplicateTitle),
        content: Text(context.l10n.bookDetailDuplicateConfirm(widget.book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(bookOperationsProvider).duplicate(widget.book.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text(context.l10n.duplicate),
          ),
        ],
      ),
    );
  }
}

class _BookHeader extends StatelessWidget {
  final Book book;
  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          Hero(
            tag: 'book-cover-${book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverPath != null
                  ? Image.file(
                File(book.coverPath!),
                width: 100,
                height: 150,
                fit: BoxFit.cover,
              )
                  : _CoverPlaceholder(width: 100, height: 150),
            ),
          ),
          const SizedBox(width: 20),
          // Titles and Author
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _StatusChip(status: book.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReadingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ReadingStatus.wantToRead => Colors.orange,
      ReadingStatus.reading => Colors.blue,
      ReadingStatus.read => Colors.green,
      ReadingStatus.abandoned => Colors.red,
      ReadingStatus.paused => Colors.deepPurpleAccent,
    };

    final label = switch (status) {
      ReadingStatus.wantToRead => context.l10n.statusWantToRead,
      ReadingStatus.reading => context.l10n.statusReading,
      ReadingStatus.read => context.l10n.statusRead,
      ReadingStatus.abandoned => context.l10n.statusAbandoned,
      ReadingStatus.paused => context.l10n.statusPaused,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// Main Tab
// -------------------------------------------------------
class _MainTab extends StatelessWidget {
  final Book book;
  final VoidCallback onTapPages;

  const _MainTab({
    required this.book,
    required this.onTapPages,
  });

  String _formatLabel(BuildContext context, BookFormat? format) {
    switch (format) {
      case BookFormat.paperback:
        return context.l10n.formatPaperback;
      case BookFormat.hardcover:
        return context.l10n.formatHardcover;
      case BookFormat.leatherbound:
        return context.l10n.formatLeatherbound;
      case BookFormat.rustic:
        return context.l10n.formatRustic;
      case BookFormat.digital:
        return context.l10n.formatDigital;
      case BookFormat.other:
        return context.l10n.formatOther;
      case null:
        return '—';
    }
  }

  String _getMultiBlockProgress(Book book, List<ReadHistoryData> history) {
    if (book.paginationConfig == null || book.paginationConfig!.segments.isEmpty) {
      return '';
    }
    
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);
    
    Map<int, int> segProgress = {};
    if (activeSession?.segmentProgress != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(activeSession!.segmentProgress!);
        segProgress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      } catch (_) {}
    }

    return book.paginationConfig!.segments.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final endVisual = PaginationHelper.getVisualPageInSegment(s.endPhysical, s);
      
      final currentInSegment = segProgress[i] ?? 0;
      
      String visualProgress = '';
      if (currentInSegment == 0) {
        visualProgress = s.type == PageNumberingType.roman ? '-' : '0';
      } else {
        // Calculate physical page within segment to get visual representation
        final physForVisual = s.startPhysical + currentInSegment - 1;
        visualProgress = PaginationHelper.getVisualPageInSegment(physForVisual, s);
      }
      
      return '${s.label ?? 'Sección ${i + 1}'}: $visualProgress/$endVisual';
    }).join('  •  ');
  }

  void _showFullDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.fieldDescription.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = this.book;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadOnlyField(label: context.l10n.fieldTitle, value: book.title),
        const SizedBox(height: 20),
        if (book.subtitle != null) ...[
          _ReadOnlyField(label: context.l10n.fieldSubtitle, value: book.subtitle!),
          const SizedBox(height: 20),
        ],
        _ReadOnlyField(label: context.l10n.fieldAuthor, value: book.author),
        const SizedBox(height: 20),
        _ReadOnlyField(label: context.l10n.fieldPublisher, value: book.publisher ?? '—'),
        const SizedBox(height: 20),
        
        if (book.description != null && book.description!.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _showFullDescription(context, book.description!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.fieldDescription.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    book.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Progress Section - Tap to edit
        GestureDetector(
          onTap: onTapPages,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.bookDetailFieldPages,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
        Consumer(builder: (context, ref, _) {
          final historyAsync = ref.watch(readHistoryProvider(book.id));
          return historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('—'),
            data: (history) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.totalPages != null) ...[
                    const SizedBox(height: 8),
                    SegmentedProgressBar(
                      book: book,
                      history: history,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getMultiBlockProgress(book, history),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pág. ${PaginationHelper.getTotalReadPages(book, history)} / ${book.totalPages ?? 0}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else
                    Text('—', style: Theme.of(context).textTheme.bodyLarge),
                ],
              );
            },
          );
        }),
              
              if (book.paginationConfig != null && book.paginationConfig!.markers.isNotEmpty) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(context.l10n.paginationMarkersAndIndices, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.bold)),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  children: book.paginationConfig!.markers.map((m) => ListTile(
                    leading: Icon(Icons.location_on_outlined, size: 16, color: m.color != null ? Color(int.parse('0xFF${m.color}')) : null),
                    title: Text(m.label, style: const TextStyle(fontSize: 13)),
                    trailing: Text('${context.l10n.fieldCurrentPage.substring(0, 1).toUpperCase()}${context.l10n.fieldCurrentPage.substring(1).toLowerCase()}. ${PaginationHelper.getVisualPage(m.physicalPage, book.paginationConfig)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),
        _ReadOnlyField(label: context.l10n.bookDetailFieldFormat, value: _formatLabel(context, book.bookFormat)),
        const SizedBox(height: 20),

        // Star Rating
        Text(
          context.l10n.bookDetailFieldRating,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < (book.rating ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber[700],
              size: 24,
            );
          }),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Details Tab
// -------------------------------------------------------
class _DetailsTab extends ConsumerWidget {
  final Book book;
  final VoidCallback onTapNotes;
  final VoidCallback onStartNewReading;
  final Function(ReadHistoryData) onLongPressHistory;
  const _DetailsTab({
    required this.book,
    required this.onTapNotes,
    required this.onStartNewReading,
    required this.onLongPressHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyAsync = ref.watch(readHistoryProvider(book.id));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (history) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ReadOnlyField(
              label: context.l10n.fieldYear,
              value: book.publishYear?.toString() ?? '—',
            ),
            const SizedBox(height: 20),
            _ReadOnlyField(label: context.l10n.fieldIsbn, value: book.isbn ?? '—'),
            const SizedBox(height: 20),
            _ReadOnlyField(label: context.l10n.fieldLanguage, value: book.language ?? '—'),
            const SizedBox(height: 24),

            // Collection section
            Text(
              context.l10n.fieldCollection.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            if (book.collectionName != null && book.collectionName!.isNotEmpty)
              Consumer(builder: (context, ref, _) {
                final tagsAsync = ref.watch(allCollectionsProvider);
                return tagsAsync.maybeWhen(
                  data: (allCols) {
                    final collection = allCols.where((t) => t.id == book.collectionId).firstOrNull;
                    if (collection == null) return Text(book.collectionName ?? '—', style: Theme.of(context).textTheme.bodyLarge);
                    
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TagBooksView(tag: collection),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Collection number placeholder
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  book.collectionNumber?.toString() ?? '#',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collection.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer(builder: (context, ref, _) {
                                    final countAsync = ref.watch(booksByCollectionProvider(collection.id));
                                    return countAsync.maybeWhen(
                                      data: (list) => Text(
                                        context.l10n.imprintBookCount(list.length),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      orElse: () => const SizedBox.shrink(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                  orElse: () => Text(book.collectionName ?? '—', style: Theme.of(context).textTheme.bodyLarge),
                );
              })
            else
              Text('—', style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 24),

            // Imprint section
            Text(
              context.l10n.bookDetailFieldImprintSection,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(builder: (context, ref, _) {
              final imprintAsync = ref.watch(bookImprintProvider(book.id));
              return imprintAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const Text('—'),
                data: (imprint) {
                  if (imprint == null) {
                    return Text('—', style: Theme.of(context).textTheme.bodyLarge);
                  }
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagBooksView(tag: imprint),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail or initials
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imprint.imagePath != null
                                ? Image.file(
                              File(imprint.imagePath!),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => _ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
                            )
                                : _ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  imprint.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Consumer(builder: (context, ref, _) {
                                  final countAsync =
                                  ref.watch(imprintBookCountProvider(imprint.id));
                                  return countAsync.maybeWhen(
                                    data: (count) => Text(
                                      context.l10n.imprintBookCount(count),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 20),

            _ReadOnlyField(
              label: context.l10n.fieldTranslator,
              value: book.translator ?? '—',
            ),
            const SizedBox(height: 20),

            // Personal Notes
            GestureDetector(
              onTap: onTapNotes,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.bookDetailFieldPersonalNotes,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      book.notes ?? context.l10n.bookDetailNotesEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: book.notes == null
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ReadOnlyField(
                    label: context.l10n.bookDetailFieldAdded,
                    value:
                    '${book.createdAt.day}/${book.createdAt.month}/${book.createdAt.year}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ReadOnlyField(
                    label: 'Copias',
                    value: '${book.copies}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Independent Sections Summary
            if (book.paginationConfig != null && book.paginationConfig!.segments.isNotEmpty) ...[
              Text(
                'SECCIONES INDEPENDIENTES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: book.paginationConfig!.segments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isLast = i == book.paginationConfig!.segments.length - 1;
                    
                    final completedReads = history.where((h) => h.finishedAt != null).length;
                    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
                    final activeSession = history.lastWhereOrNull((h) => h.readNumber == activeSessionNum);
                    
                    Map<int, int> segProgress = {};
                    if (activeSession?.segmentProgress != null) {
                      try {
                        final Map<String, dynamic> decoded = jsonDecode(activeSession!.segmentProgress!);
                        segProgress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
                      } catch (_) {}
                    }

                    final currentInSegment = segProgress[i] ?? 0;
                    final segmentTotal = s.endPhysical - s.startPhysical + 1;

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(s.label ?? 'Sección ${i+1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Lectura actual: $activeSessionNum'),
                          trailing: Text(
                            '${(segmentTotal > 0 ? (currentInSegment / segmentTotal * 100) : 0).toStringAsFixed(0)}%',
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!isLast) Divider(height: 1, indent: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Reading History Section
            Text(
              context.l10n.bookDetailReadHistoryTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            if (history.isEmpty)
              Text('—', style: Theme.of(context).textTheme.bodyLarge)
            else
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: history.asMap().entries.map((entry) {
                    final h = entry.value;
                    final isLast = entry.key == history.length - 1;
                    
                    String dateRange = '';
                    if (h.startedAt != null) {
                      dateRange = '${h.startedAt!.day}/${h.startedAt!.month}/${h.startedAt!.year}';
                      if (h.finishedAt != null) {
                        dateRange += ' – ${h.finishedAt!.day}/${h.finishedAt!.month}/${h.finishedAt!.year}';
                      } else {
                        dateRange += ' – ${context.l10n.bookDetailReadOngoing}';
                      }
                    } else {
                      dateRange = '—';
                    }

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onLongPress: () => onLongPressHistory(h),
                          title: Text(
                            context.l10n.bookDetailReadNumber(h.readNumber),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateRange,
                                style: TextStyle(color: colorScheme.outline, fontSize: 12),
                              ),
                              if (h.sections != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  (jsonDecode(h.sections!) as List).join(' • '),
                                  style: TextStyle(
                                    color: colorScheme.primary.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          leading: Icon(
                            h.finishedAt != null ? Icons.check_circle_outline : Icons.play_circle_outline,
                            size: 18,
                            color: h.finishedAt != null ? Colors.green : colorScheme.primary,
                          ),
                        ),
                        if (!isLast) Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Start New Reading Button
            if (book.status != ReadingStatus.reading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: OutlinedButton.icon(
                  onPressed: onStartNewReading,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.bookDetailStartNewReadingButton),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({
    required this.label, 
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );

    return content;
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _CoverPlaceholder({
    this.width = 90,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: colorScheme.outline,
      ),
    );
  }
}

class _ImprintPlaceholder extends StatelessWidget {
  final double size;
  final double iconSize;
  final String? name;

  const _ImprintPlaceholder({
    this.size = 80,
    this.iconSize = 32,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (name != null && name!.isNotEmpty) {
      final initials = name!
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .take(3)
          .map((w) => w[0].toUpperCase())
          .join();
      content = Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: size * 0.35,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      content = Icon(
        Icons.business_outlined,
        size: iconSize,
        color: colorScheme.outline,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
