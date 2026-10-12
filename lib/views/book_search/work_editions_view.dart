import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../controllers/app_settings_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../../models/book_search_result.dart';
import '../../services/book_search_service.dart';
import '../../services/inventaire_service.dart';
import '../../services/open_library_service.dart';
import '../book_form/book_form_view.dart';

/// View displaying all hydrated editions for a specific canonical work.
class WorkEditionsView extends ConsumerStatefulWidget {
  final BookSearchResult workResult;

  const WorkEditionsView({super.key, required this.workResult});

  @override
  ConsumerState<WorkEditionsView> createState() => _WorkEditionsViewState();
}

class _WorkEditionsViewState extends ConsumerState<WorkEditionsView> {
  List<BookSearchResult> _editions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEditions();
  }

  String _getPreferredLanguage() {
    final settings = ref.read(appSettingsProvider);
    if (settings.locale?.languageCode != null) {
      return settings.locale!.languageCode;
    }
    try {
      return Localizations.localeOf(context).languageCode;
    } catch (_) {
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    }
  }

  Future<void> _fetchEditions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final preferredLanguage = _getPreferredLanguage();

      List<BookSearchResult> results = [];

      if (widget.workResult.openLibraryWorkKey != null) {
        results = await OpenLibraryService.getEditionsByWork(
          widget.workResult.openLibraryWorkKey!,
          preferredLanguage: preferredLanguage,
          baseAuthors: widget.workResult.authors,
        );
      } else if (widget.workResult.inventaireWorkUri != null) {
        results = await InventaireService.getEditionsByWork(
          widget.workResult.inventaireWorkUri!,
          preferredLanguage: preferredLanguage,
        );
      } else {
        final searchResults = await OpenLibraryService.searchStructured(
          BookSearchQuery(
            title: widget.workResult.title,
            author: widget.workResult.authors.isNotEmpty ? widget.workResult.authors.first : null,
            isbn: widget.workResult.isbn,
          ),
          preferredLanguage: preferredLanguage,
        );
        final workKey = searchResults.firstWhereOrNull((r) => r.openLibraryWorkKey != null)?.openLibraryWorkKey;
        if (workKey != null) {
          results = await OpenLibraryService.getEditionsByWork(
            workKey,
            preferredLanguage: preferredLanguage,
            baseAuthors: widget.workResult.authors,
          );
        }
      }

      if (mounted) {
        setState(() {
          _editions = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _selectEdition(BookSearchResult edition) {
    // Preserve authors from work if edition has none
    var finalResult = edition.authors.isEmpty || edition.authors.first == 'Unknown Author'
        ? edition.copyWith(authors: widget.workResult.authors)
        : edition;

    // Attach original title from work if not already present
    if (finalResult.originalTitle == null && widget.workResult.title.isNotEmpty && widget.workResult.title != finalResult.title) {
      finalResult = finalResult.copyWith(originalTitle: widget.workResult.title);
    } else if (finalResult.originalTitle == null && widget.workResult.originalTitle != null) {
      finalResult = finalResult.copyWith(originalTitle: widget.workResult.originalTitle);
    }

    // Attach description from work if edition description is missing
    if (finalResult.description == null && widget.workResult.description != null) {
      finalResult = finalResult.copyWith(description: widget.workResult.description);
    }

    // Attach pageCount from work if edition pageCount is missing
    if (finalResult.pageCount == null && widget.workResult.pageCount != null) {
      finalResult = finalResult.copyWith(pageCount: widget.workResult.pageCount);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => BookFormView(prefill: finalResult),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workResult.title),
      ),
      body: Column(
        children: [
          // Header Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workResult.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.workResult.authors.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.workResult.editionCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      context.l10n.workEditionsCount(widget.workResult.editionCount!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Editions List or Loading State
          Expanded(child: _buildBody(colorScheme, theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _editions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                context.l10n.workEditionsEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _selectEdition(widget.workResult),
                icon: const Icon(Icons.check),
                label: Text(context.l10n.workEditionsUseGeneral),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _editions.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        final ed = _editions[index];
        final currentLangCode = (ref.read(appSettingsProvider).locale?.languageCode ??
                Localizations.localeOf(context).languageCode)
            .toLowerCase();
        final isPreferredLang = ed.language != null &&
            ed.language!.toLowerCase().startsWith(currentLangCode);

        return ListTile(
          onTap: () => _selectEdition(ed),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 44,
              height: 62,
              child: ed.coverUrl != null
                  ? Image.network(
                      ed.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.menu_book, color: colorScheme.outline, size: 20),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.menu_book, color: colorScheme.outline, size: 20),
                    ),
            ),
          ),
          title: Text(
            ed.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              if (ed.publisher != null || ed.publishYear != null)
                Text(
                  [
                    if (ed.publisher != null) ed.publisher,
                    if (ed.publishYear != null) '${ed.publishYear}',
                  ].join(' • '),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (ed.isbn != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ISBN ${ed.isbn}',
                        style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                      ),
                    ),
                  if (ed.language != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isPreferredLang
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ed.language!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: isPreferredLang ? FontWeight.bold : FontWeight.normal,
                          color: isPreferredLang
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (ed.pageCount != null)
                    Text(
                      context.l10n.pageSuffix(ed.pageCount!),
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                    ),
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
        );
      },
    );
  }
}
