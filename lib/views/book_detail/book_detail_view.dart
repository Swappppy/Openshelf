import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../../widgets/status_chip.dart';
import '../book_form/book_form_view.dart';
import '../../widgets/page_picker.dart';
import '../../widgets/tag_chip.dart';
import '../../l10n/l10n_extension.dart';

class BookDetailView extends ConsumerWidget {
  final Book book;
  const BookDetailView({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

// -------------------------------------------------------
// Cabecera — portada izquierda + resumen derecha
// -------------------------------------------------------
class _BookHeader extends StatelessWidget {
  final Book book;
  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portada
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.coverPath != null
                ? Image.file(
              File(book.coverPath!),
              width: 90,
              height: 130,
              fit: BoxFit.cover,
            )
                : Container(
              width: 90,
              height: 130,
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.menu_book,
                size: 40,
                color: colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Resumen
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texto izquierda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (book.publisher != null)
                        Text(
                          book.publisher!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Chip derecha
                StatusChip(status: book.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Pestaña Principal
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
        // Categorías
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

        // Páginas — toca para editar
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
                    // Columna izquierda — slider
                    Expanded(
                      child: LinearProgressIndicator(
                        value: ((book.currentPage ?? 0) / book.totalPages!)
                            .clamp(0.0, 1.0),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Columna derecha — números
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

        // Valoración
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
// Pestaña Detalles
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

        // Sellos
        Text(
          context.l10n.bookDetailFieldImprintSection,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const SizedBox(height: 4),
        Consumer(builder: (context, ref, _) {
          final imprintAsync = ref.watch(bookImprintProvider(book.id));
          return imprintAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('—'),
            data: (imprint) {
              if (imprint == null) {
                return Text('—', style: Theme.of(context).textTheme.bodyLarge);
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imprint.imagePath != null
                            ? Image.file(
                          File(imprint.imagePath!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 80,
                        child: Text(
                          imprint.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }),

        const SizedBox(height: 20),

        // Notas
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

        // Fechas
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
// Widgets auxiliares
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