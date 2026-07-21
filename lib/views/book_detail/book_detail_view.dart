import 'package:drift/drift.dart' hide Column;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/reading_session_controller.dart';
import '../../controllers/book_operations_controller.dart';
import '../book_form/book_form_view.dart';
import '../../l10n/l10n_extension.dart';
import '../../utils/pagination_helper.dart';
import '../../widgets/segmented_page_picker.dart';
import 'widgets/book_header.dart';
import 'widgets/main_tab.dart';
import 'widgets/details_tab.dart';

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

  void _showPagePicker(BuildContext context) async {
    final book = widget.book;
    if (book.totalPages == null) return;

    final db = ref.read(databaseProvider);
    final history = await db.readHistoryDao.watchHistoryForBook(book.id).first;
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

    if (!context.mounted) return;

    final Map<int, int> initialSegProgress = activeSession?.segmentProgress ?? {};

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
            await ref.read(readingSessionControllerProvider).updatePageProgress(
              book: book,
              newPage: phys,
              newSegProgress: newSegProgress,
              newConfig: newConfig,
              sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
            );
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
    final segments = book.paginationConfig?.segments ?? [];

    if (segments.isEmpty) {
      ref.read(readingSessionControllerProvider).startNewReading(
        book: book,
        sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
      );
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
                          ref.read(readingSessionControllerProvider).startNewReading(
                            book: book,
                            selectedIndices: selectSections ? selectedIndices : null,
                            sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
                          );
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
                  onTapPages: () => _showPagePicker(context),
                ),
                DetailsTab(
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
