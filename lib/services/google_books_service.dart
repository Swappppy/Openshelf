import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';
import 'book_search_service.dart';

/// Integration for the Google Books API.
class GoogleBooksService {
  static const _host = 'www.googleapis.com';
  static const _path = '/books/v1/volumes';
  static const _timeout = Duration(seconds: 10);

  /// Searches for books using structured query parameters.
  static Future<List<BookSearchResult>> searchStructured(
    BookSearchQuery query, {
    String? apiKey,
    String? preferredLanguage,
    http.Client? client,
  }) async {
    if (query.hasIsbn) {
      final res = await getByIsbn(
        query.isbn!,
        apiKey: apiKey,
        preferredLanguage: preferredLanguage,
        client: client,
      );
      if (res != null) return [res];
    }

    final rawQ = query.rawQuery ??
        [query.title, query.author, query.publisher]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(' ');

    return search(
      rawQ,
      apiKey: apiKey,
      preferredLanguage: preferredLanguage,
      title: query.title,
      author: query.author,
      publisher: query.publisher,
      client: client,
    );
  }

  /// Searches for books using progressive fallback strategies with retry logic for API instability.
  static Future<List<BookSearchResult>> search(
    String query, {
    String? apiKey,
    String? preferredLanguage,
    String? title,
    String? author,
    String? publisher,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();

    final cleanTitle = title?.trim();
    final cleanAuthor = author?.trim();
    final cleanPublisher = publisher?.trim();

    // Strategy 1: Quoted field operators (intitle:"...", inauthor:"...", inpublisher:"...")
    if ((cleanTitle != null && cleanTitle.isNotEmpty) ||
        (cleanAuthor != null && cleanAuthor.isNotEmpty) ||
        (cleanPublisher != null && cleanPublisher.isNotEmpty)) {
      final parts = <String>[];
      if (cleanTitle != null && cleanTitle.isNotEmpty) parts.add('intitle:"${_cleanTerm(cleanTitle)}"');
      if (cleanAuthor != null && cleanAuthor.isNotEmpty) parts.add('inauthor:"${_cleanTerm(cleanAuthor)}"');
      if (cleanPublisher != null && cleanPublisher.isNotEmpty) parts.add('inpublisher:"${_cleanTerm(cleanPublisher)}"');

      final results = await _executeApiQuery(parts.join(' '), apiKey: apiKey, client: httpClient);
      if (results.isNotEmpty) return results;
    }

    // Strategy 2: Omit publisher (since inpublisher: in Google Books API often yields 0 results)
    if (cleanPublisher != null && cleanPublisher.isNotEmpty && ((cleanTitle != null && cleanTitle.isNotEmpty) || (cleanAuthor != null && cleanAuthor.isNotEmpty))) {
      final parts = <String>[];
      if (cleanTitle != null && cleanTitle.isNotEmpty) parts.add('intitle:"${_cleanTerm(cleanTitle)}"');
      if (cleanAuthor != null && cleanAuthor.isNotEmpty) parts.add('inauthor:"${_cleanTerm(cleanAuthor)}"');

      final results = await _executeApiQuery(parts.join(' '), apiKey: apiKey, client: httpClient);
      if (results.isNotEmpty) return results;
    }

    // Strategy 3: Unquoted field operators (e.g. intitle:Title inauthor:Author)
    if ((cleanTitle != null && cleanTitle.isNotEmpty) || (cleanAuthor != null && cleanAuthor.isNotEmpty)) {
      final parts = <String>[];
      if (cleanTitle != null && cleanTitle.isNotEmpty) parts.add('intitle:${_cleanTerm(cleanTitle)}');
      if (cleanAuthor != null && cleanAuthor.isNotEmpty) parts.add('inauthor:${_cleanTerm(cleanAuthor)}');

      final results = await _executeApiQuery(parts.join(' '), apiKey: apiKey, client: httpClient);
      if (results.isNotEmpty) return results;
    }

    // Strategy 4: Plain keyword query (e.g. q="Title Author Publisher")
    final terms = [cleanTitle, cleanAuthor, cleanPublisher]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    final plainQ = terms.isNotEmpty ? terms : _cleanTerm(query);

    if (plainQ.isNotEmpty) {
      final results = await _executeApiQuery(plainQ, apiKey: apiKey, client: httpClient);
      if (results.isNotEmpty) return results;
    }

    // Strategy 5: Plain keyword query without publisher (q="Title Author")
    if (cleanPublisher != null && cleanPublisher.isNotEmpty) {
      final titleAuthorTerms = [cleanTitle, cleanAuthor]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      if (titleAuthorTerms.isNotEmpty) {
        final results = await _executeApiQuery(titleAuthorTerms, apiKey: apiKey, client: httpClient);
        if (results.isNotEmpty) return results;
      }
    }

    return [];
  }

  /// Fetches all available editions/volumes in Google Books for a given work or search result.
  static Future<List<BookSearchResult>> getEditionsByWork(
    BookSearchResult workResult, {
    String? apiKey,
    String? preferredLanguage,
    http.Client? client,
  }) async {
    final cleanTitle = _cleanTerm(workResult.title);
    final cleanAuthor = workResult.authors.isNotEmpty && workResult.authors.first != 'Unknown Author'
        ? _cleanTerm(workResult.authors.first)
        : '';

    final queryParts = [
      if (cleanTitle.isNotEmpty) cleanTitle,
      if (cleanAuthor.isNotEmpty) cleanAuthor,
    ];

    if (queryParts.isEmpty) return [];

    final httpClient = client ?? http.Client();

    final results = await _executeApiQuery(
      queryParts.join(' '),
      apiKey: apiKey,
      client: httpClient,
    );

    // Filter results so ONLY volumes matching title and author are included
    final searchQuery = BookSearchQuery(
      title: workResult.title,
      author: workResult.authors.isNotEmpty ? workResult.authors.first : null,
    );
    final eligible = results.where((res) => BookSearchService.isEligible(res, searchQuery)).toList();

    final filteredResults = eligible.isNotEmpty ? eligible : results;

    // Sort editions: Preferred language match first, then cover presence, then publication year desc
    final sorted = List<BookSearchResult>.from(filteredResults);
    if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
      final prefLang = preferredLanguage.toLowerCase().substring(0, 2);
      sorted.sort((a, b) {
        final aLang = a.language?.toLowerCase().substring(0, 2);
        final bLang = b.language?.toLowerCase().substring(0, 2);
        final aMatch = (aLang == prefLang) ? 0 : (aLang != null ? 2 : 1);
        final bMatch = (bLang == prefLang) ? 0 : (bLang != null ? 2 : 1);
        if (aMatch != bMatch) return aMatch.compareTo(bMatch);

        final aCover = a.coverUrl != null ? 0 : 1;
        final bCover = b.coverUrl != null ? 0 : 1;
        if (aCover != bCover) return aCover.compareTo(bCover);

        return (b.publishYear ?? 0).compareTo(a.publishYear ?? 0);
      });
    }

    return sorted;
  }

