import 'package:annas_archive_client/annas_archive_client.dart';
import 'package:flutter/foundation.dart';
import '../models/book_search_result.dart';

/// Integration for Anna's Archive search.
class AnnasArchiveService {
  static final _client = AnnasArchive();

  /// Searches for books using Anna's Archive.
  static Future<List<BookSearchResult>> search(String query) async {
    try {
      debugPrint('Anna\'s Archive: Searching for "$query"');
      final books = await _client.searchBooks(query);

      return books.map((book) {
        // Anna's Archive v0.1.0 authors is a single string, often comma-separated.
        final authors = book.authors
            .split(RegExp(r'[,;]'))
            .map((e) {
              var name = e.trim();
              // Remove bracketed roles like (Translator), (Editor)
              name = name.replaceFirst(RegExp(r'\s*\(.*?\)$'), '');
              return name;
            })
            .where((e) => e.isNotEmpty)
            .toList();

        return BookSearchResult(
          title: book.title,
          authors: authors.isEmpty ? ['Unknown Author'] : authors,
          publisher: book.publisher,
          publishYear: null, // Year is not available in search results for v0.1.0
          language: _normalizeLanguage(book.language),
          source: 'Anna\'s Archive',
          coverUrl: book.coverUrl,
          description: book.description ?? 'Hash: ${book.hash}',
        );
      }).toList();
    } catch (e) {
      debugPrint('Anna\'s Archive Search Error: $e');
      return [];
    }
  }

  static String? _normalizeLanguage(String? lang) {
    if (lang == null || lang.isEmpty) return null;
    final l = lang.toLowerCase();
    if (l.contains('spanish') || l.contains('español')) return 'es';
    if (l.contains('english') || l.contains('inglés')) return 'en';
    if (l.contains('french') || l.contains('francés')) return 'fr';
    if (l.contains('german') || l.contains('alemán')) return 'de';
    if (l.contains('italian') || l.contains('italiano')) return 'it';
    if (l.contains('portuguese') || l.contains('portugués')) return 'pt';
    return lang;
  }

  /// Anna's Archive doesn't have a direct ISBN lookup in the client's simple API,
  /// but we can search by ISBN.
  static Future<BookSearchResult?> getByIsbn(String isbn) async {
    final results = await search(isbn);
    if (results.isNotEmpty) {
      // Filter results to ensure it's a good match if possible, 
      // but Anna's Archive search by ISBN is usually very accurate.
      return results.first;
    }
    return null;
  }
}
