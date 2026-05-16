import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/app_settings_controller.dart';
import '../../services/book_search_service.dart';
import '../../services/cover_service.dart';
import '../../l10n/l10n_extension.dart';

/// Modal sheet that allows users to pick an alternative cover image from online sources.
class CoverPickerSheet extends ConsumerStatefulWidget {
  final String? isbn;
  final String? title;
  final String? author;
  final String? publisher;
  final ValueChanged<String> onCoverSelected;

  const CoverPickerSheet({
    super.key,
    this.isbn,
    this.title,
    this.author,
    this.publisher,
    required this.onCoverSelected,
  });

  @override
  ConsumerState<CoverPickerSheet> createState() => _CoverPickerSheetState();
}

class _CoverPickerSheetState extends ConsumerState<CoverPickerSheet> {
  /// List of potential cover images and their local temporary preview paths.
  final List<(CoverCandidate, String?)> _items = [];
  bool _searching = true;
  String? _error;
  
  /// Index of the item currently being finalized and saved.
  int? _saving;

  @override
  void initState() {
    super.initState();
    _search();
  }

  /// Triggers the online search for cover candidates.
  Future<void> _search() async {
    final settings = ref.read(appSettingsProvider);
    final apiKey = settings.googleBooksApiKey;
    final lang = settings.locale?.languageCode;

    try {
      final stream = CoverSearchService.search(
        isbn: widget.isbn,
        title: widget.title,
        author: widget.author,
        publisher: widget.publisher,
        apiKey: apiKey,
        preferredLanguage: lang,
        servers: settings.searchServers,
      );

      await for (final candidate in stream) {
        if (!mounted) return;
        setState(() {
          _searching = false; // Stop initial full-screen spinner
          _items.add((candidate, null));
        });
        _downloadSinglePreview(_items.length - 1);
      }

      if (mounted && _items.isEmpty) {
        setState(() {
          _searching = false;
          _error = context.l10n.coverPickerNoResults;
        });
      } else if (mounted) {
        setState(() => _searching = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searching = false;
          _error = context.l10n.coverPickerNetworkError;
        });
      }
    }
  }

  /// Downloads a single preview image.
  Future<void> _downloadSinglePreview(int index) async {
    if (index >= _items.length) return;
    final (candidate, _) = _items[index];
    
    final path = await CoverService.downloadForPreview(candidate.url);
    if (mounted) {
      setState(() {
        _items[index] = (candidate, path ?? ''); // Use empty string to signal failure
      });
    }
  }

  /// Finalizes selection, handles cropping if necessary, and saves the image permanently.
  Future<void> _selectCover(int index) async {
    final (candidate, previewPath) = _items[index];
    if (previewPath == null || previewPath.isEmpty) return;

    setState(() => _saving = index);

    // Smart Crop: check if the aspect ratio is already close to 2:3
    final isGood = await CoverService.isRatioCorrect(previewPath, 2 / 3);
    
    String finalPath;
    if (isGood) {
      finalPath = await CoverService.saveCover(previewPath);
    } else {
      if (!mounted) return;
      final l10n = context.l10n;
      // Manual crop is standard for consistent library appearance.
      final croppedPath = await CoverService.cropCover(
        previewPath, 
        title: l10n.cropCoverTitle,
        doneButtonTitle: l10n.done,
        cancelButtonTitle: l10n.cancel,
      );
      if (croppedPath == null) {
        if (mounted) setState(() => _saving = null);
        return;
      }
      
      finalPath = await CoverService.saveCover(croppedPath);
    }

    if (mounted) {
      widget.onCoverSelected(finalPath);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          // Header section with drag handle and search status.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.coverPickerTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (widget.isbn != null)
                            Text(
                              context.l10n.coverPickerIsbnLabel(widget.isbn!),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colorScheme.outline),
                            )
                          else if (widget.title != null)
                            Text(
                              widget.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colorScheme.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (_searching)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          Expanded(child: _buildBody(scrollController, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildBody(ScrollController scroll, ColorScheme colorScheme) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 56, color: colorScheme.outline),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.outline)),
            ],
          ),
        ),
      );
    }

    final loaded = _items.where((e) => e.$2 != null).length;
    final total = _items.length;

    return GridView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _items.length + (loaded < total ? 1 : 0),
      itemBuilder: (context, index) {
        // Progress cell at the end while loading.
        if (index == _items.length) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.coverPickerProgress(loaded, total),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          );
        }

        final (candidate, previewPath) = _items[index];
        final isSaving = _saving == index;

        return GestureDetector(
          onTap: previewPath != null && previewPath.isNotEmpty && _saving == null
              ? () => _selectCover(index)
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: previewPath != null
                    ? (previewPath.isEmpty
                        ? Center(child: Icon(Icons.broken_image, color: colorScheme.error, size: 24))
                        : Image.file(
                  File(previewPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: colorScheme.surfaceContainerHighest),
                ))
                    : Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),

              // Source Badge
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6)),
                  ),
                  child: Text(
                    _formatSourceLabel(candidate.source),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (isSaving)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatSourceLabel(String source) {
    if (source.contains('Google')) return 'Google';
    if (source.contains('Inventaire')) return 'Inventaire';
    if (source.contains('Open Library')) return 'OL';
    return source;
  }
}
