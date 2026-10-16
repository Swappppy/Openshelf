import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/app_settings_controller.dart';
import '../../../controllers/book_search_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../models/app_settings.dart';
import '../../../models/book_search_result.dart';
import '../../book_form/book_form_view.dart';
import '../work_editions_view.dart';
import 'book_search_tile.dart';

/// Body component of the book search screen managing loading, error, prompt, empty, and results states.
class BookSearchBody extends ConsumerWidget {
  final BookSearchController controller;

  const BookSearchBody({super.key, required this.controller});

  String _serverLabel(BookSearchServer server, BuildContext context) {
    switch (server) {
      case BookSearchServer.googleBooks:
        return context.l10n.bookSearchServerGoogleBooks;
      case BookSearchServer.openLibrary:
        return context.l10n.bookSearchServerOpenLibrary;
      case BookSearchServer.inventaire:
        return context.l10n.bookSearchServerInventaire;
      case BookSearchServer.annasArchive:
        return context.l10n.bookSearchServerAnnasArchive;
    }
  }

  void _handleResultTap(BuildContext context, BookSearchResult result) {
    final hasWorkKey = result.openLibraryWorkKey != null || result.inventaireWorkUri != null;
    final hasMultipleEditions = result.editionCount != null
        ? result.editionCount! > 1
        : hasWorkKey;

    if (hasMultipleEditions) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkEditionsView(workResult: result),
        ),
      );
    } else {
      _openForm(context, result);
    }
  }

  void _openForm(BuildContext context, BookSearchResult result) {
    var finalResult = result;
    final isbnInput = controller.isbnController.text.trim().replaceAll(RegExp(r'[^0-9X]'), '');
    final isIsbn = (isbnInput.length == 10 || isbnInput.length == 13) && RegExp(r'^[0-9]+X?$').hasMatch(isbnInput);

    if (isIsbn && (result.isbn == null || result.isbn!.isEmpty)) {
      finalResult = result.copyWith(isbn: isbnInput);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.loading && controller.results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null && controller.results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.tonal(
                    onPressed: () => controller.search(context, networkErrorMsg: context.l10n.bookSearchErrorNetwork),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (!controller.searched) {
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
                  children: activeServers
                      .map((s) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public, size: 13, color: colorScheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                _serverLabel(s, context),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        }

        if (controller.results.isEmpty) {
          final isbnInput = controller.isbnController.text.trim().replaceAll(RegExp(r'[^0-9X]'), '');
          final isIsbn = (isbnInput.length == 10 || isbnInput.length == 13) &&
              RegExp(r'^[0-9]+X?$').hasMatch(isbnInput);

          final displayQuery = [
            controller.titleController.text.trim(),
            controller.authorController.text.trim(),
            controller.publisherController.text.trim(),
            controller.isbnController.text.trim(),
          ].where((s) => s.isNotEmpty).join(' - ');

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: colorScheme.outline),
                const SizedBox(height: 12),
                Text(
                  context.l10n.bookSearchNoResults(displayQuery),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (isIsbn || controller.hasAnyInput) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookFormView(
                            prefill: BookSearchResult(
                              title: controller.titleController.text.trim(),
                              authors: controller.authorController.text.trim().isNotEmpty
                                  ? [controller.authorController.text.trim()]
                                  : [],
                              isbn: isbnInput.isNotEmpty ? isbnInput : null,
                              publisher: controller.publisherController.text.trim().isNotEmpty
                                  ? controller.publisherController.text.trim()
                                  : null,
                              source: 'Manual entry',
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.addManually),
                  ),
                ],
              ],
            ),
          );
        }

        return Column(
          children: [
            if (controller.loading)
              LinearProgressIndicator(
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 3,
              ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.results.length,
                itemBuilder: (context, index) => BookSearchResultTile(
                  result: controller.results[index],
                  onTap: (result) => _handleResultTap(context, result),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
