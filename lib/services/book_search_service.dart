import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/app_settings.dart';
import '../models/book_search_query.dart';
import '../models/book_search_result.dart';
import '../services/database.dart';
import 'google_books_service.dart';
import 'open_library_service.dart';
import 'inventaire_service.dart';
import 'annas_archive_service.dart';

export '../models/book_search_query.dart';
export 'cover_search_service.dart';

/// Orchestrates multi-provider book searches and merges results intelligently.
class BookSearchService {
  /// FASE A: Deterministic eligibility gatekeeper.
  /// Hard boolean rules (no points, no score blending).
  /// Returns false if candidate fails hard title, author, or ISBN guards.
  static bool isEligible(BookSearchResult candidate, BookSearchQuery query) {
    // 1. ISBN Guard
    if (query.hasIsbn) {
      final targetIsbn = query.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      if (candidate.isbn != null) {
        final candIsbn = candidate.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
        if (candIsbn.isNotEmpty && candIsbn == targetIsbn) {
          return true; // Exact ISBN match passes unconditionally
        }
        if (candIsbn.isNotEmpty && candIsbn != targetIsbn) {
          return false; // Mismatched ISBN -> reject
        }
      }
    }

    // 2. Title Guard
    if (query.hasTitle && query.title!.trim().isNotEmpty) {
      if (!_matchTitle(candidate.title, query.title!, candidate.subtitle)) {
        return false;
      }
    }

    // 3. Author Guard
    if (query.hasAuthor && query.author!.trim().isNotEmpty) {
      if (!_matchAuthor(candidate.authors, query.author!)) {
        return false;
      }
    }

    return true;
  }

  static bool _matchTitle(String candTitle, String targetTitle, String? subtitle) {
    final normCand = _normalize(candTitle);
    final normTarget = _normalize(targetTitle);

    if (normCand == normTarget) return true;
    if (normCand.contains(normTarget) || normTarget.contains(normCand)) return true;

    // Subtitle check
    if (subtitle != null && subtitle.isNotEmpty) {
      final normSub = _normalize(subtitle);
      if (normSub.contains(normTarget) || normTarget.contains(normSub)) return true;
    }

    // Keyword overlap check
    final keywords = normTarget.split(' ').where((w) => w.length > 2).toList();
    if (keywords.isEmpty) return true;

    int matched = 0;
    for (final kw in keywords) {
      if (normCand.contains(kw)) matched++;
    }

    return (matched / keywords.length) >= 0.5;
  }

  static bool _matchAuthor(List<String> candAuthors, String targetAuthor) {
    final normTargetWords = _normalize(targetAuthor)
        .split(' ')
        .where((w) => w.length > 2)
        .toList();

    if (normTargetWords.isEmpty) return true;

    final normCand = candAuthors.map((a) => _normalize(a)).join(' ');
    if (normCand.isEmpty || normCand == 'unknown author') return true; // Allow candidates with missing author

    int matched = 0;
    for (final word in normTargetWords) {
      if (normCand.contains(word)) matched++;
    }

    return (matched / normTargetWords.length) >= 0.5;
  }

  /// FASE B: Ranking and ordering score for candidates that passed Phase A.
  static double calculateRankScore(
    BookSearchResult candidate,
    BookSearchQuery query, {
    String? preferredLanguage,
  }) {
    double score = 1000.0; // Base score for eligible candidates

    // 1. Exact ISBN Match Bonus
    if (query.hasIsbn && candidate.isbn != null) {
      final targetIsbn = query.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      final candIsbn = candidate.isbn!.replaceAll(RegExp(r'[^0-9X]'), '');
      if (targetIsbn == candIsbn && targetIsbn.isNotEmpty) {
        score += 4000.0;
      }
    }

    // 2. Edition Count / Work Popularity Boost
    if (candidate.editionCount != null && candidate.editionCount! > 1) {
      final count = candidate.editionCount!.clamp(1, 100);
      score += count * 20.0; // Canonical works with many editions get up to +2000 points
    }

    // 3. Preferred Language Boost
    if (preferredLanguage != null && preferredLanguage.isNotEmpty && candidate.language != null) {
      final pref = preferredLanguage.toLowerCase().substring(0, 2);
      final candLang = candidate.language!.toLowerCase().substring(0, 2);
      if (candLang == pref) {
        score += 500.0;
      }
    }

    // 4. Exact Title Equality Bonus
    if (query.hasTitle) {
      if (_normalize(candidate.title) == _normalize(query.title!)) {
        score += 500.0;
      }
    }

    // 5. Data Richness Tie-Breakers
    if (candidate.coverUrl != null && candidate.coverUrl!.isNotEmpty) score += 200.0;
    if (candidate.description != null && candidate.description!.length > 50) score += 100.0;
    if (candidate.publisher != null && candidate.publisher!.isNotEmpty) score += 50.0;
    if (candidate.publishYear != null) score += 50.0;
    if (candidate.pageCount != null) score += 50.0;

    // 6. Self-publishing / Vanity publisher penalty
    if (_isSelfPublished(candidate.publisher)) {
      score -= 500.0;
    }

    return score;
  }

