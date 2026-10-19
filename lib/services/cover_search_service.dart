import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/app_settings.dart';
import '../models/book_search_query.dart';
import '../models/book_search_result.dart';
import 'google_books_service.dart';
import 'open_library_service.dart';
import 'inventaire_service.dart';

/// Specialized service for finding alternative cover images for a book.
class CoverSearchService {
  /// Searches for potential cover images across multiple providers using book metadata.
  /// Returns a stream of candidates as they are found.
  static Stream<CoverCandidate> search({
    String? isbn,
    String? title,
    String? author,
    String? publisher,
    String? apiKey,
    String? preferredLanguage,
    List<BookSearchServer> servers = const [
      BookSearchServer.googleBooks,
      BookSearchServer.openLibrary,
      BookSearchServer.inventaire,
    ],
  }) {
    bool isCancelled = false;
    final controller = StreamController<CoverCandidate>(
      onCancel: () {
        isCancelled = true;
      },
    );
    final seenUrls = <String>{};
    int foundCount = 0;

    void addCandidate(String url, String source) {
      if (url.trim().isEmpty) return;
      if (!seenUrls.contains(url)) {
        seenUrls.add(url);
        foundCount++;
        controller.add(CoverCandidate(url: url, source: source));
      }
    }

    Future<void> runSearch() async {
      try {
        // 1. ISBN Search (Specific high-confidence lookup as primary)
        if (isbn != null) {
          if (isCancelled) return;
          debugPrint('CoverSearch: Step 1 (ISBN) - ISBN: "$isbn"');
          for (final server in servers) {
            if (isCancelled) return;
            try {
              switch (server) {
                case BookSearchServer.googleBooks:
                  final res = await GoogleBooksService.getByIsbn(isbn, apiKey: apiKey, preferredLanguage: preferredLanguage);
                  if (res?.coverUrl != null && _isRelevant(res!.title, title ?? '')) {
                    addCandidate(res.coverUrl!, 'Google Books');
                  }
                  break;
                case BookSearchServer.openLibrary:
                  final res = await OpenLibraryService.getByIsbn(isbn);
                  if (res?.coverUrl != null && _isRelevant(res!.title, title ?? '')) {
                    addCandidate(res.coverUrl!, 'Open Library');
                  }
                  break;
                case BookSearchServer.inventaire:
                  final res = await InventaireService.getByIsbn(isbn, preferredLanguage: preferredLanguage);
                  if (res?.coverUrl != null && _isRelevant(res!.title, title ?? '')) {
                    addCandidate(res.coverUrl!, 'Inventaire');
                  }
                  break;
              }
            } catch (e) {
              debugPrint('CoverSearch: ISBN Error from ${server.name}: $e');
            }
          }
        }

        // 2. Precise Text Search (Title + Publisher)
        if (title != null && publisher != null && publisher.isNotEmpty) {
          if (isCancelled) return;
          final query = '"$title" $publisher';
          debugPrint('CoverSearch: Step 2 (Precise Title+Publisher) - Query: "$query"');

          for (final server in servers) {
            if (isCancelled) return;
            try {
              List<BookSearchResult> results = [];
              switch (server) {
                case BookSearchServer.googleBooks:
                  results = await GoogleBooksService.search(
                    query,
                    apiKey: apiKey,
                    preferredLanguage: preferredLanguage,
                    title: title,
                    publisher: publisher,
                  );
                  break;
                case BookSearchServer.openLibrary:
                  results = await OpenLibraryService.search(query);
                  break;
                case BookSearchServer.inventaire:
                  results = await InventaireService.search(query, preferredLanguage: preferredLanguage);
                  break;
              }
              for (final res in results) {
                if (isCancelled) return;
                if (res.coverUrl != null && _isRelevant(res.title, title)) {
                  addCandidate(res.coverUrl!, server.name);
                }
              }
            } catch (e) {
              debugPrint('CoverSearch: Error in precise search for ${server.name}: $e');
            }
          }
        }

        // 3. Specific Text Search (Title + Author) - Primary or Fallback
        if (title != null) {
          if (isCancelled) return;
          final queryParts = [
            '"$title"',
            if (author != null && author.isNotEmpty) author,
          ];
          final query = queryParts.join(' ');
          debugPrint('CoverSearch: Step 3 (Specific Title+Author) - Query: "$query"');

          for (final server in servers) {
            if (isCancelled) return;
            try {
              List<BookSearchResult> results = [];
              switch (server) {
                case BookSearchServer.googleBooks:
                  results = await GoogleBooksService.search(
                    query,
                    apiKey: apiKey,
                    preferredLanguage: preferredLanguage,
                    title: title,
                    author: author,
                  );
                  break;
                case BookSearchServer.openLibrary:
                  results = await OpenLibraryService.search(query);
                  break;
                case BookSearchServer.inventaire:
                  results = await InventaireService.search(query, preferredLanguage: preferredLanguage);
                  break;
              }
              for (final res in results) {
                if (isCancelled) return;
                if (res.coverUrl != null && _isRelevant(res.title, title)) {
                  addCandidate(res.coverUrl!, server.name);
                }
              }
            } catch (e) {
              debugPrint('CoverSearch: Error in specific search for ${server.name}: $e');
            }
          }
        }

        // 4. Inventaire editions fallback
        if (title != null && servers.contains(BookSearchServer.inventaire)) {
          if (isCancelled) return;
          debugPrint('CoverSearch: Step 4 (Inventaire Deep Dive)');
          try {
            final works = await InventaireService.search(title, preferredLanguage: preferredLanguage, limit: 10);

            final candidateWorks = works.where((w) => w.inventaireWorkUri != null).toList();

            int scoreWork(BookSearchResult w) {
              int score = 0;
              if (_isRelevant(w.title, title)) score += 10;
              if (author != null && author.isNotEmpty) {
                final surname = _normalize(author.trim().split(' ').last);
                final desc = _normalize(w.description ?? '');
                if (desc.contains(surname)) score += 20;
              }
              return score;
            }

            candidateWorks.sort((a, b) => scoreWork(b).compareTo(scoreWork(a)));

            final bestWork = candidateWorks.firstOrNull;
            final bestScore = bestWork != null ? scoreWork(bestWork) : 0;
            final workUri = bestWork?.inventaireWorkUri;

            if (bestScore < 20) {
              debugPrint('CoverSearch: Step 4 skipped - best score $bestScore too low for "${bestWork?.title}"');
            } else if (workUri != null) {
              if (isCancelled) return;
              debugPrint('CoverSearch: Step 4 - Using work "$workUri" (${bestWork!.title}) with score $bestScore');
              final editions = await InventaireService.getEditionsByWork(
                workUri,
                preferredLanguage: preferredLanguage,
              );
              for (final ed in editions) {
                if (isCancelled) return;
                if (ed.coverUrl != null) {
                  addCandidate(ed.coverUrl!, 'Inventaire (Ed.)');
                }
              }
            }
          } catch (e) {
            debugPrint('CoverSearch: Step 4 Error: $e');
          }
        }
      } finally {
        if (!controller.isClosed) {
          await controller.close();
          debugPrint('CoverSearch: Stream closed. Total unique candidates found: $foundCount');
        } else {
          debugPrint('CoverSearch: Interrupted by caller. Found $foundCount candidates before stopping.');
        }
      }
    }

    runSearch();
    return controller.stream;
  }

  static bool _isRelevant(String resultTitle, String targetTitle) {
    if (targetTitle.isEmpty) return true;

    final resNorm = _normalize(resultTitle);
    final tgtNorm = _normalize(targetTitle);

    if (resNorm.contains(tgtNorm) || tgtNorm.contains(resNorm)) return true;

    final keywords = tgtNorm
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (keywords.isEmpty) return true;

    int matchCount = 0;
    for (final kw in keywords) {
      if (resNorm.contains(kw)) matchCount++;
    }

    final relevance = matchCount / keywords.length;
    return relevance >= 0.4;
  }

  static String _normalize(String s) {
    var norm = s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
      .replaceAll('ü', 'u').replaceAll('ñ', 'n');
    return norm.replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
