import 'dart:async';
import 'package:flutter/foundation.dart';
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
      // One round per provider instead of repeating near-identical searches:
      //  1. ISBN lookup (exact edition) on every provider.
      //  2. One text search per provider, skipped where the ISBN lookup already
      //     identified the work, since the work's editions are then fetched
      //     directly and give more covers than any text search.
      // Depth comes from fetching ALL editions of the matched works (Open
      // Library editions.json, Inventaire batched editions), not from issuing
      // more searches.
      final cleanIsbn = isbn?.replaceAll(RegExp(r'[^0-9X]'), '') ?? '';
      final hasIsbn = cleanIsbn.isNotEmpty;
      final cleanTitle = title?.trim() ?? '';
      final hasTitle = cleanTitle.isNotEmpty;
      final cleanAuthor = author?.trim() ?? '';
      final cleanPublisher = publisher?.trim() ?? '';

      String? olWorkKey;
      var inventaireWorkFound = false;

      bool authorMatches(BookSearchResult r) {
        if (cleanAuthor.isEmpty) return true;
        final surname = _normalize(cleanAuthor.split(' ').last);
        if (surname.isEmpty) return true;
        final haystack = _normalize('${r.authors.join(' ')} ${r.description ?? ''}');
        return haystack.contains(surname);
      }

      try {
        // ---- 1. ISBN ----
        if (hasIsbn) {
          debugPrint('CoverSearch: ISBN round - "$cleanIsbn"');
          for (final server in servers) {
            if (isCancelled) return;
            try {
              switch (server) {
                case BookSearchServer.googleBooks:
                  final res = await GoogleBooksService.getByIsbn(cleanIsbn, apiKey: apiKey, preferredLanguage: preferredLanguage);
                  if (res?.coverUrl != null && _isRelevant(res!.title, cleanTitle)) {
                    addCandidate(res.coverUrl!, 'Google Books');
                  }
                  break;
                case BookSearchServer.openLibrary:
                  final res = await OpenLibraryService.getByIsbn(cleanIsbn, preferredLanguage: preferredLanguage);
                  if (res != null && _isRelevant(res.title, cleanTitle)) {
                    if (res.coverUrl != null) addCandidate(res.coverUrl!, 'Open Library');
                    olWorkKey = res.openLibraryWorkKey;
                  }
                  break;
                case BookSearchServer.inventaire:
                  final found = await InventaireService.getByIsbnWithEditions(cleanIsbn, preferredLanguage: preferredLanguage);
                  final res = found.result;
                  if (res != null && _isRelevant(res.title, cleanTitle)) {
                    if (res.coverUrl != null) addCandidate(res.coverUrl!, 'Inventaire');
                    for (final ed in found.editions) {
                      if (isCancelled) return;
                      if (ed.coverUrl != null) addCandidate(ed.coverUrl!, 'Inventaire (Ed.)');
                    }
                    inventaireWorkFound = res.inventaireWorkUri != null;
                  }
                  break;
              }
            } catch (e) {
              debugPrint('CoverSearch: ISBN error from ${server.name}: $e');
            }
          }
        }

        // ---- 2. One text search per provider ----
        for (final server in servers) {
          if (isCancelled) return;
          try {
            switch (server) {
              case BookSearchServer.googleBooks:
                // Google has no work grouping, so its text search is the only
                // way to reach other editions. Title + author with up to 40
                // results already includes the publisher's edition unless the
                // result set is saturated; only then is the publisher added.
                if (!hasTitle) break;
                debugPrint('CoverSearch: Google text round');
                final results = await GoogleBooksService.search(
                  cleanTitle,
                  apiKey: apiKey,
                  preferredLanguage: preferredLanguage,
                  title: cleanTitle,
                  author: cleanAuthor.isNotEmpty ? cleanAuthor : null,
                );
                for (final res in results) {
                  if (isCancelled) return;
                  if (res.coverUrl != null && _isRelevant(res.title, cleanTitle)) addCandidate(res.coverUrl!, 'Google Books');
                }
                if (results.length >= 40 && cleanPublisher.isNotEmpty) {
                  if (isCancelled) return;
                  final narrowed = await GoogleBooksService.search(
                    cleanTitle,
                    apiKey: apiKey,
                    preferredLanguage: preferredLanguage,
                    title: cleanTitle,
                    publisher: cleanPublisher,
                  );
                  for (final res in narrowed) {
                    if (isCancelled) return;
                    if (res.coverUrl != null && _isRelevant(res.title, cleanTitle)) addCandidate(res.coverUrl!, 'Google Books');
                  }
                }
                break;

              case BookSearchServer.openLibrary:
                if (olWorkKey == null && hasTitle) {
                  debugPrint('CoverSearch: Open Library text round');
                  final results = await OpenLibraryService.searchStructured(
                    BookSearchQuery(title: cleanTitle, author: cleanAuthor.isNotEmpty ? cleanAuthor : null),
                    preferredLanguage: preferredLanguage,
                  );
                  for (final res in results) {
                    if (isCancelled) return;
                    if (!_isRelevant(res.title, cleanTitle)) continue;
                    if (res.coverUrl != null) addCandidate(res.coverUrl!, 'Open Library');
                    if (olWorkKey == null && res.openLibraryWorkKey != null && authorMatches(res)) {
                      olWorkKey = res.openLibraryWorkKey;
                    }
                  }
                }
                final workKey = olWorkKey;
                if (workKey != null) {
                  if (isCancelled) return;
                  for (final url in await OpenLibraryService.getEditionCoverUrls(workKey)) {
                    if (isCancelled) return;
                    addCandidate(url, 'Open Library (Ed.)');
                  }
                }
                break;

              case BookSearchServer.inventaire:
                if (inventaireWorkFound || !hasTitle) break;
                debugPrint('CoverSearch: Inventaire text round');
                final works = await InventaireService.searchWorksWithEditions(
                  cleanTitle,
                  preferredLanguage: preferredLanguage,
                  limit: 10,
                );
                for (final entry in works) {
                  if (isCancelled) return;
                  if (!_isRelevant(entry.work.title, cleanTitle)) continue;
                  if (entry.work.coverUrl != null) addCandidate(entry.work.coverUrl!, 'Inventaire');
                  // Edition covers only for works by the right author, so a
                  // homonymous work does not flood the picker.
                  if (!authorMatches(entry.work)) continue;
                  for (final ed in entry.editions) {
                    if (isCancelled) return;
                    if (ed.coverUrl != null) addCandidate(ed.coverUrl!, 'Inventaire (Ed.)');
                  }
                }
                break;
            }
          } catch (e) {
            debugPrint('CoverSearch: text error from ${server.name}: $e');
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
