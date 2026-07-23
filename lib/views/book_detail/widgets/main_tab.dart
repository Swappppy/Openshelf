import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../utils/pagination_helper.dart';
import '../../../widgets/segmented_progress_bar.dart';
import '../../../controllers/read_history_controller.dart';
import '../../../controllers/books_controller.dart';
import '../../../widgets/tag_chip.dart';
import '../../shelves/shelf_books_view.dart';

class MainTab extends StatelessWidget {
  final Book book;
  final VoidCallback onTapPages;
  final Function(int) onTapSection;

  const MainTab({
    super.key,
    required this.book,
    required this.onTapPages,
    required this.onTapSection,
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ReadOnlyField(label: context.l10n.fieldTitle, value: book.title),
        const SizedBox(height: 20),
        if (book.subtitle != null) ...[
          ReadOnlyField(label: context.l10n.fieldSubtitle, value: book.subtitle!),
          const SizedBox(height: 20),
        ],
        ReadOnlyField(label: context.l10n.fieldAuthor, value: book.author),
        const SizedBox(height: 20),
        ReadOnlyField(label: context.l10n.fieldPublisher, value: book.publisher ?? '—'),
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

        // Categories (Tags) - Moved up
        Text(
          context.l10n.bookDetailFieldCategories.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final tagsAsync = ref.watch(bookTagsProvider(book.id));
            return tagsAsync.maybeWhen(
              data: (tags) {
                if (tags.isEmpty) {
                  return Text('—', style: Theme.of(context).textTheme.bodyLarge);
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => TagChip(
                    label: tag.name,
                    colorHex: tag.color,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagBooksView(tag: tag),
                      ),
                    ),
                  )).toList(),
                );
              },
              orElse: () => const Text('—'),
            );
          },
        ),
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
                    context.l10n.bookDetailFieldPages.toUpperCase(),
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
                    final totalRead = PaginationHelper.getTotalReadPages(book, history);
                    final totalPages = book.totalPages ?? 0;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (book.totalPages != null) ...[
                          if (book.paginationConfig?.markers.isNotEmpty ?? false)
                            const SizedBox(height: 55),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SegmentedProgressBar(
                                  book: book,
                                  history: history,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$totalRead / $totalPages',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '${(totalPages > 0 ? (totalRead / totalPages * 100) : 0).toStringAsFixed(0)}%',
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

                        if (book.paginationConfig != null &&
                            (book.paginationConfig!.markers.isNotEmpty ||
                                book.paginationConfig!.segments.length > 1)) ...[
                          const SizedBox(height: 16),
                          _MarkersAndSegmentsTile(
                            book: book,
                            history: history,
                            onTapSection: onTapSection,
                          ),
                        ],
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),
        ReadOnlyField(label: context.l10n.bookDetailFieldFormat, value: _formatLabel(context, book.bookFormat)),
        const SizedBox(height: 20),

        // Star Rating
        Text(
          context.l10n.bookDetailFieldRating.toUpperCase(),
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

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyField({
    super.key,
    required this.label, 
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
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
  }
}

class _MarkersAndSegmentsTile extends StatefulWidget {
  final Book book;
  final List<ReadHistoryData> history;
  final Function(int) onTapSection;

  const _MarkersAndSegmentsTile({
    required this.book,
    required this.history,
    required this.onTapSection,
  });

  @override
  State<_MarkersAndSegmentsTile> createState() => _MarkersAndSegmentsTileState();
}

class _MarkersAndSegmentsTileState extends State<_MarkersAndSegmentsTile> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.book.paginationConfig?.segments ?? [];
    final markers = widget.book.paginationConfig?.markers ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    final pages = <Widget>[];
    if (segments.length > 1) pages.add(_buildSegmentsPage(context, segments));
    if (markers.isNotEmpty) pages.add(_buildMarkersPage(context, markers));

    if (pages.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        context.l10n.paginationMarkersAndIndices,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      children: [
        SizedBox(
          height: 200, // Fixed height for scrolling content
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (v) => setState(() => _currentPage = v),
                  children: pages,
                ),
              ),
              if (pages.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentsPage(BuildContext context, List<PaginationSegment> segments) {
    final colorScheme = Theme.of(context).colorScheme;
    final history = widget.history;
    final book = widget.book;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: segments.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, i) {
        final s = segments[i];
        final completedReads = history.where((h) => h.finishedAt != null).length;
        final sectionLabel = s.label ?? context.l10n.paginationSectionLabel(i + 1);

        final activeSessionForSegment = history.lastWhereOrNull(
            (h) => h.sections == null || h.sections!.contains(sectionLabel));

        final sessionNumToShow = activeSessionForSegment?.readNumber ??
            PaginationHelper.getActiveSessionNumber(book.status, completedReads);

        final Map<int, int> segProgress = activeSessionForSegment?.segmentProgress ?? {};
        final currentInSegment = segProgress[i] ?? 0;
        final segmentTotal = s.endPhysical - s.startPhysical + 1;

        final curVisual = PaginationHelper.getVisualPageInSegment(s.startPhysical + currentInSegment - 1, s);
        final totVisual = PaginationHelper.getVisualPageInSegment(s.endPhysical, s);

        final segmentColor = s.color != null
            ? Color(int.parse('0xFF${s.color}'))
            : colorScheme.primary.withValues(alpha: 0.2);

        return IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: segmentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              Expanded(
                child: ListTile(
                  onTap: () => widget.onTapSection(i),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    sectionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${context.l10n.statusReading}: $sessionNumToShow',
                      style: const TextStyle(fontSize: 11)),
                  trailing: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$curVisual / $totVisual  ',
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${(segmentTotal > 0 ? (currentInSegment / segmentTotal * 100) : 0).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarkersPage(BuildContext context, List<PaginationMarker> markers) {
    final book = widget.book;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: markers.length,
      itemBuilder: (context, i) {
        final m = markers[i];
        return ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            size: 16,
            color: m.color != null ? Color(int.parse('0xFF${m.color}')) : null,
          ),
          title: Text(m.label, style: const TextStyle(fontSize: 13)),
          trailing: Text(
            '${context.l10n.paginationCurrentPageShort} ${PaginationHelper.getVisualPage(m.physicalPage, book.paginationConfig)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        );
      },
    );
  }
}
