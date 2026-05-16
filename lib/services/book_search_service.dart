import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import '../models/app_settings.dart';
import '../models/book_search_result.dart';
import 'google_books_service.dart';
import 'open_library_service.dart';
import 'inventaire_service.dart';

/// Represents a potential cover image found online.
class CoverCandidate {
  final String url;
  final String source;
  CoverCandidate({required this.url, required this.source});
}

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
    final controller = StreamController<CoverCandidate>();
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
          debugPrint('CoverSearch: Step 1 (ISBN) - ISBN: "$isbn"');
          for (final server in servers) {
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
          final query = '"$title" $publisher';
          debugPrint('CoverSearch: Step 2 (Precise Title+Publisher) - Query: "$query"');
          
          for (final server in servers) {
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
          final queryParts = [
            '"$title"',
            if (author != null && author.isNotEmpty) author,
          ];
          final query = queryParts.join(' ');
          debugPrint('CoverSearch: Step 3 (Specific Title+Author) - Query: "$query"');
          
          for (final server in servers) {
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
                if (res.coverUrl != null && _isRelevant(res.title, title)) {
                  addCandidate(res.coverUrl!, server.name);
                }
              }
            } catch (e) {
              debugPrint('CoverSearch: Error in specific search for ${server.name}: $e');
            }
          }
        }

        // 4. Inventaire editions fallback — always execute if provider active
        if (title != null && servers.contains(BookSearchServer.inventaire)) {
          debugPrint('CoverSearch: Step 4 (Inventaire Deep Dive)');
          try {
            final works = await InventaireService.search(title, preferredLanguage: preferredLanguage, limit: 10);
            
            final candidateWorks = works.where((w) => w.inventaireWorkUri != null).toList();

            // Scoring: every work gets points for title and author match
            int scoreWork(BookSearchResult w) {
              int score = 0;
              if (_isRelevant(w.title, title)) score += 10;
              if (author != null && author.isNotEmpty) {
                final surname = _normalize(author.trim().split(' ').last);
                final desc = _normalize(w.description ?? '');
                if (desc.contains(surname)) score += 20; // Author carries more weight than title
              }
              return score;
            }

            // Sort by score descending; preserves Inventaire order (popularity) for ties
            candidateWorks.sort((a, b) => scoreWork(b).compareTo(scoreWork(a)));
            
            final bestWork = candidateWorks.firstOrNull;
            final bestScore = bestWork != null ? scoreWork(bestWork) : 0;
            final workUri = bestWork?.inventaireWorkUri;
            
            // Require a minimum score (at least an author match) to avoid false positives
            if (bestScore < 20) {
              debugPrint('CoverSearch: Step 4 skipped - best score $bestScore too low for "${bestWork?.title}"');
            } else if (workUri != null) {
              debugPrint('CoverSearch: Step 4 - Using work "$workUri" (${bestWork!.title}) with score $bestScore');
              final editions = await InventaireService.getEditionsByWork(
                workUri,
                preferredLanguage: preferredLanguage,
              );
              for (final ed in editions) {
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
        await controller.close();
        debugPrint('CoverSearch: Stream closed. Total unique candidates found: $foundCount');
      }
    }

    runSearch();
    return controller.stream;
  }

  /// Checks if a result title is relevant to the target title using a keyword-based heuristic.
  static bool _isRelevant(String resultTitle, String targetTitle) {
    if (targetTitle.isEmpty) return true;
    
    final resNorm = _normalize(resultTitle);
    final tgtNorm = _normalize(targetTitle);
    
    // Direct inclusion check
    if (resNorm.contains(tgtNorm) || tgtNorm.contains(resNorm)) return true;

    // Keyword overlap check (ignore very short common words)
    final keywords = tgtNorm
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2) // Allow words like 'II', 'del', 'the' etc are still ignored
        .toList();
    
    if (keywords.isEmpty) return true;

    int matchCount = 0;
    for (final kw in keywords) {
      if (resNorm.contains(kw)) matchCount++;
    }
    
    // Threshold: At least 50% of significant keywords must match
    final relevance = matchCount / keywords.length;
    return relevance >= 0.4; // Slightly more lenient
  }

  /// Normalize: lowercase, remove accents, and strip non-alphanumeric
  static String _normalize(String s) {
    // Simple accent removal for common Spanish/Latin chars
    var norm = s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
      .replaceAll('ü', 'u').replaceAll('ñ', 'n');
    return norm.replaceAll(RegExp(r'[^\w\s]'), ' ');
  }
}