  /// Helper to execute GET requests with automatic retries on 503 / 500 / 429 transient API errors.
  static Future<http.Response?> _getWithRetry(
    Uri uri, {
    required http.Client client,
    int maxRetries = 2,
  }) async {
    for (var i = 0; i <= maxRetries; i++) {
      try {
        final response = await client.get(uri).timeout(_timeout);
        if (response.statusCode == 200) {
          return response;
        }
        if (response.statusCode == 503 || response.statusCode == 500 || response.statusCode == 429) {
          debugPrint('Google Books API HTTP ${response.statusCode} (Attempt ${i + 1}/${maxRetries + 1}) for $uri');
          if (i < maxRetries) {
            await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
            continue;
          }
        }
        return response;
      } catch (e) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
      }
    }
    return null;
  }

  /// Internal helper to construct Uri and execute Google Books HTTP search.
  static Future<List<BookSearchResult>> _executeApiQuery(
    String q, {
    String? apiKey,
    required http.Client client,
  }) async {
    if (q.trim().isEmpty) return [];

    try {
      final queryParams = <String, String>{
        'q': q,
        'maxResults': '40',
      };

      if (apiKey != null && apiKey.isNotEmpty) {
        queryParams['key'] = apiKey;
      }

      final uri = Uri.https(_host, _path, queryParams);
      debugPrint('Google Books: Searching $uri');

      final response = await _getWithRetry(uri, client: client);
      if (response == null) return [];

      debugPrint('Google Books: HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items == null || items.isEmpty) {
          debugPrint('Google Books: No items found for "$q"');
          return [];
        }

        return items.map((item) => _parseItem(item)).toList();
      } else {
        debugPrint('Google Books Error: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Google Books Search Error: $e');
    }
    return [];
  }

  /// Looks up a book by its ISBN-13 or ISBN-10.
  static Future<BookSearchResult?> getByIsbn(
    String isbn, {
    String? apiKey,
    String? preferredLanguage,
    http.Client? client,
  }) async {
    try {
      final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
      if (cleanIsbn.isEmpty) return null;

      final queryParams = <String, String>{
        'q': 'isbn:$cleanIsbn',
      };

      if (apiKey != null && apiKey.isNotEmpty) {
        queryParams['key'] = apiKey;
      }

      final uri = Uri.https(_host, _path, queryParams);
      debugPrint('Google Books: ISBN Lookup $uri');

      final httpClient = client ?? http.Client();
      final response = await _getWithRetry(uri, client: httpClient);
      if (response == null) return null;

      debugPrint('Google Books: HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return _parseItem(items.first);
        }
        debugPrint('Google Books: ISBN not found');
      } else {
        debugPrint('Google Books Error: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Google Books ISBN Error: $e');
    }
    return null;
  }

  static String _cleanTerm(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static BookSearchResult _parseItem(dynamic item) {
    final info = item['volumeInfo'] as Map<String, dynamic>? ?? {};

    // Prioritize ISBN-13 over ISBN-10
    final idents = info['industryIdentifiers'] as List?;
    String? isbn;
    if (idents != null) {
      final i13 = idents.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null);
      final i10 = idents.firstWhere((id) => id['type'] == 'ISBN_10', orElse: () => null);
      isbn = (i13 ?? i10 ?? (idents.isNotEmpty ? idents.first : null))?['identifier']?.toString();
    }

    // Cover image prioritization and HTTPS upgrade
    final cover = _parseCoverUrl(info['imageLinks']);

    // Language code (ISO 639-1)
    String? language = info['language']?.toString();
    if (language != null && language.length > 2) {
      language = language.substring(0, 2);
    }

    return BookSearchResult(
      title: info['title']?.toString() ?? 'Unknown Title',
      subtitle: info['subtitle']?.toString(),
      authors: (info['authors'] as List?)?.map((a) => a.toString()).toList() ?? ['Unknown Author'],
      isbn: isbn,
      language: language,
      publisher: info['publisher']?.toString(),
      coverUrl: cover,
      pageCount: info['pageCount'] is int ? info['pageCount'] as int : int.tryParse(info['pageCount']?.toString() ?? ''),
      publishYear: _parseYear(info['publishedDate']?.toString()),
      description: info['description']?.toString(),
      categories: (info['categories'] as List?)?.map((c) => c.toString()).toList() ?? [],
      source: 'Google Books',
    );
  }

  static String? _parseCoverUrl(dynamic imageLinks) {
    if (imageLinks == null || imageLinks is! Map) return null;
    final map = imageLinks as Map<String, dynamic>;

    String? url = map['extraLarge'] as String? ??
        map['large'] as String? ??
        map['medium'] as String? ??
        map['small'] as String? ??
        map['thumbnail'] as String? ??
        map['smallThumbnail'] as String?;

    if (url == null || url.trim().isEmpty) return null;

    if (url.startsWith('http:')) {
      url = url.replaceFirst('http:', 'https:');
    }

    // Clean curl effect parameter from Google Books covers for a flatter image
    url = url.replaceAll('&edge=curl', '').replaceAll('edge=curl&', '');

    return url;
  }

  static int? _parseYear(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    final match = RegExp(r'\b(18|19|20)\d{2}\b').firstMatch(dateStr);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }
}
