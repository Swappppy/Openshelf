import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';
import 'book_search_service.dart';

class InventaireService {
  static const _baseUrl = 'https://inventaire.io/api';
  static const _timeout = Duration(seconds: 10);
  
  // User agent required by Inventaire API guidelines
  static const _headers = {
    'User-Agent': 'Openshelf/1.0 (https://github.com/ftena/openshelf; contact@example.com)',
  };

  static Future<List<BookSearchResult>> search(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    // Check if query is an ISBN
    final isbn = query.replaceAll(RegExp(r'[-\s]'), '');
    if (RegExp(r'^\d{10}(\d{3})?$').hasMatch(isbn)) {
      final result = await _searchByIsbn(isbn);
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

      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final label = item['label'] as String? ?? '';
        
        // Try to get author from claims/entities first
        String author = '';
        final claims = item['claims'] as Map<String, dynamic>?;
        final entities = item['entities'] as Map<String, dynamic>?;
        if (claims != null && entities != null) {
          final authorIds = (claims['P50'] ?? claims['wdt:P50']) as List<dynamic>?;
          if (authorIds != null && authorIds.isNotEmpty) {
            final names = <String>[];
            for (final id in authorIds) {
              final authorEntity = entities[id];
              if (authorEntity != null) {
                final aLabel = authorEntity['label'] as String?;
                if (aLabel != null) names.add(aLabel);
              }
            }
            if (names.isNotEmpty) author = names.join(', ');
          }
        }

        // Fallback to description cleanup
        if (author.isEmpty) {
          author = item['description'] as String? ?? '';
          author = author.replaceFirst(RegExp(r'^(book|novel|work|essay|story|biography|collection|play|poem|edited) by ', caseSensitive: false), '');
        }
        
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
          author: author,
          isbn: null,
          publisher: null,
          publishYear: null,
          totalPages: null,
          coverUrl: coverUrl,
          source: 'Inventaire.io',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<BookSearchResult?> _searchByIsbn(String isbn) async {
    try {
      final uri = Uri.parse('$_baseUrl/entities').replace(
        queryParameters: {
          'action': 'by-uris',
          'uris': 'isbn:$isbn',
          'relatives': 'wdt:P50|wdt:P123', // hydrates authors and publisher
        },
      );

      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) return null;

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

      return _fromEntity(entities, mainEntity, isbn);
    } catch (_) {
      return null;
    }
  }

  static BookSearchResult _fromEntity(Map<String, dynamic> allEntities, Map<String, dynamic> entity, String? isbn) {
    final claims = entity['claims'] as Map<String, dynamic>? ?? {};
    
    // 1. Get Title (Spanish first)
    final labels = entity['labels'] as Map<String, dynamic>? ?? {};
    final title = labels['es'] ?? labels['ca'] ?? labels['en'] 
        ?? (labels.values.isNotEmpty ? labels.values.first : 'Unknown Title');

    // 2. Get Author(s)
    String author = 'Unknown Author';
    final authorIds = claims['P50'] ?? claims['wdt:P50'];
    if (authorIds is List && authorIds.isNotEmpty) {
      final names = <String>[];
      for (final id in authorIds) {
        final authorEntity = allEntities[id];
        if (authorEntity != null) {
          final aLabels = authorEntity['labels'] as Map<String, dynamic>? ?? {};
          final name = aLabels['es'] ?? aLabels['ca'] ?? aLabels['en'] 
              ?? (aLabels.values.isNotEmpty ? aLabels.values.first : null);
          if (name != null) names.add(name);
        }
      }
      if (names.isNotEmpty) author = names.join(', ');
    } else {
      final nameStrings = claims['P2093'] ?? claims['wdt:P2093'];
      if (nameStrings is List && nameStrings.isNotEmpty) {
        author = nameStrings.first.toString();
      }
    }

    // 3. Get Publisher
    String? publisher;
    final publisherIds = claims['P123'] ?? claims['wdt:P123'];
    if (publisherIds is List && publisherIds.isNotEmpty) {
      final pubEntity = allEntities[publisherIds.first];
      if (pubEntity != null) {
        final pLabels = pubEntity['labels'] as Map<String, dynamic>? ?? {};
        publisher = pLabels['es'] ?? pLabels['ca'] ?? pLabels['en'] 
            ?? (pLabels.values.isNotEmpty ? pLabels.values.first : null);
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
      final dateStr = dateClaims.first.toString();
      if (dateStr.length >= 4) {
        publishYear = int.tryParse(dateStr.substring(0, 4));
      }
    }
    
    return BookSearchResult(
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      publishYear: publishYear,
      totalPages: null, // P1104 is pages, but often missing
      coverUrl: coverUrl,
      source: 'Inventaire.io',
    );
  }

  static String? _resolveImageUrl(dynamic imageVal) {
    if (imageVal == null) return null;
    
    if (imageVal is Map) {
      final url = imageVal['url'] as String?;
      if (url != null && url.startsWith('http')) return url;
      if (url != null) return 'https://inventaire.io$url';
    }
    
    final imgStr = imageVal.toString();
    if (imgStr.isEmpty || imgStr == 'null') return null;
    if (imgStr.startsWith('http')) return imgStr;
    
    // Hash image from Inventaire
    return 'https://inventaire.io/img/entities/$imgStr';
  }

  static Future<List<CoverCandidate>> searchCovers(String query) async {
    final results = await search(query, limit: 10);
    return results
        .where((r) => r.coverUrl != null)
        .map((r) => CoverCandidate(url: r.coverUrl!, source: 'Inventaire'))
        .toList();
  }
}