/// Orchestrates multi-provider book searches and merges results intelligently.
class BookSearchService {
  /// Queries specified providers sequentially in the order defined in settings.
  static Future<List<BookSearchResult>> searchAll(
    String query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) async {
    final cleanIsbn = query.replaceAll(RegExp(r'[^0-9X]'), '');
    final isIsbn = (cleanIsbn.length == 10 || cleanIsbn.length == 13) && RegExp(r'^[0-9]+X?$').hasMatch(cleanIsbn);

    final List<BookSearchResult> allResults = [];
    
    // We execute in sequence to respect the server order from settings
    for (final server in servers) {
      try {
        debugPrint('BookSearchService: Querying ${server.name}...');
        List<BookSearchResult> serverResults = [];
        if (isIsbn) {
          final res = await _performIsbnLookup(server, cleanIsbn, googleApiKey, preferredLanguage);
          if (res != null) {
            serverResults.add(res);
          } else {
            // Fallback to general search if ISBN lookup failed
            serverResults.addAll(await _performGeneralSearch(server, query, googleApiKey, preferredLanguage));
          }
        } else {
          serverResults.addAll(await _performGeneralSearch(server, query, googleApiKey, preferredLanguage));
        }
        
        debugPrint('BookSearchService: ${server.name} returned ${serverResults.length} results');
        allResults.addAll(serverResults);
      } catch (e) {
        debugPrint('BookSearchService: Error from ${server.name}: $e');
      }
    }

    debugPrint('BookSearchService: Total results: ${allResults.length}');

    if (allResults.isNotEmpty) {
      final merged = _mergeResults(allResults, preferredLanguage: preferredLanguage);
      if (merged != null) {
        debugPrint('BookSearchService: Prepending merged recommended result');
        // Filter out individual provider results that are identical to the merged one
        final others = allResults.where((r) => 
          !(r.isbn == merged.isbn && r.title == merged.title && r.authors.length == merged.authors.length)
        ).toList();

        return [merged, ...others];
      }
    }

    return allResults;
  }

  static Future<BookSearchResult?> _performIsbnLookup(
    BookSearchServer server,
    String isbn,
    String? googleApiKey,
    String? preferredLanguage,
  ) async {
    switch (server) {
      case BookSearchServer.googleBooks:
        return await GoogleBooksService.getByIsbn(isbn, apiKey: googleApiKey, preferredLanguage: preferredLanguage);
      case BookSearchServer.openLibrary:
        return await OpenLibraryService.getByIsbn(isbn);
      case BookSearchServer.inventaire:
        return await InventaireService.getByIsbn(isbn, preferredLanguage: preferredLanguage);
    }
  }

  static Future<List<BookSearchResult>> _performGeneralSearch(
    BookSearchServer server,
    String query,
    String? googleApiKey,
    String? preferredLanguage,
  ) async {
    switch (server) {
      case BookSearchServer.googleBooks:
        return await GoogleBooksService.search(query, apiKey: googleApiKey, preferredLanguage: preferredLanguage);
      case BookSearchServer.openLibrary:
        return await OpenLibraryService.search(query);
      case BookSearchServer.inventaire:
        return await InventaireService.search(query, preferredLanguage: preferredLanguage);
    }
  }

  /// Queries specified providers sequentially using an ISBN.
  static Future<List<BookSearchResult>> searchByIsbn(
    String isbn, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) async {
    final List<BookSearchResult> valid = [];
    
    for (final server in servers) {
      try {
        final res = await _performIsbnLookup(server, isbn, googleApiKey, preferredLanguage);
        if (res != null) {
          valid.add(res);
        }
      } catch (e) {
        debugPrint('BookSearchService: ISBN Error from ${server.name}: $e');
      }
    }

    if (valid.isNotEmpty) {
      final merged = _mergeResults(valid, preferredLanguage: preferredLanguage);
      if (merged != null) {
        final others = valid.where((r) => 
          !(r.isbn == merged.isbn && r.title == merged.title && r.authors.length == merged.authors.length)
        ).toList();
        
        return [merged, ...others];
      }
    }

    return valid;
  }

  /// Heuristically merges multiple search results into one "Best of" result.
  /// It prioritizes the longest title, most resolved authors, and highest resolution cover.
  static BookSearchResult? _mergeResults(List<BookSearchResult> results, {String? preferredLanguage}) {
    if (results.isEmpty) return null;
    if (results.length == 1) return results.first;

    // Try to find the best title matching the preferred language if available
    // For now, we heuristically look for non-English if preferred is ES, etc.
    // But individual services already prioritize language, so the first few results are likely best.

    String bestTitle = results.first.title;
    List<String> bestAuthors = results.first.authors;
    String? bestIsbn = results.first.isbn;
    String? bestCover = results.first.coverUrl;
    String? bestPublisher = results.first.publisher;
    int? bestYear = results.first.publishYear;
    int? bestPages = results.first.pageCount;
    String? bestDesc = results.first.description;
    Set<String> allCategories = {};

    for (final res in results) {
      // Pick the title that seems most complete.
      if (res.title.length > bestTitle.length) bestTitle = res.title;
      
      // Merge unique authors.
      if (res.authors.isNotEmpty && res.authors.first != 'Unknown Author') {
        if (bestAuthors.contains('Unknown Author')) {
          bestAuthors = res.authors;
        }
      }

      // Prioritize ISBNs that are 13 characters long.
      if (res.isbn != null) {
        if (bestIsbn == null || res.isbn!.length > bestIsbn.length) {
          bestIsbn = res.isbn;
        }
      }

      // Keep the first valid cover found.
      if (bestCover == null && res.coverUrl != null) bestCover = res.coverUrl;
      if (bestPublisher == null && res.publisher != null) bestPublisher = res.publisher;
      if (bestYear == null && res.publishYear != null) bestYear = res.publishYear;
      if (bestPages == null && res.pageCount != null) bestPages = res.pageCount;
      if (bestDesc == null && res.description != null) bestDesc = res.description;
      
      allCategories.addAll(res.categories);
    }

    return BookSearchResult(
      title: bestTitle,
      authors: bestAuthors,
      isbn: bestIsbn,
      publisher: bestPublisher,
      coverUrl: bestCover,
      pageCount: bestPages,
      publishYear: bestYear,
      description: bestDesc,
      categories: allCategories.toList(),
      source: 'Recommended by Openshelf',
    );
  }
}
