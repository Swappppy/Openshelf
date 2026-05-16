import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

/// Integration for the Google Books API.
class GoogleBooksService {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Searches for books using a general query with field-specific restrictions.
  static Future<List<BookSearchResult>> search(
    String query, {
    String? apiKey,
    String? preferredLanguage,
    String? title,
    String? author,
    String? publisher,
  }) async {
    try {
      // Build a more precise query using Google's field identifiers
      final List<String> parts = [];
      if (title != null && title.isNotEmpty) {
        parts.add('intitle:"$title"');
      } else {
        parts.add(Uri.encodeComponent(query));
      }
      
      if (author != null && author.isNotEmpty) parts.add('inauthor:"$author"');
      if (publisher != null && publisher.isNotEmpty) parts.add('inpublisher:"$publisher"');

      final q = parts.join('+');
      var url = '$_baseUrl?q=$q&maxResults=40';
      
      if (apiKey != null && apiKey.isNotEmpty) {
        url += '&key=$apiKey';
      }
      if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
        final lang = preferredLanguage.length > 2 ? preferredLanguage.substring(0, 2) : preferredLanguage;
        url += '&langRestrict=$lang';
      }
      
      debugPrint('Google Books: Searching $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      debugPrint('Google Books: HTTP ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items == null) {
          debugPrint('Google Books: No items found in response');
          return [];
        }

        return items.map((item) => _parseItem(item)).toList();
      } else {
        debugPrint('Google Books Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Google Books Search Error: $e');
    }
    return [];
  }

  /// Looks up a book by its ISBN-13 or ISBN-10.
  static Future<BookSearchResult?> getByIsbn(String isbn, {String? apiKey, String? preferredLanguage}) async {
    try {
      var url = '$_baseUrl?q=isbn:${Uri.encodeComponent(isbn)}';
      if (apiKey != null && apiKey.isNotEmpty) {
        url += '&key=$apiKey';
      }
      
      debugPrint('Google Books: ISBN Lookup $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      debugPrint('Google Books: HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return _parseItem(items.first);
        }
        debugPrint('Google Books: ISBN not found');
      }
    } catch (e) {
      debugPrint('Google Books ISBN Error: $e');
    }
    return null;
  }

  static BookSearchResult _parseItem(dynamic item) {
    final info = item['volumeInfo'];
    final idents = info['industryIdentifiers'] as List?;
    String? isbn;
    if (idents != null) {
      final i13 = idents.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null);
      isbn = i13 != null ? i13['identifier'] : idents.first['identifier'];
    }

    // Attempt to get higher resolution covers if available.
    final images = info['imageLinks'];
    String? cover = images?['thumbnail'];
    if (cover != null && cover.startsWith('http:')) {
      cover = cover.replaceFirst('http:', 'https:');
    }

    return BookSearchResult(
      title: info['title'] ?? 'Unknown Title',
      subtitle: info['subtitle'],
      authors: (info['authors'] as List?)?.cast<String>() ?? ['Unknown Author'],
      isbn: isbn,
      language: info['language'],
      publisher: info['publisher'],
      coverUrl: cover,
      pageCount: info['pageCount'],
      publishYear: _parseYear(info['publishedDate']),
      description: info['description'],
      categories: (info['categories'] as List?)?.cast<String>() ?? [],
      source: 'Google Books',
    );
  }

  static int? _parseYear(String? date) {
    if (date == null || date.isEmpty) return null;
    final year = int.tryParse(date.substring(0, 4));
    return year;
  }
}
