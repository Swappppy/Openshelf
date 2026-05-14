import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';
import 'book_search_service.dart';

/// Integration for Inventaire.io, which provides high-quality Spanish and European metadata.
class InventaireService {
  static const _baseUrl = 'https://inventaire.io/api';
  static const _timeout = Duration(seconds: 10);
  
  // User agent required by Inventaire API guidelines
  static const _headers = {
    'User-Agent': 'Openshelf/1.0 (https://github.com/ftena/openshelf; contact@example.com)',
    'Accept': 'application/json',
  };

  /// Searches for books using the Inventaire search API.
  static Future<List<BookSearchResult>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    // Check if query is an ISBN
    final isbn = query.replaceAll(RegExp(r'[-\s]'), '');
    if (RegExp(r'^\d{10}(\d{3})?$').hasMatch(isbn)) {
      final result = await getByIsbn(isbn);
      return result != null ? [result] : [];
    }

    // General search by title/author
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query.trim(),
          'types': 'works',
          'limit': '$limit',
        },
      );

      debugPrint('Inventaire: Searching $uri');
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('Inventaire Search Error: HTTP ${response.statusCode}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final label = item['label'] as String? ?? 'Unknown Title';
        
        // Try to get author from claims/entities first
        List<String> authors = [];
        final claims = item['claims'] as Map<String, dynamic>?;
        final entities = item['entities'] as Map<String, dynamic>?;
        if (claims != null && entities != null) {
          final authorIds = (claims['P50'] ?? claims['wdt:P50']) as List<dynamic>?;
          if (authorIds != null && authorIds.isNotEmpty) {
            for (final id in authorIds) {
              final authorEntity = entities[id];
              if (authorEntity != null) {
                final aLabel = authorEntity['label'] as String?;
                if (aLabel != null) authors.add(aLabel);
              }
            }
          }
        }

        // Fallback to description cleanup for authors
        if (authors.isEmpty) {
          var desc = item['description'] as String? ?? '';
          if (desc.isNotEmpty) {
            desc = desc.replaceFirst(RegExp(r'^(book|novel|work|essay|story|biography|collection|play|poem|edited) by ', caseSensitive: false), '');
            authors.add(desc);
          }
        }
        
        if (authors.isEmpty) authors.add('Unknown Author');
        
        // Resolve Image
        String? coverUrl = _resolveImageUrl(item['image']);
        if (coverUrl == null && claims != null) {
          final p18 = claims['P18'] ?? claims['wdt:P18'];
          if (p18 is List && p18.isNotEmpty) {
            coverUrl = _resolveImageUrl(p18.first);
          }
        }
        
        return BookSearchResult(
          title: label,
          authors: authors,
          isbn: null,
          publisher: null,
          publishYear: null,
          pageCount: null,
          coverUrl: coverUrl,
          source: 'Inventaire',
        );
      }).toList();
    } catch (e) {
      debugPrint('Inventaire Search Error: $e');
      return [];
    }
  }

  /// Looks up a book by its ISBN via the entities endpoint.
  static Future<BookSearchResult?> getByIsbn(String isbn) async {
    try {
      final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
      final uri = Uri.parse('$_baseUrl/entities').replace(
        queryParameters: {
          'action': 'by-uris',
          'uris': 'isbn:$cleanIsbn',
          'relatives': 'wdt:P50|wdt:P123', // hydrates authors and publisher
        },
      );

      debugPrint('Inventaire: ISBN Lookup $uri');
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('Inventaire ISBN Error: HTTP ${response.statusCode} - ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final entities = body['entities'] as Map<String, dynamic>?;
      if (entities == null || entities.isEmpty) return null;

      // The main entity is usually the one that has the requested URI in its info
      final mainEntity = entities.values.firstWhere(
        (e) => e['type'] == 'edition',
        orElse: () => entities.values.firstWhere(
          (e) => e['type'] == 'work',
          orElse: () => entities.values.first,
        ),
      );

      return _fromEntity(entities, mainEntity, cleanIsbn);
    } catch (e) {
      debugPrint('Inventaire ISBN Error: $e');
      return null;
    }
  }

  static BookSearchResult _fromEntity(Map<String, dynamic> allEntities, Map<String, dynamic> entity, String? isbn) {
    final claims = entity['claims'] as Map<String, dynamic>? ?? {};
    
    // 1. Get Title (neutral selection)
    final labels = entity['labels'] as Map<String, dynamic>? ?? {};
    final title = labels.values.isNotEmpty ? labels.values.first : 'Unknown Title';

    // 2. Get Author(s)
    List<String> authors = [];
    final authorIds = claims['P50'] ?? claims['wdt:P50'];
    if (authorIds is List && authorIds.isNotEmpty) {
      for (final id in authorIds) {
        final authorEntity = allEntities[id];
        if (authorEntity != null) {
          final aLabels = authorEntity['labels'] as Map<String, dynamic>? ?? {};
          final name = aLabels.values.isNotEmpty ? aLabels.values.first : null;
          if (name != null) authors.add(name);
        }
      }
    } else {
      final nameStrings = claims['P2093'] ?? claims['wdt:P2093'];
      if (nameStrings is List && nameStrings.isNotEmpty) {
        authors.add(nameStrings.first.toString());
      }
    }
    
    if (authors.isEmpty) authors.add('Unknown Author');

    // 3. Get Publisher
    String? publisher;
    final publisherIds = claims['P123'] ?? claims['wdt:P123'];
    if (publisherIds is List && publisherIds.isNotEmpty) {
      final pubEntity = allEntities[publisherIds.first];
      if (pubEntity != null) {
        final pLabels = pubEntity['labels'] as Map<String, dynamic>? ?? {};
        publisher = pLabels.values.isNotEmpty ? pLabels.values.first : null;
      }
    }

    // 4. Get Image
    String? coverUrl = _resolveImageUrl(entity['image']);
    if (coverUrl == null) {
      final p18 = claims['P18'] ?? claims['wdt:P18'];
      if (p18 is List && p18.isNotEmpty) {
        coverUrl = _resolveImageUrl(p18.first);
      }
    }

    // 5. Get Year
    int? publishYear;
    final dateClaims = claims['P577'] ?? claims['wdt:P577'];
    if (dateClaims is List && dateClaims.isNotEmpty) {
      final dateStr = _extractValue(dateClaims.first);
      if (dateStr != null && dateStr.length >= 4) {
        publishYear = int.tryParse(dateStr.substring(0, 4));
      }
    }
    
    return BookSearchResult(
      title: title,
      authors: authors,
      isbn: isbn,
      publisher: publisher,
      publishYear: publishYear,
      pageCount: null, // P1104 is pages, but often missing
      coverUrl: coverUrl,
      source: 'Inventaire',
    );
  }

  static String? _resolveImageUrl(dynamic imageVal) {
    if (imageVal == null) return null;
    
    if (imageVal is Map) {
      final url = imageVal['url'] as String?;
      if (url != null && url.startsWith('http')) return url;
      if (url != null) return 'https://inventaire.io$url';
      
      final value = imageVal['value'] as String?;
      if (value != null) return _resolveImageUrl(value);
    }
    
    final imgStr = imageVal.toString();
    if (imgStr.isEmpty || imgStr == 'null') return null;
    if (imgStr.startsWith('http')) return imgStr;
    
    // Hash image from Inventaire
    return 'https://inventaire.io/img/entities/$imgStr';
  }

  static String? _extractValue(dynamic claim) {
    if (claim is String) return claim;
    if (claim is Map) return claim['value']?.toString();
    return claim?.toString();
  }

  static Future<List<CoverCandidate>> searchCovers(String query) async {
    final results = await search(query, limit: 10);
    return results
        .where((r) => r.coverUrl != null)
        .map((r) => CoverCandidate(url: r.coverUrl!, source: 'Inventaire'))
        .toList();
  }
}
