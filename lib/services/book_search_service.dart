import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_search_result.dart';
import '../models/app_settings.dart';
import '../controllers/app_settings_controller.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';

class SearchResponse {
  final List<BookSearchResult> results;
  /// Null si se usó el proveedor principal. Nombre del fallback si se usó éste.
  final String? usedFallback;

  const SearchResponse({required this.results, this.usedFallback});
}

class BookSearchService {
  final BookSearchServer server;
  const BookSearchService(this.server);

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
    } on Exception catch (e) {
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

  static Future<List<BookSearchResult>> _searchWith(
      BookSearchServer s,
      String query, {
        required int limit,
      }) {
    return switch (s) {
      BookSearchServer.openLibrary =>
          OpenLibraryService.search(query, limit: limit),
      BookSearchServer.googleBooks =>
          GoogleBooksService.search(query, limit: limit),
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
  final server = settings.maybeWhen(
    data: (s) => s.searchServer,
    orElse: () => BookSearchServer.openLibrary,
  );
  return BookSearchService(server);
});