  static bool _isSelfPublished(String? publisher) {
    if (publisher == null) return false;
    final norm = publisher.toLowerCase();
    return norm.contains('independently published') ||
        norm.contains('createspace') ||
        norm.contains('kdp') ||
        norm.contains('lulu') ||
        norm.contains('authorhouse');
  }

  /// Queries specified providers using a structured query object.
  static Future<List<BookSearchResult>> searchAllStructured(
    BookSearchQuery query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) async {
    if (query.isEmpty) return [];

    final List<BookSearchResult> rawResults = [];

    // 1. Fetch raw candidates from all selected servers
    for (final server in servers) {
      try {
        debugPrint('BookSearchService: Querying ${server.name}...');
        final serverResults = await _performServerSearch(
            server, query, googleApiKey, preferredLanguage);
        rawResults.addAll(serverResults);
      } catch (e) {
        debugPrint('BookSearchService: Error from ${server.name}: $e');
      }
    }

    if (rawResults.isEmpty) return [];

    // Attach search ISBN if candidate missing it
    final enrichedRaw = rawResults.map((res) {
      if (query.hasIsbn && (res.isbn == null || res.isbn!.isEmpty)) {
        return res.copyWith(isbn: query.isbn!);
      }
      return res;
    }).toList();

    // 2. FASE A: Hard eligibility filter
    final eligible = enrichedRaw.where((r) => isEligible(r, query)).toList();
    if (eligible.isEmpty) return [];

    // 3. FASE B: Score eligible candidates
    final scored = eligible.map((r) {
      final score = calculateRankScore(r, query, preferredLanguage: preferredLanguage);
      return MapEntry(r, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    // 4. DEDUPLICATION EN UNA SOLA PASADA (Single-pass grouping by arePeers)
    final groups = <List<BookSearchResult>>[];
    for (final item in scored.map((e) => e.key)) {
      bool added = false;
      for (final group in groups) {
        if (arePeers(group.first, item)) {
          group.add(item);
          added = true;
          break;
        }
      }
      if (!added) {
        groups.add([item]);
      }
    }

    // 5. Synthesis: Merge each peer group into a synthesized winner.
    // For each peer group, sort candidates by rank score so the canonical/original work is primary.
    final finalResults = <BookSearchResult>[];
    for (final group in groups) {
      group.sort((a, b) => calculateRankScore(b, query, preferredLanguage: preferredLanguage)
          .compareTo(calculateRankScore(a, query, preferredLanguage: preferredLanguage)));

      if (group.length == 1) {
        finalResults.add(group.first);
      } else {
        final merged = mergeResults(
          group,
          query: query.rawQuery ?? query.title ?? '',
          isIsbn: query.hasIsbn,
          preferredLanguage: preferredLanguage,
        );
        if (merged != null) {
          finalResults.add(merged);
        } else {
          finalResults.add(group.first);
        }
      }
    }

    return finalResults;
  }

  /// Queries specified providers using a simple query string.
  static Future<List<BookSearchResult>> searchAll(
    String query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) {
    return searchAllStructured(
      BookSearchQuery.fromRawQuery(query),
      servers: servers,
      googleApiKey: googleApiKey,
      preferredLanguage: preferredLanguage,
    );
  }

  /// Calculates a relevance score for a result relative to the query string.
  @visibleForTesting
  static double calculateScore(
      BookSearchResult res, String query, bool queryIsIsbn) {
    final searchQuery = queryIsIsbn
        ? BookSearchQuery(isbn: query, rawQuery: query)
        : BookSearchQuery.fromRawQuery(query);

    if (!isEligible(res, searchQuery)) {
      return 0.0;
    }
    return calculateRankScore(res, searchQuery);
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
      if (a.authors.isEmpty || b.authors.isEmpty) return true;
      final authA = a.authors.map((e) => _normalize(e)).join(' ');
      final authB = b.authors.map((e) => _normalize(e)).join(' ');

      final wordsA = authA.split(' ').where((w) => w.length > 3).toSet();
      final wordsB = authB.split(' ').where((w) => w.length > 3).toSet();

      if (wordsA.intersection(wordsB).isNotEmpty) return true;
    }

    return false;
  }

  static String _normalize(String s) {
    var norm = s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
      .replaceAll('ü', 'u').replaceAll('ñ', 'n');
    return norm.replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static Future<List<BookSearchResult>> _performServerSearch(
    BookSearchServer server,
    BookSearchQuery query,
    String? googleApiKey,
    String? preferredLanguage,
  ) async {
    switch (server) {
      case BookSearchServer.googleBooks:
        return await GoogleBooksService.searchStructured(
          query,
          apiKey: googleApiKey,
          preferredLanguage: preferredLanguage,
        );
      case BookSearchServer.openLibrary:
        return await OpenLibraryService.searchStructured(query);
      case BookSearchServer.inventaire:
        return await InventaireService.searchStructured(query, preferredLanguage: preferredLanguage);
      case BookSearchServer.annasArchive:
        return await AnnasArchiveService.searchStructured(query);
    }
  }

  /// Queries specified providers sequentially using an ISBN.
  static Future<List<BookSearchResult>> searchByIsbn(
    String isbn, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) {
    return searchAllStructured(
      BookSearchQuery(isbn: isbn),
      servers: servers,
      googleApiKey: googleApiKey,
      preferredLanguage: preferredLanguage,
    );
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

    final titles = <String>[];
    final authors = <String>{};
    final publishers = <String, int>{};
    final years = <int, int>{};
    final pages = <int, int>{};
    final languages = <String, int>{};
    final categories = <String>{};
    final descriptions = <String>[];
    final covers = <String>[];
    final translators = <String>[];

    String? bestIsbn = isIsbn ? query.replaceAll(RegExp(r'[^0-9X]'), '') : null;
    int? maxEditionCount;
    String? openLibraryWorkKey;
    String? inventaireWorkUri;
    BookFormat? bestFormat;

    final prefLang = preferredLanguage?.toLowerCase().substring(0, 2);

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
      if (res.translator != null && res.translator!.isNotEmpty) {
        translators.add(res.translator!);
      }
      if (res.editionCount != null) {
        if (maxEditionCount == null || res.editionCount! > maxEditionCount) {
          maxEditionCount = res.editionCount;
        }
      }
      if (res.openLibraryWorkKey != null) {
        openLibraryWorkKey ??= res.openLibraryWorkKey;
      }
      if (res.inventaireWorkUri != null) {
        inventaireWorkUri ??= res.inventaireWorkUri;
      }
      if (res.format != null) {
        bestFormat ??= res.format;
      }

      categories.addAll(res.categories);
      if (res.description != null) descriptions.add(res.description!);

      // Cover prioritization: put cover from preferredLanguage edition at the beginning
      if (res.coverUrl != null && res.coverUrl!.isNotEmpty) {
        if (prefLang != null && res.language?.toLowerCase().startsWith(prefLang) == true) {
          covers.insert(0, res.coverUrl!);
        } else {
          covers.add(res.coverUrl!);
        }
      }

      if (bestIsbn == null && res.isbn != null) {
        bestIsbn = res.isbn;
      } else if (bestIsbn != null &&
          res.isbn != null &&
          res.isbn!.length > bestIsbn.length) {
        bestIsbn = res.isbn;
      }
    }

    // Title selection: Prefer title from result matching preferredLanguage if present
    String bestTitle = '';
    if (prefLang != null) {
      final matchInPrefLang = results.firstWhereOrNull(
        (r) => r.language?.toLowerCase().startsWith(prefLang) == true && r.title.isNotEmpty,
      );
      if (matchInPrefLang != null) {
        bestTitle = matchInPrefLang.title;
      }
    }

    if (bestTitle.isEmpty) {
      bestTitle = titles.fold<String>(
        '',
        (prev, curr) => curr.length > prev.length ? curr : prev,
      );
    }

    if (bestTitle.isEmpty && results.isNotEmpty) {
      bestTitle = results.first.title;
    }

    // Original title: if there's an original work title different from bestTitle, record it
    String? originalTitle;
    final otherTitle = titles.firstWhereOrNull((t) => t != bestTitle && _normalize(t) != _normalize(bestTitle));
    if (otherTitle != null) {
      originalTitle = otherTitle;
    }

    T? mostFrequent<T>(Map<T, int> freqMap) {
      if (freqMap.isEmpty) return null;
      return freqMap.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final bestPublisher = mostFrequent(publishers);
    final bestYear = mostFrequent(years);
    final bestPageCount = mostFrequent(pages);
    final bestLanguage = prefLang ?? mostFrequent(languages);

    final bestDesc = descriptions.fold<String?>(
      null,
      (prev, curr) => (prev == null || curr.length > prev.length) ? curr : prev,
    );

    final bestCover = covers.firstOrNull;
    final bestTranslator = translators.firstOrNull;

    return BookSearchResult(
      title: bestTitle,
      subtitle: results.firstWhereOrNull((r) => r.subtitle != null)?.subtitle,
      originalTitle: originalTitle,
      authors: authors.toList(),
      isbn: bestIsbn,
      language: bestLanguage,
      translator: bestTranslator,
      publisher: bestPublisher,
      coverUrl: bestCover,
      pageCount: bestPageCount,
      publishYear: bestYear,
      description: bestDesc,
      categories: categories.toList(),
      source: results.first.source,
      openLibraryWorkKey: openLibraryWorkKey,
      inventaireWorkUri: inventaireWorkUri,
      editionCount: maxEditionCount,
      format: bestFormat,
    );
  }
}
