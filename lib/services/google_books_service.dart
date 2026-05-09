import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

class GoogleBooksService {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const _timeout = Duration(seconds: 10);

  static Future<List<BookSearchResult>> search(
      String query, {
        int limit = 20,
      }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': query.trim(),
        'maxResults': '$limit',
        'printType': 'books',
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 429) {
      throw Exception('rate_limit');
    }
    if (response.statusCode != 200) {
      throw Exception('Google Books respondió con ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];

    return items
        .cast<Map<String, dynamic>>()
        .map(_fromItem)
        .where((r) => r.title.isNotEmpty)
        .toList();
  }

  static BookSearchResult _fromItem(Map<String, dynamic> item) {
    final info = item['volumeInfo'] as Map<String, dynamic>? ?? {};

    final authors = info['authors'];
    final identifiers = info['industryIdentifiers'] as List<dynamic>? ?? [];
    final imageLinks = info['imageLinks'] as Map<String, dynamic>?;

    // Preferimos ISBN-13, si no ISBN-10
    String? isbn;
    for (final id in identifiers.cast<Map<String, dynamic>>()) {
      if (id['type'] == 'ISBN_13') {
        isbn = id['identifier'] as String?;
        break;
      }
    }
    isbn ??= identifiers.cast<Map<String, dynamic>>()
        .where((id) => id['type'] == 'ISBN_10')
        .map((id) => id['identifier'] as String?)
        .firstOrNull;

    // Año de publicación — Google devuelve "2004" o "2004-01-01"
    final dateStr = info['publishedDate'] as String?;
    final publishYear = dateStr != null && dateStr.length >= 4
        ? int.tryParse(dateStr.substring(0, 4))
        : null;

    // Portada: thumbnail de Google, con https forzado
    String? coverUrl = imageLinks?['thumbnail'] as String?;
    if (coverUrl != null) {
      coverUrl = coverUrl.replaceFirst('http://', 'https://');
      // Subir calidad: zoom=1 da 128px, zoom=0 da la más grande disponible
      coverUrl = coverUrl.replaceAll('&zoom=1', '&zoom=0');
    }

    return BookSearchResult(
      title: info['title'] as String? ?? '',
      author: (authors is List && authors.isNotEmpty)
          ? authors.first as String
          : '',
      isbn: isbn,
      publisher: info['publisher'] as String?,
      publishYear: publishYear,
      totalPages: info['pageCount'] as int?,
      coverUrl: coverUrl,
      openLibraryKey: null,
    );
  }
}