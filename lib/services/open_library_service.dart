import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

/// Integration for the Open Library Search API.
class OpenLibraryService {
  static const _host = 'openlibrary.org';
  static const _searchPath = '/search.json';
  static const _headers = {
    'User-Agent': 'Openshelf/1.0.0 (https://github.com/ftena/openshelf)',
    'Accept': 'application/json',
  };

  /// Searches for books using a general query. 
  /// Open Library provides broad data and community-maintained covers.
  static Future<List<BookSearchResult>> search(String query) async {
    try {
      final uri = Uri.https(_host, _searchPath, {
        'q': query,
        'limit': '40',
      });
      
      debugPrint('Open Library: Searching $uri');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List?;
        if (docs == null) return [];

        return docs.map((doc) => _parseDoc(doc)).toList();
      } else {
        debugPrint('Open Library Search Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Open Library Search Error: $e');
    }
    return [];
  }

  /// Looks up a book by its ISBN.
  static Future<BookSearchResult?> getByIsbn(String isbn) async {
    try {
      final uri = Uri.https(_host, _searchPath, {
        'isbn': isbn,
      });
      
      debugPrint('Open Library: ISBN Lookup $uri');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List?;
        if (docs != null && docs.isNotEmpty) {
          return _parseDoc(docs.first);
        }
      } else {
        debugPrint('Open Library ISBN Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Open Library ISBN Error: $e');
    }
    return null;
  }

  static BookSearchResult _parseDoc(dynamic doc) {
    final coverId = doc['cover_i'];
    final coverUrl = coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg' : null;

    return BookSearchResult(
      title: doc['title'] ?? 'Unknown Title',
      subtitle: doc['subtitle'],
      authors: (doc['author_name'] as List?)?.cast<String>() ?? ['Unknown Author'],
      isbn: (doc['isbn'] as List?)?.first,
      language: (doc['language'] as List?)?.first,
      publisher: (doc['publisher'] as List?)?.first,
      coverUrl: coverUrl,
      publishYear: doc['first_publish_year'],
      categories: (doc['subject'] as List?)?.take(5).cast<String>().toList() ?? [],
      source: 'Open Library',
    );
  }
}
