import 'package:drift/drift.dart' hide Column;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/reading_session_controller.dart';
import '../../controllers/book_operations_controller.dart';
import '../book_form/book_form_view.dart';
import '../../l10n/l10n_extension.dart';
import '../../utils/pagination_helper.dart';
import '../../widgets/segmented_page_picker.dart';
import '../../utils/time_map.dart';
import 'widgets/book_header.dart';
import 'widgets/main_tab.dart';
import 'widgets/details_tab.dart';
import 'widgets/new_reading_bottom_sheet.dart';
import '../../utils/media_progress.dart';
import '../book_form/widgets/form_components.dart' show DurationFormField;
import 'widgets/ownership_event_sheet.dart';
import '../../controllers/read_history_controller.dart';
import '../../controllers/app_settings_controller.dart';

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

  void _showPagePicker(BuildContext context, {int? initialSegmentIndex, int? startAt}) async {
    final book = widget.book;
    if (book.totalPages == null) return;

    final db = ref.read(databaseProvider);
    final history = await db.readHistoryDao.watchHistoryForBook(book.id).first;
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

    if (!context.mounted) return;

    // Mixed mode: a session that resumes after the other medium starts at
    // [startAt] (pages covered). Only the section containing it moves there;
    // the others keep their own progress (sections may be read out of order).
    final segments = book.paginationConfig?.segments ?? const <PaginationSegment>[];
    final Map<int, int> initialSegProgress = Map<int, int>.from(activeSession?.segmentProgress ?? const {});
    if (startAt != null && segments.isNotEmpty) {
      // A start on a boundary belongs to the section that begins there (you
      // finished one section in the other medium and continue with the next).
      final k = _sectionAt(startAt, segments);
      if (k >= 0) {
        initialSegProgress[k] = startAt - (segments[k].startPhysical - 1);
        initialSegmentIndex ??= k;
      }
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
          initialProgress: startAt ?? activeSession?.progress ?? 0,
          initialSegmentProgress: initialSegProgress,
          initialSegmentIndex: initialSegmentIndex,
          config: book.paginationConfig,
          onSave: (phys, newSegProgress, newConfig) async {
            await ref.read(readingSessionControllerProvider).updatePageProgress(
              book: book,
              newPage: phys,
              newSegProgress: newSegProgress,
              newConfig: newConfig,
              startAt: startAt,
              sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  /// Listening progress: the user types the position shown by the player.
  Future<void> _showAudioPicker(BuildContext context, {int? startAt}) async {
    final book = widget.book;
    final db = ref.read(databaseProvider);
    final info = await db.audiobookInfoDao.getForBook(book.id);
    final history = await db.readHistoryDao.getHistoryForBook(book.id);
    if (!context.mounted) return;

    final duration = info?.durationSeconds ?? 0;
    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.audioDurationMissing)));
      return;
    }

    // Sections shared with the pages in a mixed book; an audiobook's own.
    final sections = audioSegmentsFor(book, duration, audioConfig: info?.paginationConfig);
    final completed = history.where((h) => h.finishedAt != null).length;
    final active = PaginationHelper.getActiveSessionNumber(book.status, completed);
    final entry = history.firstWhereOrNull((h) => h.readNumber == active);
    final initial = Map<int, int>.from(entry?.audioSegmentProgress ??
        (sections.length == 1
            ? {0: MediaProgress.audio(book, history, info)?.current ?? 0}
            : PaginationHelper.distributePhysicalPage(entry?.audioProgress ?? 0, sections)));
    int? initialIndex;
    if (startAt != null) {
      final k = _sectionAt(startAt, sections);
      if (k >= 0) {
        initial[k] = startAt - (sections[k].startPhysical - 1);
        initialIndex = k;
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SegmentedTimePicker(
          sections: sections,
          initialSegmentProgress: initial,
          initialSegmentIndex: initialIndex,
          saveLabel: ctx.l10n.paginationSaveProgress,
          onSave: (segProgress) async {
            await ref.read(readingSessionControllerProvider).updateAudioProgress(
              book: book,
              newSegProgress: segProgress,
              duration: duration,
              startAt: startAt,
              sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  /// Mixed mode: starts a progress entry in [medium]. When the previous
  /// entry of this read was in the other medium, asks where this session
  /// starts, so the two media cover complementary stretches.
  Future<void> _beginSession(ReadingMedium medium, {int? initialSegmentIndex}) async {
    final book = widget.book;
    final last = await ref.read(readingSessionControllerProvider).lastEntryOfActiveRead(book);
    int? startAt;
    if (last != null && last.medium != medium) {
      if (!mounted) return;
      // Where the other medium stopped, if known, to suggest a start.
      final lastEnd = last.startPosition != null ? last.startPosition! + last.pagesRead : null;
      final answer = await _askStartPosition(medium, otherMediumEnd: lastEnd);
      if (answer == null) return; // dismissed: nothing is logged
      startAt = answer.start; // null: continue from this medium's own pointer
    }
    if (!mounted) return;
    if (medium == ReadingMedium.text) {
      _showPagePicker(context, initialSegmentIndex: initialSegmentIndex, startAt: startAt);
    } else {
      await _showAudioPicker(context, startAt: startAt);
    }
  }

  /// Asks where a session in [medium] starts. Returns null when dismissed,
  /// `(start: null)` to continue from the medium's own pointer.
  ///
  /// With [otherMediumEnd] (where the other medium stopped, in its units) the
  /// field is prefilled with that position translated through the shared
  /// sections ([TimeMap]); it is only a suggestion the user can overwrite.
  Future<({int? start})?> _askStartPosition(ReadingMedium medium, {int? otherMediumEnd}) async {
    final book = widget.book;
    final db = ref.read(databaseProvider);
    final history = await db.readHistoryDao.getHistoryForBook(book.id);
    final info = await db.audiobookInfoDao.getForBook(book.id);
    if (!mounted) return null;

    final completed = history.where((h) => h.finishedAt != null).length;
    final active = PaginationHelper.getActiveSessionNumber(book.status, completed);
    final entry = history.firstWhereOrNull((h) => h.readNumber == active);
    final pagePointer = entry?.progress ?? 0;
    final audioPointer = entry?.audioProgress ?? 0;
    final config = book.paginationConfig;
    final useVisual = config?.useVisualMode ?? false;
    final ownPointer = medium == ReadingMedium.text ? pagePointer : audioPointer;

    // Start in the medium's own units: pages already covered (page - 1) or seconds.
    int? parseStart(String text) {
      if (medium == ReadingMedium.audio) return parseDuration(text);
      final page = useVisual && config != null
          ? PaginationHelper.getPhysicalFromVisual(text.trim(), config)
          : int.tryParse(text.trim());
      if (page == null || page < 1 || page > (book.totalPages ?? page)) return null;
      return page - 1;
    }

    final formKey = GlobalKey<FormState>();
    String suggestion = '';
    final duration = info?.durationSeconds ?? 0;
    if (otherMediumEnd != null && duration > 0 && (book.totalPages ?? 0) > 0) {
      final map = TimeMap(
        totalPages: book.totalPages!,
        duration: duration,
        segments: config?.segments ?? const [],
        markers: config?.markers ?? const [],
      );
      if (medium == ReadingMedium.text) {
        final page = (map.toPages(otherMediumEnd) + 1).clamp(1, book.totalPages!);
        suggestion = useVisual && config != null ? PaginationHelper.getVisualPage(page, config) : '$page';
      } else {
        suggestion = formatDuration(map.toSeconds(otherMediumEnd));
      }
    }

    final otherMedium = medium == ReadingMedium.text
        ? context.l10n.mixedLastAudio('${formatDuration(audioPointer)} $durationUnit')
        : context.l10n.mixedLastPage(useVisual && config != null
            ? PaginationHelper.getVisualPageForProgress(pagePointer, config)
            : pagePointer.toString());

    final result = await showDialog<({int? start})>(
      context: context,
      builder: (_) => _OwnedController(
        initialText: suggestion,
        builder: (_, ctrl) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final candidate = parseStart(ctrl.text);
          final overlaps = candidate != null && candidate < ownPointer;
          return AlertDialog(
            title: Text(ctx.l10n.mixedStartTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherMedium, style: Theme.of(ctx).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  if (medium == ReadingMedium.audio)
                    DurationFormField(
                      controller: ctrl,
                      label: ctx.l10n.mixedStartPosition,
                      helperText: suggestion.isNotEmpty ? ctx.l10n.mixedSuggested : null,
                      icon: Icons.headphones_outlined,
                      isRequired: true,
                      autofocus: true,
                      onChanged: (_) => setDialogState(() {}),
                      extraValidator: (seconds) => (info?.durationSeconds ?? 0) > 0 && seconds > info!.durationSeconds!
                          ? ctx.l10n.audioPositionBeyondDuration
                          : null,
                    )
                  else
                    TextFormField(
                      controller: ctrl,
                      autofocus: true,
                      keyboardType: useVisual ? TextInputType.text : TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ctx.l10n.mixedStartPage,
                        helperText: suggestion.isNotEmpty ? ctx.l10n.mixedSuggested : null,
                        prefixIcon: const Icon(Icons.menu_book_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                      validator: (v) => parseStart(v ?? '') == null ? ctx.l10n.mixedInvalidPage : null,
                    ),
                  if (overlaps) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Theme.of(ctx).colorScheme.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(ctx.l10n.mixedOverlapWarning, style: Theme.of(ctx).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, (start: null)),
                child: Text(ctx.l10n.mixedSkip),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx, (start: parseStart(ctrl.text)));
                },
                child: Text(ctx.l10n.mixedContinue),
              ),
            ],
          );
        },
      ),
      ),
    );
    return result;
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
              onPressed: () async {
                final updated = widget.book.copyWith(notes: Value(controller.text));
                await ref.read(databaseProvider).bookDao.updateBook(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartNewReadingDialog() {
    final book = widget.book;
    final history = ref.read(readHistoryProvider(book.id)).value ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NewReadingBottomSheet(
        book: book,
        history: history,
      ),
    );
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
                  subtitle: Text(startedAt != null ? DateFormat.yMd(Localizations.localeOf(context).toString()).format(startedAt!) : '—'),
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
                  subtitle: Text(finishedAt != null ? DateFormat.yMd(Localizations.localeOf(context).toString()).format(finishedAt!) : '—'),
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
                  ref.read(readingSessionControllerProvider).updateHistoryEntry(h, startedAt: startedAt, finishedAt: finishedAt);
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
                          ref.read(readingSessionControllerProvider).deleteHistoryEntry(widget.book, h.readNumber);
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

  void _showOwnershipOptions(OwnershipLogData entry) {
    final db = ref.read(databaseProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () async {
                Navigator.pop(ctx);
                final edited = await OwnershipEventSheet.show(context, entry);
                if (edited != null) await db.ownershipDao.editEvent(edited);
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
                    content: Text(context.l10n.ownershipEventDeleteConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx2), child: Text(context.l10n.cancel)),
                      FilledButton(
                        onPressed: () {
                          db.ownershipDao.removeEvent(entry);
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
            tooltip: context.l10n.edit,
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookFormView(existingBook: book),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: context.l10n.duplicate,
            onPressed: () {
              HapticFeedback.selectionClick();
              _confirmDuplicate(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.delete,
            onPressed: () {
              HapticFeedback.selectionClick();
              _confirmDelete(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          BookHeader(book: book),
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
                MainTab(
                  book: book,
                  onTapPages: () => switch (widget.book.mediaType) {
                    MediaType.audio => _showAudioPicker(context),
                    MediaType.both => _beginSession(ReadingMedium.text),
                    MediaType.reading => _showPagePicker(context),
                  },
                  onTapAudio: () => _beginSession(ReadingMedium.audio),
                  onTapSection: (idx) => widget.book.mediaType == MediaType.both
                      ? _beginSession(ReadingMedium.text, initialSegmentIndex: idx)
                      : _showPagePicker(context, initialSegmentIndex: idx),
                ),
                DetailsTab(
                  book: book,
                  onTapNotes: () => _showNotesEditor(context),
                  onStartNewReading: _showStartNewReadingDialog,
                  onLongPressHistory: _showHistoryOptions,
                  onLongPressOwnership: _showOwnershipOptions,
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
              final settings = ref.read(appSettingsProvider);
              ref.read(databaseProvider).bookDao.deleteBook(
                widget.book.id,
                pruneEnabled: settings.pruneOrphanCategories,
                excludedIds: settings.excludedCategoriesFromPruning,
              );
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

/// Owns a [TextEditingController] for the lifetime of a dialog or sheet.
/// Disposing it right after `showDialog` returns is too early: the route is
/// still animating out and its fields still use the controller.
class _OwnedController extends StatefulWidget {
  final String initialText;
  final Widget Function(BuildContext context, TextEditingController controller) builder;

  const _OwnedController({this.initialText = '', required this.builder});

  @override
  State<_OwnedController> createState() => _OwnedControllerState();
}

class _OwnedControllerState extends State<_OwnedController> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

/// Index of the section that contains position [at] (covered units, so a
/// section spans `[startPhysical - 1, endPhysical]`). On a boundary the
/// section that starts there wins; the very end belongs to the last section.
int _sectionAt(int at, List<PaginationSegment> sections) {
  final starting = sections.indexWhere((s) => at >= s.startPhysical - 1 && at < s.endPhysical);
  if (starting >= 0) return starting;
  return sections.lastIndexWhere((s) => at >= s.startPhysical - 1 && at <= s.endPhysical);
}

