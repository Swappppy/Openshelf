import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_search_result.dart';
import '../models/app_settings.dart';
import '../controllers/app_settings_controller.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';

// -------------------------------------------------------
// Búsqueda de Libros (Resultados completos)
// -------------------------------------------------------

class SearchResponse {
  final List<BookSearchResult> results;
  /// Null si se usó el proveedor principal. Nombre del fallback si se usó éste.
  final String? usedFallback;

  const SearchResponse({required this.results, this.usedFallback});
}

class BookSearchService {
  final BookSearchServer server;
  final String? googleBooksApiKey;

  const BookSearchService(this.server, {this.googleBooksApiKey});

  Future<SearchResponse> search(String query, {int limit = 20}) async {
    try {
      final results = await _searchWith(server, query, limit: limit);
      // Si el principal devuelve resultados, los usamos
      if (results.isNotEmpty) {
        return SearchResponse(results: results);
      }
      // Sin resultados: intentar fallback silencioso
      final fallback = _fallbackFor(server);
      final fallbackResults = await _searchWith(fallback, query, limit: limit);
      if (fallbackResults.isNotEmpty) {
        return SearchResponse(
          results: fallbackResults,
          usedFallback: _label(fallback),
        );
      }
      // Ninguno encontró nada
      return const SearchResponse(results: []);
    } on Exception {
      // El principal falló: intentar fallback
      final fallback = _fallbackFor(server);
      try {
        final fallbackResults = await _searchWith(fallback, query, limit: limit);
        return SearchResponse(
          results: fallbackResults,
          usedFallback: _label(fallback),
        );
      } on Exception {
        // Ambos fallaron: relanzar el error original
        rethrow;
      }
    }
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
    };
  }

  static BookSearchServer _fallbackFor(BookSearchServer s) =>
      s == BookSearchServer.openLibrary
          ? BookSearchServer.googleBooks
          : BookSearchServer.openLibrary;

  static String _label(BookSearchServer s) =>
      s == BookSearchServer.openLibrary ? 'Open Library' : 'Google Books';
}

final bookSearchServiceProvider = Provider<BookSearchService>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.maybeWhen(
    data: (s) => BookSearchService(
      s.searchServer,
      googleBooksApiKey: s.googleBooksApiKey,
    ),
    orElse: () => const BookSearchService(BookSearchServer.openLibrary),
  );
});

// -------------------------------------------------------
// Búsqueda de Portadas (Candidatos de imagen)
// -------------------------------------------------------

class CoverCandidate {
  final String url;
  final String source; // 'Open Library' | 'Google Books'

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

  // -------------------------------------------------------
  // Open Library
  // -------------------------------------------------------
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

  // -------------------------------------------------------
  // Google Books
  // -------------------------------------------------------
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
}
