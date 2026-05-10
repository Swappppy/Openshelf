import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/app_settings_controller.dart';
import '../../services/book_search_service.dart';
import '../../services/cover_service.dart';

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
  // Cada entrada: CoverCandidate + path local del preview (null = cargando)
  final List<(CoverCandidate, String?)> _items = [];
  bool _searching = true;
  String? _error;
  // Índice del que se está guardando definitivamente
  int? _saving;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    final settings = ref.read(appSettingsProvider).value;
    final apiKey = settings?.googleBooksApiKey;

    try {
      final candidates = await CoverSearchService.search(
        isbn: widget.isbn,
        title: widget.title,
        author: widget.author,
        publisher: widget.publisher,
        apiKey: apiKey,
      );

      debugPrint('Candidatos encontrados: ${candidates.length}');
      for (final c in candidates) {
        debugPrint('  ${c.source}: ${c.url}');
      }

      if (!mounted) return;

      if (candidates.isEmpty) {
        setState(() {
          _searching = false;
          _error = 'No se encontraron portadas para este libro.';
        });
        return;
      }

      setState(() {
        _searching = false;
        for (final c in candidates) {
          _items.add((c, null));
        }
      });

      // Descarga previews en paralelo por lotes de 4
      _downloadPreviews();
    } catch (_) {
      if (mounted) {
        setState(() {
          _searching = false;
          _error = 'No se pudo conectar. Comprueba tu conexión.';
        });
      }
    }
  }

  Future<void> _downloadPreviews() async {
    const batchSize = 4;
    for (var i = 0; i < _items.length; i += batchSize) {
      final end =
      (i + batchSize).clamp(0, _items.length);
      final batch = _items.sublist(i, end);

      await Future.wait(
        batch.asMap().entries.map((entry) async {
          final idx = i + entry.key;
          final (candidate, _) = entry.value;
          final path =
          await CoverService.downloadForPreview(candidate.url);
          if (mounted && path != null) {
            setState(() {
              _items[idx] = (candidate, path);
            });
          }
        }),
      );
    }
  }

  Future<void> _selectCover(int index) async {
    final (candidate, previewPath) = _items[index];
    if (previewPath == null) return;

    setState(() => _saving = index);

    // Smart crop: si ya tiene el ratio correcto, guardar directo
    if (await CoverService.isRatioCorrect(previewPath, 2 / 3)) {
      debugPrint('Grid Selection: Ratio correcto, omitiendo recorte.');
      final savedPath = await CoverService.saveCover(previewPath);
      if (mounted) {
        widget.onCoverSelected(savedPath);
        Navigator.pop(context);
      }
      return;
    }

    // Si no, procedemos al recorte manual
    final croppedPath = await CoverService.cropCover(previewPath);
    if (croppedPath == null) {
      if (mounted) setState(() => _saving = null);
      return;
    }
    final savedPath = await CoverService.saveCover(croppedPath);

    if (mounted) {
      widget.onCoverSelected(savedPath);
      Navigator.pop(context);
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
          // Handle + cabecera
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
                            'Portadas',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (widget.isbn != null)
                            Text(
                              'ISBN ${widget.isbn}',
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

          // Cuerpo
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
        // Celda de progreso al final mientras carga
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
                  '$loaded / $total',
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
          onTap: previewPath != null && _saving == null
              ? () => _selectCover(index)
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen o placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: previewPath != null
                    ? Image.file(File(previewPath), fit: BoxFit.cover)
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

              // Badge de fuente
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
                    candidate.source == 'Google Books' ? 'Google' : 'OL',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Overlay de guardado
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
}