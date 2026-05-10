import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

class OpenLibraryService {
  static const _baseUrl = 'https://openlibrary.org';
  static const _timeout = Duration(seconds: 10);

  /// Busca libros por texto libre (título, autor, ISBN).
  /// Devuelve hasta [limit] resultados.
  static Future<List<BookSearchResult>> search(
      String query, {
        int limit = 20,
      }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search.json').replace(
      queryParameters: {
        'q': query.trim(),
        'limit': '$limit',
        'fields':
        'key,title,author_name,isbn,publisher,first_publish_year,'
            'number_of_pages_median,cover_i',
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Open Library responded with ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = body['docs'] as List<dynamic>? ?? [];

    return docs
        .cast<Map<String, dynamic>>()
        .map(BookSearchResult.fromOpenLibraryDoc)
        .where((r) => r.title.isNotEmpty)
        .toList();
  }
}