import 'package:flutter/material.dart';
import '../../controllers/app_settings_controller.dart';
import '../../models/app_settings.dart';
import '../book_form/book_form_view.dart';
import '../../models/book_search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/book_search_service.dart';
import '../../l10n/l10n_extension.dart';

/// Screen for searching books across multiple online providers.
class BookSearchView extends ConsumerStatefulWidget {
  final String? initialQuery;
  const BookSearchView({super.key, this.initialQuery});

  @override
  ConsumerState<BookSearchView> createState() => _BookSearchViewState();
}

class _BookSearchViewState extends ConsumerState<BookSearchView> {
  late final TextEditingController _ctrl;
  final _focusNode = FocusNode();

  List<BookSearchResult> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    
    // Automatically focus search bar or trigger search if query provided.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery == null) {
        _focusNode.requestFocus();
      } else {
        _search();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Triggers a parallel multi-provider search.
  Future<void> _search() async {
    final query = _ctrl.text.trim();
    if (query.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });

    try {
      final settings = ref.read(appSettingsProvider);
      
      // Direct call to the static orchestration service.
      final results = await BookSearchService.searchAll(
        query,
        servers: settings.searchServers,
        googleApiKey: settings.googleBooksApiKey,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.bookSearchErrorNetwork;
          _loading = false;
        });
      }
    }
  }

  void _openForm(BookSearchResult result) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) =>
            BookFormView(prefill: result),
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

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: context.l10n.bookSearchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        toolbarHeight: 56,
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                setState(() {
                  _results = [];
                  _searched = false;
                  _error = null;
                });
                _focusNode.requestFocus();
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  String _label(BookSearchServer s) => switch (s) {
    BookSearchServer.openLibrary => 'Open Library',
    BookSearchServer.googleBooks => 'Google Books',
    BookSearchServer.inventaire => 'Inventaire.io',
  };

  Widget _buildBody(ColorScheme colorScheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: _search,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!_searched) {
      final activeServers = ref.watch(appSettingsProvider.select((s) => s.searchServers));

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              context.l10n.bookSearchPrompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: activeServers.map((s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public, size: 13, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    _label(s),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              )).toList(),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              context.l10n.bookSearchNoResults(_ctrl.text),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) =>
          _ResultTile(result: _results[index], onTap: _openForm),
    );
  }
}

/// Compact result tile for a book search result.
class _ResultTile extends StatelessWidget {
  final BookSearchResult result;
  final ValueChanged<BookSearchResult> onTap;

  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isRecommended = result.source == 'Recommended by Openshelf';

    return InkWell(
      onTap: () => onTap(result),
      child: Container(
        color: isRecommended ? colorScheme.primaryContainer.withValues(alpha: 0.15) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 48,
                height: 68,
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
            const SizedBox(width: 12),

            // Metadata Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRecommended)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.bookSearchRecommended,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
            Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
          ],
        ),
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
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
