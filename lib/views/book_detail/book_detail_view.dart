import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../book_form/book_form_view.dart';
import '../../widgets/page_picker.dart';
import '../../widgets/tag_chip.dart';
import '../../l10n/l10n_extension.dart';
import '../shelves/shelf_books_view.dart';

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
  Future<void> _updatePage(int newPage) async {
    final book = widget.book;
    final total = book.totalPages ?? 0;
    ReadingStatus newStatus = book.status;

    if (newPage == 0) {
      newStatus = ReadingStatus.wantToRead;
    } else if (total > 0 && newPage >= total) {
      newStatus = ReadingStatus.read;
    } else {
      newStatus = ReadingStatus.reading;
    }

    final updated = book.copyWith(
      currentPage: Value(newPage),
      status: newStatus,
    );
    await ref.read(databaseProvider).updateBook(updated);
  }

  Future<void> _updateNotes(String notes) async {
    final updated = widget.book.copyWith(
      notes: Value(notes.trim().isEmpty ? null : notes.trim()),
    );
    await ref.read(databaseProvider).updateBook(updated);
  }

  /// Opens the ergonomic wheel-based page picker.
  void _showPagePicker(BuildContext context) {
    final book = widget.book;
    if (book.totalPages == null) return;
    int selectedPage = book.currentPage ?? 0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.bookDetailPagePickerTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            PagePicker(
              initialValue: selectedPage,
              maxValue: book.totalPages!,
              onChanged: (val) => selectedPage = val,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await _updatePage(selectedPage);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(context.l10n.save),
            ),
            const SizedBox(height: 8),
          ],
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
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.bookDetailNotesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: context.l10n.bookDetailNotesHint,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await _updateNotes(controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
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
        toolbarHeight: 40,
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, animation, _) =>
                    BookFormView(existingBook: book),
                transitionsBuilder: (_, animation, _, child) =>
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                transitionDuration: const Duration(milliseconds: 350),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _BookHeader(book: book),
          TabBar(
            controller: _tabController,
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref
                  .read(databaseProvider)
                  .deleteBook(widget.book.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// Header section displaying the large cover and a summary column (Title, Author, Rating, Tags).
class _BookHeader extends ConsumerWidget {
  final Book book;
  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tagsAsync = ref.watch(bookTagsProvider(book.id));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.coverPath != null
                ? Image.file(
              File(book.coverPath!),
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const _CoverPlaceholder(width: 100, height: 150),
            )
                : const _CoverPlaceholder(width: 100, height: 150),
          ),
          const SizedBox(width: 20),

          // Summary Column
          Expanded(
            child: SizedBox(
              height: 150, // Matches cover height for perfect alignment
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Star Rating
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final isFilled = i < (book.rating ?? 0);
                            return Icon(
                              isFilled ? Icons.star : Icons.star_border,
                              color: isFilled ? Colors.amber[700] : colorScheme.outline.withValues(alpha: 0.3),
                              size: 14,
                            );
                          }),
                          if (book.rating != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${book.rating})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // Tags display (Limited to 2 rows with +N counter)
                  tagsAsync.maybeWhen(
                    data: (tagList) => tagList.isEmpty 
                      ? const SizedBox.shrink() 
                      : _CompactTagsDisplay(tags: tagList),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A smart tag display that fits tags within two rows and adds a counter for hidden ones.
class _CompactTagsDisplay extends StatelessWidget {
  final List<Tag> tags;
  const _CompactTagsDisplay({required this.tags});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
        
        final rows = <List<Tag>>[];
        var currentContext = <Tag>[];
        double currentRowWidth = 0;
        const spacing = 8.0;
        const chipPadding = 20.0; // horizontal total

        for (var i = 0; i < tags.length; i++) {
          final tag = tags[i];
          final painter = TextPainter(
            text: TextSpan(text: tag.name, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          
          final tagWidth = painter.width + chipPadding;
          
          if (currentRowWidth + tagWidth <= constraints.maxWidth) {
            currentContext.add(tag);
            currentRowWidth += tagWidth + spacing;
          } else {
            rows.add(currentContext);
            currentContext = [tag];
            currentRowWidth = tagWidth + spacing;
          }
          
          if (rows.length == 2) break;
        }
        
        if (rows.length < 2) rows.add(currentContext);
        
        final visibleTags = rows.take(2).expand((r) => r).toList();
        final hiddenCount = tags.length - visibleTags.length;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...visibleTags.map((tag) {
              final color = tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : null;
              return _SimpleTagChip(label: tag.name, color: color);
            }),
            if (hiddenCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  '+$hiddenCount',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SimpleTagChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _SimpleTagChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: baseColor,
          fontWeight: FontWeight.w500,
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
  const _MainTab({required this.book, required this.onTapPages});

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

  @override
  Widget build(BuildContext context) {
    final book = this.book;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadOnlyField(label: context.l10n.fieldTitle, value: book.title),
        const SizedBox(height: 20),
        _ReadOnlyField(label: context.l10n.fieldAuthor, value: book.author),
        const SizedBox(height: 20),
        _ReadOnlyField(label: context.l10n.fieldPublisher, value: book.publisher ?? '—'),
        const SizedBox(height: 20),
        _ReadOnlyField(
          label: context.l10n.fieldYear,
          value: book.publishYear?.toString() ?? '—',
        ),
        const SizedBox(height: 20),
        _ReadOnlyField(label: context.l10n.fieldIsbn, value: book.isbn ?? '—'),
        const SizedBox(height: 20),
        
        // Full Category list
        Text(
          context.l10n.bookDetailFieldCategories,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Consumer(builder: (context, ref, _) {
          final tagsAsync = ref.watch(bookTagsProvider(book.id));
          return tagsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('—'),
            data: (tagList) => tagList.isEmpty
                ? Text(
              '—',
              style: Theme.of(context).textTheme.bodyLarge,
            )
                : Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tagList.map((tag) => TagChip(
                label: tag.name,
                colorHex: tag.color,
              )).toList(),
            ),
          );
        }),
        const SizedBox(height: 20),

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
              if (book.totalPages != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: ((book.currentPage ?? 0) / book.totalPages!)
                            .clamp(0.0, 1.0),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.l10n.pageProgressShort(book.currentPage ?? 0, book.totalPages!),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(((book.currentPage ?? 0) / book.totalPages!) * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else
                Text('—', style: Theme.of(context).textTheme.bodyLarge),
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
class _DetailsTab extends StatelessWidget {
  final Book book;
  final VoidCallback onTapNotes;
  const _DetailsTab({required this.book, required this.onTapNotes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadOnlyField(
          label: context.l10n.fieldCollection,
          value: book.collectionName ?? '—',
        ),
        const SizedBox(height: 20),
        _ReadOnlyField(
          label: context.l10n.fieldCollectionNumber,
          value: book.collectionNumber?.toString() ?? '—',
        ),
        const SizedBox(height: 20),

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
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Timestamps
        _ReadOnlyField(
          label: context.l10n.bookDetailFieldAdded,
          value:
          '${book.createdAt.day}/${book.createdAt.month}/${book.createdAt.year}',
        ),
        const SizedBox(height: 20),
        _ReadOnlyField(
          label: context.l10n.bookDetailFieldStarted,
          value: book.startedAt != null
              ? '${book.startedAt!.day}/${book.startedAt!.month}/${book.startedAt!.year}'
              : '—',
        ),
        const SizedBox(height: 20),
        _ReadOnlyField(
          label: context.l10n.bookDetailFieldFinished,
          value: book.finishedAt != null
              ? '${book.finishedAt!.day}/${book.finishedAt!.month}/${book.finishedAt!.year}'
              : '—',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Helper Widgets
// -------------------------------------------------------

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double iconSize;

  const _CoverPlaceholder({
    this.width = 90,
    this.height = 130,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        size: iconSize,
        color: Theme.of(context).colorScheme.outline,
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
