import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../controllers/database_provider.dart';
import '../../services/database.dart';
import '../../services/book_search_service.dart';
import '../../controllers/app_settings_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../book_search/book_search_view.dart';

class SearchHistoryView extends ConsumerStatefulWidget {
  const SearchHistoryView({super.key});

  @override
  ConsumerState<SearchHistoryView> createState() => _SearchHistoryViewState();
}

class _SearchHistoryViewState extends ConsumerState<SearchHistoryView> {
  bool _isRetrying = false;

  Future<void> _retryItem(SearchHistoryData item) async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    try {
      final historyDao = ref.read(searchHistoryDaoProvider);
      final settings = ref.read(appSettingsProvider);
      final db = ref.read(databaseProvider);

      if (item.type == 'isbn_scan' || item.type == 'batch_scan') {
        final code = item.query;
        final existing = await db.bookDao.getBookByIsbn(code);
        if (existing != null) {
          await historyDao.updateEntry(item.copyWith(status: 'success'));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.errorDuplicateIsbn)),
            );
          }
          return;
        }

        final results = await BookSearchService.searchByIsbn(
          code,
          servers: settings.searchServers,
          googleApiKey: settings.googleBooksApiKey,
          preferredLanguage: settings.locale?.languageCode,
        );

        if (results.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.bookSearchNoResults(code))),
            );
          }
          return;
        }

        final book = results.first;
        final insertedBook = book.toCompanion();
        final id = await db.bookDao.insertBook(insertedBook);

        if (book.categories.isNotEmpty) {
          final tagIds = <int>[];
          for (final cat in book.categories) {
            tagIds.add(await db.tagDao.getOrCreateCategory(cat));
          }
          await db.tagDao.setBookTags(id, tagIds);
        }

        await historyDao.updateEntry(item.copyWith(
          status: 'success',
          title: Value(book.title),
          author: Value(book.authors.join(', ')),
          publisher: Value(book.publisher),
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(book.title)),
          );
        }
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookSearchView(
                initialQuery: item.query,
                initialTitle: item.title,
                initialAuthor: item.author,
                initialPublisher: item.publisher,
                initialIsbn: (item.type == 'isbn_scan' || item.type == 'batch_scan') ? item.query : null,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.bookSearchErrorNetwork)),
        );
      }
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyDao = ref.watch(searchHistoryDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.searchHistoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: context.l10n.searchHistoryClear,
            onPressed: () async {
              await historyDao.clearHistory();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<SearchHistoryData>>(
        stream: historyDao.watchAllHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.searchHistoryEmpty,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSuccess = item.status == 'success';
              final isFailed = item.status == 'failed';

              IconData typeIcon;
              if (item.type == 'isbn_scan') {
                typeIcon = Icons.qr_code_scanner;
              } else if (item.type == 'batch_scan') {
                typeIcon = Icons.document_scanner_outlined;
              } else {
                typeIcon = Icons.search;
              }

              String statusLabel;
              if (isSuccess) {
                statusLabel = context.l10n.searchHistoryStatusSuccess;
              } else if (isFailed) {
                statusLabel = context.l10n.searchHistoryStatusFailed;
              } else {
                statusLabel = context.l10n.searchHistoryStatusPending;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSuccess
                        ? Colors.green.withValues(alpha: 0.2)
                        : isFailed
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                    child: Icon(
                      typeIcon,
                      color: isSuccess
                          ? Colors.green
                          : isFailed
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                  title: Text(
                    item.title ?? item.query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title != null)
                        Text(
                          '${context.l10n.fieldIsbn}: ${item.query}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.author != null)
                        Text(
                          '${context.l10n.searchFieldAuthor}: ${item.author}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.publisher != null)
                        Text(
                          '${context.l10n.searchFieldPublisher}: ${item.publisher}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : isFailed
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSuccess
                                    ? Colors.green
                                    : isFailed
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSuccess)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: context.l10n.retry,
                          onPressed: _isRetrying ? null : () => _retryItem(item),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => historyDao.deleteEntry(item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
