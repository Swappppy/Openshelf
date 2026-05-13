import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_search_result.dart';
import '../models/app_settings.dart';
import '../controllers/app_settings_controller.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';
import 'inventaire_service.dart';

// -------------------------------------------------------
// Búsqueda de Libros (Resultados completos)
// -------------------------------------------------------

class SearchResponse {
  final List<BookSearchResult> results;
  /// Lista de proveedores que contribuyeron resultados, en orden de aparición.
  final List<String> providers;

  const SearchResponse({required this.results, required this.providers});
}

class BookSearchService {
  final List<BookSearchServer> servers;
  final String? googleBooksApiKey;

  const BookSearchService(this.servers, {this.googleBooksApiKey});

  Future<SearchResponse> search(String query, {int limit = 20}) async {
    final allProviderResults = <BookSearchServer, List<BookSearchResult>>{};
    final contributors = <String>[];

    // 1. Fetch all results from all active servers
    await Future.wait(servers.map((server) async {
      try {
        final results = await _searchWith(server, query, limit: limit);
        if (results.isNotEmpty) {
          allProviderResults[server] = results;
          contributors.add(_label(server));
        }
      } catch (e) {
        debugPrint('Search error with ${_label(server)}: $e');
      }
    }));

    if (allProviderResults.isEmpty) {
      return const SearchResponse(results: [], providers: []);
    }

    // 2. Create the "Recommended by Openshelf" result
    final recommended = _createRecommended(allProviderResults);

    // 3. Flatten and deduplicate remaining results
    final finalResults = <BookSearchResult>[];
    if (recommended != null) {
      finalResults.add(recommended);
    }

    final seenKeys = <String>{};
    if (recommended != null) {
      seenKeys.add(_getDedupeKey(recommended));
    }

    // Add remaining results in user-preferred order
    for (final server in servers) {
      final results = allProviderResults[server];
      if (results == null) continue;

      for (final r in results) {
        final key = _getDedupeKey(r);
        if (!seenKeys.contains(key)) {
          finalResults.add(r);
          seenKeys.add(key);
        }
      }
    }

    return SearchResponse(
      results: finalResults,
      providers: contributors,
    );
  }

  BookSearchResult? _createRecommended(Map<BookSearchServer, List<BookSearchResult>> allResults) {
    // Strategy: Take the first result of each provider and merge them if they seem to be the same book
    // For now, let's just pick the "best" one if we only have one provider, 
    // or merge the top ones if they share an ISBN or very similar title.
    
    final candidates = allResults.values.where((list) => list.isNotEmpty).map((list) => list.first).toList();
    if (candidates.isEmpty) return null;

    // Group candidates that look like the same book (by ISBN primarily)
    final grouped = <String, List<BookSearchResult>>{};
    for (final c in candidates) {
      final key = c.isbn ?? c.title.toLowerCase().trim();
      grouped.putIfAbsent(key, () => []).add(c);
    }

    // Pick the largest group (most consensus)
    final bestGroup = grouped.values.reduce((a, b) => a.length >= b.length ? a : b);
    
    // Merge the best group
    return _mergeResults(bestGroup);
  }

  BookSearchResult _mergeResults(List<BookSearchResult> group) {
    if (group.length == 1) {
      final r = group.first;
      return BookSearchResult(
        title: r.title,
        author: r.author,
        isbn: r.isbn,
        publisher: r.publisher,
        publishYear: r.publishYear,
        totalPages: r.totalPages,
        coverUrl: r.coverUrl,
        openLibraryKey: r.openLibraryKey,
        source: 'Openshelf Recommended',
      );
    }

    // Aggregation logic
    String title = '';
    String author = '';
    String? isbn;
    String? publisher;
    int? year;
    int? pages;
    String? cover;
    String? olKey;

    for (final r in group) {
      // Preference: Longest title usually most descriptive
      if (r.title.length > title.length) title = r.title;
      // Preference: Non-empty author
      if (author.isEmpty || (r.author.isNotEmpty && author == 'Unknown Author')) author = r.author;
      
      isbn ??= r.isbn;
      publisher ??= r.publisher;
      year ??= r.publishYear;
      pages ??= r.totalPages;
      cover ??= r.coverUrl;
      olKey ??= r.openLibraryKey;
    }

    return BookSearchResult(
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      publishYear: year,
      totalPages: pages,
      coverUrl: cover,
      openLibraryKey: olKey,
      source: 'Openshelf Recommended',
    );
  }

  String _getDedupeKey(BookSearchResult r) {
    return r.isbn ?? r.openLibraryKey ?? '${r.title.toLowerCase()}_${r.author.toLowerCase()}';
  }

  Future<List<BookSearchResult>> _searchWith(
    BookSearchServer s,
    String query, {
    required int limit,
  }) {
    return switch (s) {
      BookSearchServer.openLibrary =>
        OpenLibraryService.search(query, limit: limit),
      BookSearchServer.googleBooks =>
        GoogleBooksService.search(query, limit: limit, apiKey: googleBooksApiKey),
      BookSearchServer.inventaire =>
        InventaireService.search(query, limit: limit),
    };
  }

  static String _label(BookSearchServer s) => switch (s) {
    BookSearchServer.openLibrary => 'Open Library',
    BookSearchServer.googleBooks => 'Google Books',
    BookSearchServer.inventaire => 'Inventaire.io',
  };
}

