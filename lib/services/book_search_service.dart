import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/app_settings.dart';
import '../models/book_search_query.dart';
import '../models/book_search_result.dart';
import '../services/database.dart';
import 'google_books_service.dart';
import 'open_library_service.dart';
import 'inventaire_service.dart';

export '../models/book_search_query.dart';
export 'cover_search_service.dart';

/// Orchestrates multi-provider book searches and merges results intelligently.
class BookSearchService {
  /// FASE A: Deterministic eligibility gatekeeper.
  /// Hard boolean rules (no points, no score blending).
  /// Returns false if candidate fails hard title, author, ISBN, or publisher guards.
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

    // 4. Publisher Guard / Pruning
    if (query.publisher != null && query.publisher!.trim().isNotEmpty) {
      if (!matchesPublisher(candidate.publisher, query.publisher!)) {
        return false;
      }
    }

    return true;
  }

  /// Checks if candidate publisher matches target publisher query.
  static bool matchesPublisher(String? candidatePublisher, String targetPublisher) {
    final cleanTarget = targetPublisher.trim().toLowerCase();
    if (cleanTarget.isEmpty) return true;
    if (candidatePublisher == null || candidatePublisher.trim().isEmpty) {
      return false; // Unknown or missing publisher fails match when target publisher is explicitly specified
    }
    final cleanCand = candidatePublisher.trim().toLowerCase();

    if (cleanCand.contains(cleanTarget) || cleanTarget.contains(cleanCand)) {
      return true;
    }

    final targetWords = cleanTarget.split(RegExp(r'[^\w]')).where((w) => w.length > 2).toList();
    if (targetWords.isEmpty) return true;

    for (final word in targetWords) {
      if (cleanCand.contains(word)) return true;
    }

    return false;
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

  /// Streams progressive search results as each server completes its query.
  static Stream<List<BookSearchResult>> searchAllStructuredStream(
    BookSearchQuery query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) async* {
    if (query.isEmpty) return;

    final List<BookSearchResult> accumulatedRaw = [];
    final controller = StreamController<List<BookSearchResult>>();
    int remaining = servers.length;

    if (remaining == 0) {
      yield [];
      return;
    }

    for (final server in servers) {
      _performServerSearch(server, query, googleApiKey, preferredLanguage).then((serverResults) {
        accumulatedRaw.addAll(serverResults);
        final processed = _processCandidates(accumulatedRaw, query, preferredLanguage);
        if (!controller.isClosed) {
          controller.add(processed);
        }
      }).catchError((e) {
        debugPrint('BookSearchService Stream: Error from ${server.name}: $e');
      }).whenComplete(() {
        remaining--;
        if (remaining == 0 && !controller.isClosed) {
          controller.close();
        }
      });
    }

    yield* controller.stream;
  }

  /// Helper to process accumulated raw results into scored, deduplicated, and merged results.
  static List<BookSearchResult> _processCandidates(
    List<BookSearchResult> rawResults,
    BookSearchQuery query,
    String? preferredLanguage,
  ) {
    if (rawResults.isEmpty) return [];

    // Attach search ISBN if candidate missing it
    final enrichedRaw = rawResults.map((res) {
      if (query.hasIsbn && (res.isbn == null || res.isbn!.isEmpty)) {
        return res.copyWith(isbn: query.isbn!);
      }
      return res;
    }).toList();

    // 1. FASE A: Hard eligibility & publisher pruning filter
    final eligible = enrichedRaw.where((r) => isEligible(r, query)).toList();
    if (eligible.isEmpty) return [];

    // 2. FASE B: Score eligible candidates
    final scored = eligible.map((r) {
      final score = calculateRankScore(r, query, preferredLanguage: preferredLanguage);
      return MapEntry(r, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    // 3. DEDUPLICATION EN UNA SOLA PASADA (Single-pass grouping by arePeers)
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

    // 4. Synthesis. Fields are merged only across records of the SAME edition
    //    (same ISBN), where each provider fills gaps of the others. Peers that
    //    are different editions of the same work (title + author match) are
    //    not blended into a fictitious record: the best-ranked one represents
    //    the group and the others only contribute their providers' work keys
    //    and the largest edition count, so the editions view can query them.
    final finalResults = <BookSearchResult>[];
    for (final group in groups) {
      // `scored` was already sorted by rank, and groups keep that order.
      final representative = group.first;
      if (group.length == 1) {
        finalResults.add(representative);
        continue;
      }

      final repIsbn = _cleanIsbn(representative.isbn);
      final sameEdition = repIsbn.isEmpty
          ? <BookSearchResult>[representative]
          : group.where((r) => _cleanIsbn(r.isbn) == repIsbn).toList();

      final base = sameEdition.length > 1
          ? (mergeResults(
                sameEdition,
                query: query.hasIsbn ? query.isbn! : (query.rawQuery ?? query.title ?? ''),
                isIsbn: query.hasIsbn,
                preferredLanguage: preferredLanguage,
              ) ??
              representative)
          : representative;

      finalResults.add(_withProviderKeys(base, group));
    }

    return finalResults;
  }

  static String _cleanIsbn(String? isbn) => isbn?.replaceAll(RegExp(r'[^0-9X]'), '') ?? '';

  /// Keeps [base]'s data and adds the work keys and largest edition count
  /// found anywhere in [group].
  static BookSearchResult _withProviderKeys(BookSearchResult base, List<BookSearchResult> group) {
    int? maxEditionCount = base.editionCount;
    for (final r in group) {
      final c = r.editionCount;
      if (c != null && (maxEditionCount == null || c > maxEditionCount)) maxEditionCount = c;
    }
    return base.copyWith(
      openLibraryWorkKey: base.openLibraryWorkKey ?? group.map((r) => r.openLibraryWorkKey).nonNulls.firstOrNull,
      inventaireWorkUri: base.inventaireWorkUri ?? group.map((r) => r.inventaireWorkUri).nonNulls.firstOrNull,
      editionCount: maxEditionCount,
    );
  }

  /// Queries specified providers using a structured query object (blocking until all done).
  static Future<List<BookSearchResult>> searchAllStructured(
    BookSearchQuery query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
    String? preferredLanguage,
  }) async {
    final stream = searchAllStructuredStream(
      query,
      servers: servers,
      googleApiKey: googleApiKey,
      preferredLanguage: preferredLanguage,
    );

    List<BookSearchResult> lastResults = [];
    await for (final results in stream) {
      lastResults = results;
    }
    return lastResults;
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
        return await OpenLibraryService.searchStructured(
          query,
          preferredLanguage: preferredLanguage,
        );
      case BookSearchServer.inventaire:
        return await InventaireService.searchStructured(query, preferredLanguage: preferredLanguage);
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

    // The original title is taken only from a provider that states it.
    // A different title in the group is usually just a variant of the same
    // one (e.g. a series suffix), so it is never guessed from that.
    final originalTitle = results.map((r) => r.originalTitle).nonNulls.firstOrNull;

    T? mostFrequent<T>(Map<T, int> freqMap) {
      if (freqMap.isEmpty) return null;
      return freqMap.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final bestPublisher = mostFrequent(publishers);
    final bestYear = mostFrequent(years);
    final bestPageCount = mostFrequent(pages);
    // Prefer the user's language only if one of the merged editions is in it
    // (the title is chosen the same way); never assign it blindly.
    final prefLanguageMatch = prefLang == null
        ? null
        : languages.keys.firstWhereOrNull((l) => l.toLowerCase().startsWith(prefLang));
    final bestLanguage = prefLanguageMatch ?? mostFrequent(languages);

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
