import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../models/book_search_result.dart';

/// Compact result tile for displaying a single book search result.
class BookSearchResultTile extends StatelessWidget {
  final BookSearchResult result;
  final ValueChanged<BookSearchResult> onTap;

  const BookSearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasMultipleEditions = (result.editionCount != null && result.editionCount! > 1) ||
        result.openLibraryWorkKey != null ||
        result.inventaireWorkUri != null;

    return InkWell(
      onTap: () => onTap(result),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Thumbnail & Provider Badge
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 52,
                    height: 72,
                    child: result.coverUrl != null
                        ? Image.network(
                            result.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _CoverPlaceholder(colorScheme: colorScheme),
                          )
                        : _CoverPlaceholder(colorScheme: colorScheme),
                  ),
                ),
                const SizedBox(height: 4),
                _ProviderBadge(source: result.source),
              ],
            ),
            const SizedBox(width: 12),

            // Metadata Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.authors.join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (result.publishYear != null)
                        _MetaText(label: '${result.publishYear}'),
                      if (result.publisher != null)
                        _MetaText(label: result.publisher!),
                      if (result.pageCount != null)
                        _MetaText(label: context.l10n.pageSuffix(result.pageCount!)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing Action: Top-Right Edition Chip or Standard Chevron
            if (hasMultipleEditions && result.editionCount != null && result.editionCount! > 1)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories, size: 13, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.workEditionsCount(result.editionCount!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 14, color: colorScheme.onPrimaryContainer),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final String source;
  const _ProviderBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CoverPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book, color: colorScheme.outline, size: 24),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String label;
  const _MetaText({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.outline,
        fontSize: 11,
      ),
    );
  }
}
