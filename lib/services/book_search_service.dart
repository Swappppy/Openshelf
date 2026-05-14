import 'package:flutter/foundation.dart';
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
  static Future<List<CoverCandidate>> search({
    String? isbn,
    String? title,
    String? author,
    String? publisher,
    String? apiKey,
    List<BookSearchServer> servers = const [
      BookSearchServer.googleBooks,
      BookSearchServer.openLibrary,
      BookSearchServer.inventaire,
    ],
  }) async {
    final List<CoverCandidate> candidates = [];
    final seenUrls = <String>{};

    void addCandidate(String url, String source) {
      if (!seenUrls.contains(url)) {
        candidates.add(CoverCandidate(url: url, source: source));
        seenUrls.add(url);
      }
    }
    
    // 1. ISBN Search (High confidence)
    if (isbn != null) {
      final isbnTasks = servers.map((server) async {
        try {
          switch (server) {
            case BookSearchServer.googleBooks:
              final res = await GoogleBooksService.getByIsbn(isbn, apiKey: apiKey);
              if (res?.coverUrl != null) {
                debugPrint('CoverSearch: Found ISBN cover from Google: ${res!.coverUrl}');
                addCandidate(res.coverUrl!, 'Google Books');
              }
              break;
            case BookSearchServer.openLibrary:
              final res = await OpenLibraryService.getByIsbn(isbn);
              if (res?.coverUrl != null) {
                debugPrint('CoverSearch: Found ISBN cover from OL: ${res!.coverUrl}');
                addCandidate(res.coverUrl!, 'Open Library');
              }
              break;
            case BookSearchServer.inventaire:
              final res = await InventaireService.getByIsbn(isbn);
              if (res?.coverUrl != null) {
                debugPrint('CoverSearch: Found ISBN cover from Inventaire: ${res!.coverUrl}');
                addCandidate(res.coverUrl!, 'Inventaire');
              }
              break;
          }
        } catch (e) {
          debugPrint('CoverSearch: ISBN Error from ${server.name}: $e');
        }
      });
      await Future.wait(isbnTasks);
    }
    
    // 2. Title Search (Fallback or supplementary)
    // We always perform title search if we have few results, or if the user wants more.
    if (title != null && candidates.length < 10) {
      final query = '$title ${author ?? ''}'.trim();
      final titleTasks = servers.map((server) async {
        try {
          List<BookSearchResult> results = [];
          switch (server) {
            case BookSearchServer.googleBooks:
              results = await GoogleBooksService.search(query, apiKey: apiKey);
              break;
            case BookSearchServer.openLibrary:
              results = await OpenLibraryService.search(query);
              break;
            case BookSearchServer.inventaire:
              results = await InventaireService.search(query);
              break;
          }
          debugPrint('CoverSearch: ${server.name} found ${results.length} results by title');
          for (final res in results) {
            if (res.coverUrl != null) {
              debugPrint('CoverSearch: Adding cover from ${server.name}: ${res.coverUrl}');
              addCandidate(res.coverUrl!, server.name);
            }
          }
        } catch (e) {
          debugPrint('CoverSearch: Title Error from ${server.name}: $e');
        }
      });
      await Future.wait(titleTasks);
    }
    
    return candidates;
  }
}

/// Orchestrates multi-provider book searches and merges results intelligently.
class BookSearchService {
  /// Queries specified providers in parallel for a general search.
  static Future<List<BookSearchResult>> searchAll(
    String query, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
  }) async {
    final cleanIsbn = query.replaceAll(RegExp(r'[^0-9X]'), '');
    final isIsbn = (cleanIsbn.length == 10 || cleanIsbn.length == 13) && RegExp(r'^[0-9]+X?$').hasMatch(cleanIsbn);

    final tasks = servers.map((server) async {
      List<BookSearchResult> results = [];
      try {
        if (isIsbn) {
          // If it's an ISBN, try specific lookup first as it's higher confidence
          BookSearchResult? isbnRes;
          switch (server) {
            case BookSearchServer.googleBooks:
              isbnRes = await GoogleBooksService.getByIsbn(cleanIsbn, apiKey: googleApiKey);
              break;
            case BookSearchServer.openLibrary:
              isbnRes = await OpenLibraryService.getByIsbn(cleanIsbn);
              break;
            case BookSearchServer.inventaire:
              isbnRes = await InventaireService.getByIsbn(cleanIsbn);
              break;
          }
          if (isbnRes != null) {
            results.add(isbnRes);
            // If we found an exact ISBN match, we don't need to do a general search on this provider
            // to avoid duplicates like "Work" vs "Edition" for the same book.
            debugPrint('BookSearchService: Found exact ISBN match for ${server.name}');
          } else {
            // Only try general search if ISBN lookup failed
            results.addAll(await _performGeneralSearch(server, query, googleApiKey));
          }
        } else {
          // Normal search for non-ISBN queries
          results.addAll(await _performGeneralSearch(server, query, googleApiKey));
        }

        debugPrint('BookSearchService: ${server.name} returned ${results.length} results');
      } catch (e) {
        debugPrint('BookSearchService: Error from ${server.name}: $e');
      }
      return results;
    });

    final allResults = await Future.wait(tasks);
    final flattened = allResults.expand((e) => e).toList();
    debugPrint('BookSearchService: Total flattened results: ${flattened.length}');

    // Create a "Recommended" summary if we have high-confidence matches.
    if (flattened.isNotEmpty) {
      final merged = _mergeResults(flattened);
      if (merged != null) {
        debugPrint('BookSearchService: Prepending merged recommended result');
        // If it's an ISBN search, the recommended result is often identical to the provider result
        // Check for duplicates before prepending
        if (!flattened.any((r) => r.isbn == merged.isbn && r.title == merged.title)) {
          return [merged, ...flattened];
        }
      }
    }

    return flattened;
  }

  static Future<List<BookSearchResult>> _performGeneralSearch(
    BookSearchServer server,
    String query,
    String? googleApiKey,
  ) async {
    switch (server) {
      case BookSearchServer.googleBooks:
        return await GoogleBooksService.search(query, apiKey: googleApiKey);
      case BookSearchServer.openLibrary:
        return await OpenLibraryService.search(query);
      case BookSearchServer.inventaire:
        return await InventaireService.search(query);
    }
  }

  /// Queries specified providers in parallel using an ISBN.
  static Future<List<BookSearchResult>> searchByIsbn(
    String isbn, {
    required List<BookSearchServer> servers,
    String? googleApiKey,
  }) async {
    final tasks = servers.map((server) async {
      try {
        switch (server) {
          case BookSearchServer.googleBooks:
            return await GoogleBooksService.getByIsbn(isbn, apiKey: googleApiKey);
          case BookSearchServer.openLibrary:
            return await OpenLibraryService.getByIsbn(isbn);
          case BookSearchServer.inventaire:
            return await InventaireService.getByIsbn(isbn);
        }
      } catch (e) {
        debugPrint('BookSearchService: ISBN Error from ${server.name}: $e');
        return null;
      }
    });

    final allResults = await Future.wait(tasks);
    final valid = allResults.whereType<BookSearchResult>().toList();

    if (valid.isNotEmpty) {
      final merged = _mergeResults(valid);
      if (merged != null) {
        // Only return the best merged result for specific ISBN lookups.
        return [merged];
      }
    }

    return valid;
  }

  /// Heuristically merges multiple search results into one "Best of" result.
  /// It prioritizes the longest title, most resolved authors, and highest resolution cover.
  static BookSearchResult? _mergeResults(List<BookSearchResult> results) {
    if (results.isEmpty) return null;
    if (results.length == 1) return results.first;

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
