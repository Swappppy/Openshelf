import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../book_form/book_form_view.dart';
import '../../models/book_search_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/book_search_service.dart';
import '../../l10n/l10n_extension.dart';

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
  String? _fallbackNotice;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    // Abre el teclado al entrar si no hay query inicial
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

  Future<void> _search() async {
    final query = _ctrl.text.trim();
    if (query.isEmpty) return;

    debugPrint('BookSearchView: Searching for "$query"');
    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });

    try {
      final service = ref.read(bookSearchServiceProvider);
      final response = await service.search(query);
      if (mounted) {
        setState(() {
          _results = response.results;
          _fallbackNotice = response.usedFallback != null
              ? context.l10n.bookSearchFallbackNotice(response.usedFallback!)
              : null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        setState(() {
          _error = msg.contains('no_api_key')
              ? context.l10n.bookSearchErrorNoApiKey
              : msg.contains('rate_limit')
              ? context.l10n.bookSearchErrorRateLimit
              : context.l10n.bookSearchErrorNetwork;
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
                  _fallbackNotice = null;
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
      final service = ref.watch(bookSearchServiceProvider);
      final serverLabel = switch (service.server) {
        BookSearchServer.openLibrary => 'Open Library',
        BookSearchServer.googleBooks => 'Google Books',
      };
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 13, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  serverLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
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

    return Column(
      children: [
        if (_fallbackNotice != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: colorScheme.onTertiaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fallbackNotice!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) =>
                _ResultTile(result: _results[index], onTap: _openForm),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------
// Tile de resultado
// -------------------------------------------------------
class _ResultTile extends StatelessWidget {
  final BookSearchResult result;
  final ValueChanged<BookSearchResult> onTap;

  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura portada
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 48,
                height: 68,
                child: result.coverUrl != null
                    ? Image.network(
                  result.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _CoverPlaceholder(colorScheme: colorScheme),
                )
                    : _CoverPlaceholder(colorScheme: colorScheme),
              ),
            ),
            const SizedBox(width: 12),

            // Datos
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
                  if (result.author.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (result.publishYear != null)
                        _MetaChip(label: '${result.publishYear}'),
                      if (result.publisher != null)
                        _MetaChip(label: result.publisher!),
                      if (result.totalPages != null)
                        _MetaChip(label: context.l10n.pageSuffix(result.totalPages!)),
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

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

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