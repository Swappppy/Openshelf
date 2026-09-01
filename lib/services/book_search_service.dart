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

        // 4. Inventaire editions fallback — always execute if provider active
        if (title != null && servers.contains(BookSearchServer.inventaire)) {
          if (isCancelled) return;
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
    final isIsbn = (cleanIsbn.length == 10 || cleanIsbn.length == 13) &&
        RegExp(r'^[0-9]+X?$').hasMatch(cleanIsbn);

    final List<BookSearchResult> allResults = [];

    // 1. Fetch results from all servers
    for (final server in servers) {
      try {
        debugPrint('BookSearchService: Querying ${server.name}...');
        List<BookSearchResult> serverResults = [];
        if (isIsbn) {
          final res = await _performIsbnLookup(
              server, cleanIsbn, googleApiKey, preferredLanguage);
          if (res != null) {
            serverResults.add(res);
          } else {
            serverResults.addAll(await _performGeneralSearch(
                server, query, googleApiKey, preferredLanguage));
          }
        } else {
          serverResults.addAll(await _performGeneralSearch(
              server, query, googleApiKey, preferredLanguage));
        }
        allResults.addAll(serverResults);
      } catch (e) {
        debugPrint('BookSearchService: Error from ${server.name}: $e');
      }
    }

    if (allResults.isEmpty) return [];

    // 2. Score and Sort all results by relevance to the query
    final scoredResults = allResults.map((res) {
      // Ensure ISBN is attached if it was an ISBN search
      final r = (isIsbn && (res.isbn == null || res.isbn!.isEmpty))
          ? res.copyWith(isbn: cleanIsbn)
          : res;
      return MapEntry(r, calculateScore(r, query, isIsbn));
    }).toList();

    // Sort descending by score
    scoredResults.sort((a, b) => b.value.compareTo(a.value));

    final sortedResults = scoredResults.map((e) => e.key).toList();
    final winner = sortedResults.first;
    final winnerScore = scoredResults.first.value;

    // 3. Synthesis: Merge the winner with its "Peers" (same book from other sources)
    // We only create a recommendation if the match is decent.
    if (winnerScore >= 400) {
      final peers = sortedResults
          .where((r) => r != winner && arePeers(winner, r))
          .toList();

      final merged = mergeResults(
        [winner, ...peers],
        query: query,
        isIsbn: isIsbn,
        preferredLanguage: preferredLanguage,
      );

      if (merged != null) {
        debugPrint(
            'BookSearchService: Prepending merged recommendation (Score: $winnerScore)');
        // Remove individual provider results that are effectively duplicates of the recommendation
        final others = sortedResults
            .where((r) => !arePeers(merged, r))
            .toList();

        return [merged, ...others];
      }
    }

    return sortedResults;
  }

  /// Calculates a relevance score for a result relative to the query.
  @visibleForTesting
  static double calculateScore(
      BookSearchResult res, String query, bool queryIsIsbn) {
    final cleanQ = query.replaceAll(RegExp(r'[^0-9X]'), '');

    // 1. ISBN Match (Absolute priority)
    if (res.isbn != null) {
      final resIsbn = res.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      if (resIsbn == cleanQ && cleanQ.isNotEmpty) {
        return 5000; // Unbeatable score for exact ISBN
      }
    }

    if (queryIsIsbn) return 0; // If searching by ISBN, only ISBN matches matter for ranking

    // 2. Textual Relevance using Keyword Heuristic (Same as CoverSearchService)
    final resTitle = _normalize(res.title);
    final resAuthors = res.authors.map((a) => _normalize(a)).join(' ');
    final target = _normalize(query);

    if (target.isEmpty) return 0;

    // Direct Exact Title Match
    if (resTitle == target) return 2000;

    // Direct Title Start Match
    if (resTitle.startsWith(target)) return 1500;

    // Keyword Overlap logic
    final keywords = target
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (keywords.isEmpty) {
      // For very short queries (1-2 chars), fallback to simple containment
      return resTitle.contains(target) ? 100 : 0;
    }

    int titleMatches = 0;
    int authorMatches = 0;
    for (final kw in keywords) {
      if (resTitle.contains(kw)) titleMatches++;
      if (resAuthors.contains(kw)) authorMatches++;
    }

    final titleRelevance = titleMatches / keywords.length;
    final authorRelevance = authorMatches / keywords.length;

    // If it doesn't meet a minimum relevance threshold, it's probably noise
    if (titleRelevance < 0.4 && authorRelevance < 0.4) {
      return 0;
    }

    double score = (titleRelevance * 1000) + (authorRelevance * 500);

    // Data richness bonuses (only as tie-breakers)
    if (res.coverUrl != null) score += 10;
    if (res.description != null && res.description!.length > 100) score += 5;
    if (res.publishYear != null) score += 5;

    return score;
  }

  /// Determines if two results represent the same book.
  @visibleForTesting
  static bool arePeers(BookSearchResult a, BookSearchResult b) {
    // Exact ISBN match is definitive
    if (a.isbn != null && b.isbn != null) {
      final isbnA = a.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      final isbnB = b.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      if (isbnA == isbnB && isbnA.isNotEmpty) return true;
    }

    // Title and Author similarity
    final titleA = _normalize(a.title);
    final titleB = _normalize(b.title);

    if (titleA == titleB && titleA.isNotEmpty) {
      // If titles match, check if authors share at least one common word
      if (a.authors.isEmpty || b.authors.isEmpty) return true;
      final authA = a.authors.map((e) => _normalize(e)).join(' ');
      final authB = b.authors.map((e) => _normalize(e)).join(' ');

      final wordsA = authA.split(' ').where((w) => w.length > 3).toSet();
      final wordsB = authB.split(' ').where((w) => w.length > 3).toSet();

      if (wordsA.isEmpty || wordsB.isEmpty) return true;
      return wordsA.intersection(wordsB).isNotEmpty;
    }

    return false;
  }

  /// Normalize: lowercase, remove accents, and strip non-alphanumeric
  static String _normalize(String s) {
    // Simple accent removal for common Spanish/Latin chars
    var norm = s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
      .replaceAll('ü', 'u').replaceAll('ñ', 'n');
    return norm.replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
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
        final res = await _performIsbnLookup(
            server, isbn, googleApiKey, preferredLanguage);
        if (res != null) {
          valid.add((res.isbn == null || res.isbn!.isEmpty)
              ? res.copyWith(isbn: isbn)
              : res);
        }
      } catch (e) {
        debugPrint('BookSearchService: ISBN Error from ${server.name}: $e');
      }
    }

    if (valid.isNotEmpty) {
      final merged = mergeResults(
        valid,
        query: isbn,
        isIsbn: true,
        preferredLanguage: preferredLanguage,
      );
      if (merged != null) {
        final others = valid
            .where((r) => !(r.isbn == merged.isbn &&
                r.title == merged.title &&
                r.authors.length == merged.authors.length))
            .toList();

        return [merged, ...others];
      }
    }

    return valid;
  }

  /// Heuristically merges multiple search results into one "Best of" result.
  @visibleForTesting
  static BookSearchResult? mergeResults(
    List<BookSearchResult> results, {
    required String query,
    required bool isIsbn,
    String? preferredLanguage,
  }) {
    if (results.isEmpty) return null;

    // 1. Statistics & Merging Collections
    final titles = <String>[];
    final authors = <String>{};
    final publishers = <String, int>{};
    final years = <int, int>{};
    final pages = <int, int>{};
    final languages = <String, int>{};
    final categories = <String>{};
    final descriptions = <String>[];
    final covers = <String>[];

    String? bestIsbn = isIsbn ? query.replaceAll(RegExp(r'[^0-9X]'), '') : null;

    for (final res in results) {
      titles.add(res.title);
      if (res.authors.isNotEmpty && res.authors.first != 'Unknown Author') {
        authors.addAll(res.authors);
      }
      if (res.publisher != null) {
        publishers[res.publisher!] = (publishers[res.publisher!] ?? 0) + 1;
      }
      if (res.publishYear != null) {
        years[res.publishYear!] = (years[res.publishYear!] ?? 0) + 1;
      }
      if (res.pageCount != null) {
        pages[res.pageCount!] = (pages[res.pageCount!] ?? 0) + 1;
      }
      if (res.language != null) {
        languages[res.language!] = (languages[res.language!] ?? 0) + 1;
      }
      categories.addAll(res.categories);
      if (res.description != null) descriptions.add(res.description!);
      if (res.coverUrl != null) covers.add(res.coverUrl!);

      if (bestIsbn == null && res.isbn != null) {
        bestIsbn = res.isbn;
      } else if (bestIsbn != null &&
          res.isbn != null &&
          res.isbn!.length > bestIsbn.length) {
        // Prefer ISBN-13 over ISBN-10
        bestIsbn = res.isbn;
      }
    }

    // 2. Selection logic
    // Title: Pick the longest one (tends to include subtitles/full names)
    String bestTitle = titles.fold(
      '',
      (prev, curr) => curr.length > prev.length ? curr : prev,
    );
    if (bestTitle.isEmpty && results.isNotEmpty) {
      bestTitle = results.first.title;
    }

    // Frequent fields: Pick the most frequent non-null value
    T? mostFrequent<T>(Map<T, int> freqMap) {
      if (freqMap.isEmpty) return null;
      return freqMap.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final bestPublisher = mostFrequent(publishers);
    final bestYear = mostFrequent(years);
    final bestPageCount = mostFrequent(pages);
    final bestLanguage = mostFrequent(languages);

    // Description: Pick the longest one (more informative)
    final bestDesc = descriptions.fold<String?>(
      null,
      (prev, curr) => (prev == null || curr.length > prev.length) ? curr : prev,
    );

    // Cover: Pick the first valid cover (could be improved with resolution checks)
    final bestCover = covers.firstOrNull;

    return BookSearchResult(
      title: bestTitle,
      authors: authors.toList(),
      isbn: bestIsbn,
      publisher: bestPublisher,
      coverUrl: bestCover,
      pageCount: bestPageCount,
      publishYear: bestYear,
      description: bestDesc,
      language: bestLanguage,
      categories: categories.toList(),
      source: BookSearchResult.recommendedSource,
    );
  }
}