final bookSearchServiceProvider = Provider<BookSearchService>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.maybeWhen(
    data: (s) => BookSearchService(
      s.searchServers,
      googleBooksApiKey: s.googleBooksApiKey,
    ),
    orElse: () => const BookSearchService([
      BookSearchServer.openLibrary,
      BookSearchServer.googleBooks,
      BookSearchServer.inventaire,
    ]),
  );
});

// -------------------------------------------------------
// Búsqueda de Portadas (Candidatos de imagen)
// -------------------------------------------------------

class CoverCandidate {
  final String url;
  final String source;

  const CoverCandidate({required this.url, required this.source});
}

class CoverSearchService {
  static const _timeout = Duration(seconds: 10);

  /// Busca portadas para un libro. Busca por ISBN y por Texto (Título/Autor)
  /// para maximizar resultados, y elimina duplicados.
  static Future<List<CoverCandidate>> search({
    String? isbn,
    String? title,
    String? author,
    String? publisher,
    String? apiKey,
  }) async {
    final tasks = <Future<List<CoverCandidate>>>[];

    // 1. Búsqueda por ISBN (si existe)
    if (isbn != null && isbn.isNotEmpty) {
      tasks.add(_fromOpenLibrary(query: 'isbn:$isbn'));
      if (apiKey != null && apiKey.isNotEmpty) {
        tasks.add(_fromGoogleBooks(query: isbn, apiKey: apiKey));
      }
      tasks.add(InventaireService.searchCovers(isbn));
    }

    // 2. Búsqueda por Texto (Título + Autor)
    final textQuery = [
      if (title != null && title.isNotEmpty) title,
      if (author != null && author.isNotEmpty) author,
    ].join(' ').trim();

    if (textQuery.isNotEmpty) {
      tasks.add(_fromOpenLibrary(query: textQuery));
      if (apiKey != null && apiKey.isNotEmpty) {
        tasks.add(_fromGoogleBooks(query: textQuery, apiKey: apiKey));
      }
      tasks.add(InventaireService.searchCovers(textQuery));
    }

    final allResults = await Future.wait(tasks);

    // De-duplicación por URL y preservación de orden (intercalado original)
    final candidates = <CoverCandidate>[];
    final seenUrls = <String>{};

    // Usamos el intercalado para mantener variedad de fuentes si es posible
    final interleaved = _interleave(allResults);

    for (final c in interleaved) {
      if (!seenUrls.contains(c.url)) {
        candidates.add(c);
        seenUrls.add(c.url);
      }
    }

    return candidates;
  }

  /// Intercala listas para mezclar fuentes en lugar de agruparlas.
  static List<CoverCandidate> _interleave(List<List<CoverCandidate>> lists) {
    final result = <CoverCandidate>[];
    final maxLen = lists.fold(0, (m, l) => l.length > m ? l.length : m);
    for (var i = 0; i < maxLen; i++) {
      for (final list in lists) {
        if (i < list.length) result.add(list[i]);
      }
    }
    return result;
  }

  static Future<List<CoverCandidate>> _fromOpenLibrary({
    required String query,
  }) async {
    final candidates = <CoverCandidate>[];

    try {
      final uri = Uri.parse('https://openlibrary.org/search.json').replace(
        queryParameters: {
          'q': query,
          'limit': '15',
          'fields': 'cover_i,isbn,cover_edition_key',
        },
      );

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = (body['docs'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

        for (final doc in docs) {
          // cover_i directo
          final coverId = doc['cover_i'];
          if (coverId != null) {
            candidates.add(CoverCandidate(
              url: 'https://covers.openlibrary.org/b/id/$coverId-L.jpg',
              source: 'Open Library',
            ));
          }
          // ISBNs del doc
          final isbns = doc['isbn'];
          if (isbns is List) {
            for (final altIsbn in isbns.cast<String>().take(4)) {
              candidates.add(CoverCandidate(
                url: 'https://covers.openlibrary.org/b/isbn/$altIsbn-L.jpg?default=false',
                source: 'Open Library',
              ));
            }
          }
          // OLID
          final editionKey = doc['cover_edition_key'] as String?;
          if (editionKey != null) {
            candidates.add(CoverCandidate(
              url: 'https://covers.openlibrary.org/b/olid/$editionKey-L.jpg?default=false',
              source: 'Open Library',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('OL cover search error: $e');
    }

    return candidates;
  }

  static Future<List<CoverCandidate>> _fromGoogleBooks({
    required String query,
    required String apiKey,
  }) async {
    try {
      final uri =
      Uri.parse('https://www.googleapis.com/books/v1/volumes').replace(
        queryParameters: {
          'q': query,
          'maxResults': '10',
          'printType': 'books',
          'key': apiKey,
        },
      );

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (body['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final candidates = <CoverCandidate>[];
      for (final item in items) {
        final info =
            item['volumeInfo'] as Map<String, dynamic>? ?? {};
        final links =
        info['imageLinks'] as Map<String, dynamic>?;
        if (links == null) continue;

        for (final key in ['extraLarge', 'large', 'medium', 'thumbnail']) {
          final raw = links[key] as String?;
          if (raw != null) {
            final url = raw
                .replaceFirst('http://', 'https://')
                .replaceAll('&zoom=1', '&zoom=0');
            candidates.add(
                CoverCandidate(url: url, source: 'Google Books'));
            break;
          }
        }
      }
      return candidates;
    } catch (_) {
      return [];
    }
  }
}
