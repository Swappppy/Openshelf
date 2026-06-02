import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book_search_result.dart';

/// Integration for Inventaire.io, which provides high-quality Spanish and European metadata.
class InventaireService {
  static const _host = 'inventaire.io';
  static const _searchPath = '/api/search';
  static const _entitiesPath = '/api/entities/by-uris';
  static const _timeout = Duration(seconds: 10);
  static const _headers = {
    'User-Agent': 'Openshelf/1.0.0 (https://github.com/ftena/openshelf)',
    'Accept': 'application/json',
  };

  /// Searches for books using the Inventaire search API.
  static Future<List<BookSearchResult>> search(String query, {int limit = 40, String? preferredLanguage}) async {
    if (query.trim().isEmpty) return [];

    // General search by title/author
    try {
      final uri = Uri.https(_host, _searchPath, {
        'search': query.trim(),
        'types': 'works',
        'limit': '$limit',
        ...?preferredLanguage != null ? {'language': preferredLanguage} : null,
      });

      debugPrint('Inventaire: Searching $uri');
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('Inventaire Search Error: HTTP ${response.statusCode}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final labels = item['labels'] as Map<String, dynamic>?;
        String title = item['label'] as String? ?? 'Unknown Title';
        
        if (preferredLanguage != null && labels != null && labels.containsKey(preferredLanguage)) {
          title = labels[preferredLanguage];
        }
        
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
                final aLabels = authorEntity['labels'] as Map<String, dynamic>? ?? {};
                String? aName;
                if (preferredLanguage != null && aLabels.containsKey(preferredLanguage)) {
                  aName = aLabels[preferredLanguage];
                } else {
                  aName = authorEntity['label'] as String?;
                }
                if (aName != null) authors.add(aName);
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
          final imageClaims = [
            claims['P18'], claims['wdt:P18'],
            claims['P336'], claims['wdt:P336']
          ];
          for (final claim in imageClaims) {
            if (claim is List && claim.isNotEmpty) {
              coverUrl = _resolveImageUrl(claim.first);
              if (coverUrl != null) break;
            }
          }
        }
        
        // Resolve Subtitle (P1680)
        String? subtitle;
        if (claims != null) {
          final subtitleIds = (claims['P1680'] ?? claims['wdt:P1680']) as List<dynamic>?;
          if (subtitleIds != null && subtitleIds.isNotEmpty) {
            // It might be a string or another entity. For now try first as string
            subtitle = _extractValue(subtitleIds.first);
          }
        }

        return BookSearchResult(
          title: title,
          subtitle: subtitle,
          authors: authors,
          isbn: null,
          publisher: null,
          publishYear: null,
          pageCount: null,
          coverUrl: coverUrl,
          description: item['description'] as String?,
          source: 'Inventaire',
          inventaireWorkUri: item['uri'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Inventaire Search Error: $e');
      return [];
    }
  }

  /// Looks up a book by its ISBN via the entities endpoint.
  static Future<BookSearchResult?> getByIsbn(String isbn, {String? preferredLanguage}) async {
    try {
      final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
      final uri = Uri.https(_host, _entitiesPath, {
        'uris': 'isbn:$cleanIsbn',
        'relatives': 'wdt:P50|wdt:P123', // hydrates authors and publisher
      });

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

      return _fromEntity(entities, mainEntity, cleanIsbn, preferredLanguage: preferredLanguage);
    } catch (e) {
      debugPrint('Inventaire ISBN Error: $e');
      return null;
    }
  }

  /// Returns all editions (with covers) for a given work URI.
  /// [workUri] can be an Inventaire URI (inv:XXXX) or Wikidata URI (wd:QXXXX).
  static Future<List<BookSearchResult>> getEditionsByWork(String workUri, {
    String? preferredLanguage,
  }) async {
    const editionsTimeout = Duration(seconds: 20);
    try {
      final preferredLangWd = _langToWdUri(preferredLanguage);

      // Inventaire exposes a SPARQL endpoint for reverse property lookups.
      // This query finds all editions (inv: entities) that have wdt:P629 = workUri.
      // We also prioritize the user's preferred language.
      final sparqlQuery = preferredLangWd != null ? '''
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
SELECT ?edition ?hasPreferredLang WHERE {
  ?edition wdt:P629 <http://www.wikidata.org/entity/${workUri.replaceFirst('wd:', '')}> .
  BIND(EXISTS { ?edition wdt:P407 <$preferredLangWd> } AS ?hasPreferredLang)
}
ORDER BY DESC(?hasPreferredLang)
LIMIT 50
''' : '''
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
SELECT ?edition WHERE {
  ?edition wdt:P629 <http://www.wikidata.org/entity/${workUri.replaceFirst('wd:', '')}> .
}
LIMIT 50
''';

      final sparqlUri = Uri.https('query.inventaire.io', '/sparql', {
        'query': sparqlQuery,
      });

      debugPrint('Inventaire: SPARQL editions query for $workUri (lang: $preferredLanguage)');
      final sparqlResponse = await http.get(
        sparqlUri,
        headers: {..._headers, 'Accept': 'application/sparql-results+json'},
      ).timeout(editionsTimeout);

      debugPrint('Inventaire: SPARQL HTTP ${sparqlResponse.statusCode}');
      if (sparqlResponse.statusCode != 200) {
        debugPrint('Inventaire SPARQL Error: ${sparqlResponse.body.substring(0, sparqlResponse.body.length.clamp(0, 200))}');
        return [];
      }

      final sparqlData = jsonDecode(sparqlResponse.body) as Map<String, dynamic>;
      final bindings = (sparqlData['results']?['bindings'] as List?) ?? [];

      debugPrint('Inventaire: SPARQL returned ${bindings.length} edition bindings');
      if (bindings.isEmpty) return [];

      final editionUris = bindings
          .map((b) => b['edition']?['value'] as String?)
          .whereType<String>()
          .map((uri) {
        if (uri.startsWith('https://inventaire.io/entity/')) {
          return uri.replaceFirst('https://inventaire.io/entity/', '');
        }
        if (uri.startsWith('http://inventaire.io/entity/')) {
          // SPARQL returns http (no s), extract the hash and build inv: prefix
          final hash = uri.replaceFirst('http://inventaire.io/entity/', '');
          return 'inv:$hash';
        }
        if (uri.startsWith('http://www.wikidata.org/entity/')) {
          return 'wd:${uri.replaceFirst('http://www.wikidata.org/entity/', '')}';
        }
        return uri;
      })
          .toList();

      debugPrint('Inventaire: Found ${editionUris.length} edition URIs: ${editionUris.take(5).join(', ')}...');
      if (editionUris.isEmpty) return [];

      // Batch fetch edition data (max 50)
      final batch = editionUris.take(50).join('|');
      final fetchUri = Uri.https(_host, _entitiesPath, {'uris': batch});
      final fetchResponse = await http.get(fetchUri, headers: _headers).timeout(editionsTimeout);

      if (fetchResponse.statusCode != 200) {
        debugPrint('Inventaire Editions Fetch Error: HTTP ${fetchResponse.statusCode}');
        return [];
      }

      final fetchData = jsonDecode(fetchResponse.body) as Map<String, dynamic>;
      final entities = fetchData['entities'] as Map<String, dynamic>? ?? {};

      debugPrint('Inventaire: Hydrated ${entities.length} edition entities');

      final results = <BookSearchResult>[];

      for (final entry in entities.entries) {
        final ed = entry.value as Map<String, dynamic>;
        if (ed['type'] != 'edition') continue;

        final claims = ed['claims'] as Map<String, dynamic>? ?? {};
        final labels = ed['labels'] as Map<String, dynamic>? ?? {};

        final coverUrl = _resolveImageUrl(ed['image']);

        String? title = labels[preferredLanguage ?? 'es'] as String?
            ?? labels['en'] as String?
            ?? (labels.values.isNotEmpty ? labels.values.first.toString() : null);

        final isbn13List = claims['wdt:P212'] as List?;
        final isbn10List = claims['wdt:P957'] as List?;
        final isbn = (isbn13List?.isNotEmpty == true
            ? isbn13List!.first
            : (isbn10List?.isNotEmpty == true ? isbn10List!.first : null)) as String?;

        final dateRaw = (claims['wdt:P577'] as List?)?.isNotEmpty == true
            ? claims['wdt:P577']!.first.toString()
            : null;
        final publishYear = dateRaw != null ? int.tryParse(dateRaw.split('-').first) : null;

        final pages = (claims['wdt:P1104'] as List?)?.isNotEmpty == true
            ? claims['wdt:P1104']!.first : null;
        final pageCount = pages != null ? int.tryParse(pages.toString()) : null;

        if (title == null && isbn == null && coverUrl == null) continue;

        debugPrint('  Edition ${entry.key}: cover=${coverUrl != null} isbn=$isbn title=$title');

        // Resolve subtitle (P1680)
        final subtitleRaw = claims['wdt:P1680'] as List?;
        final subtitle = subtitleRaw?.isNotEmpty == true ? _extractValue(subtitleRaw!.first) : null;

        // Resolve language (P407)
        final langRaw = (claims['wdt:P407'] as List?)?.isNotEmpty == true ? claims['wdt:P407']!.first.toString() : null;
        final language = _wdUriToLangCode(langRaw);

        // Resolve translator (P655)
        final translatorRaw = (claims['wdt:P655'] as List?)?.isNotEmpty == true ? claims['wdt:P655']!.first.toString() : null;
        String? translator;
        if (translatorRaw != null) {
          final transEntity = entities[translatorRaw];
          if (transEntity != null) {
            final tLabels = transEntity['labels'] as Map<String, dynamic>? ?? {};
            translator = (preferredLanguage != null && tLabels.containsKey(preferredLanguage))
                ? tLabels[preferredLanguage]
                : (transEntity['label'] as String?);
          }
        }

        results.add(BookSearchResult(
          title: title ?? '',
          subtitle: subtitle,
          authors: const [],
          isbn: isbn,
          language: language,
          translator: translator,
          coverUrl: coverUrl,
          publishYear: publishYear,
          pageCount: pageCount,
          source: 'Inventaire',
          inventaireWorkUri: workUri,
        ));
      }

      results.sort((a, b) {
        final aCover = a.coverUrl != null ? 0 : 1;
        final bCover = b.coverUrl != null ? 0 : 1;
        if (aCover != bCover) return aCover.compareTo(bCover);
        return (b.publishYear ?? 0).compareTo(a.publishYear ?? 0);
      });

      debugPrint('Inventaire: Returning ${results.length} editions (${results.where((r) => r.coverUrl != null).length} with cover)');
      return results;
    } catch (e) {
      debugPrint('Inventaire Editions Error (workUri=$workUri): $e');
      return [];
    }
  }

  static BookSearchResult _fromEntity(Map<String, dynamic> allEntities, Map<String, dynamic> entity, String? isbn, {String? preferredLanguage}) {
    final claims = entity['claims'] as Map<String, dynamic>? ?? {};
    
    // 1. Get Title (Prioritize preferred language)
    final labels = entity['labels'] as Map<String, dynamic>? ?? {};
    String title = 'Unknown Title';
    if (preferredLanguage != null && labels.containsKey(preferredLanguage)) {
      title = labels[preferredLanguage];
    } else {
      title = labels['es'] ?? labels['en'] ?? (labels.values.isNotEmpty ? labels.values.first : 'Unknown Title');
    }

    // 2. Get Author(s)
    List<String> authors = [];
    final authorIds = claims['P50'] ?? claims['wdt:P50'];
    if (authorIds is List && authorIds.isNotEmpty) {
      for (final id in authorIds) {
        final authorEntity = allEntities[id];
        if (authorEntity != null) {
          final aLabels = authorEntity['labels'] as Map<String, dynamic>? ?? {};
          String? name;
          if (preferredLanguage != null && aLabels.containsKey(preferredLanguage)) {
            name = aLabels[preferredLanguage];
          } else {
            name = aLabels['es'] ?? aLabels['en'] ?? (aLabels.values.isNotEmpty ? aLabels.values.first : null);
          }
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
        if (preferredLanguage != null && pLabels.containsKey(preferredLanguage)) {
          publisher = pLabels[preferredLanguage];
        } else {
          publisher = pLabels['es'] ?? pLabels['en'] ?? (pLabels.values.isNotEmpty ? pLabels.values.first : null);
        }
      }
    }

    // 4. Get Image
    String? coverUrl = _resolveImageUrl(entity['image']);
    if (coverUrl == null) {
      final imageClaims = [
        claims['invp:P2'], claims['invp:P1'],
        claims['P18'], claims['wdt:P18'],
        claims['P336'], claims['wdt:P336']
      ];
      for (final claim in imageClaims) {
        if (claim is List && claim.isNotEmpty) {
          coverUrl = _resolveImageUrl(claim.first);
          if (coverUrl != null) break;
        }
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

    // 6. Get Subtitle
    final subtitleRaw = claims['P1680'] ?? claims['wdt:P1680'];
    final subtitle = subtitleRaw is List && subtitleRaw.isNotEmpty ? _extractValue(subtitleRaw.first) : null;

    // 7. Get Language
    final langRaw = (claims['P407'] ?? claims['wdt:P407']) as List?;
    final language = langRaw != null && langRaw.isNotEmpty ? _wdUriToLangCode(langRaw.first.toString()) : null;

    // 8. Get Translator
    final transRaw = (claims['P655'] ?? claims['wdt:P655']) as List?;
    String? translator;
    if (transRaw != null && transRaw.isNotEmpty) {
      final transId = transRaw.first.toString();
      final transEntity = allEntities[transId];
      if (transEntity != null) {
        final tLabels = transEntity['labels'] as Map<String, dynamic>? ?? {};
        translator = (preferredLanguage != null && tLabels.containsKey(preferredLanguage))
            ? tLabels[preferredLanguage]
            : (tLabels['es'] ?? tLabels['en'] ?? (tLabels.values.isNotEmpty ? tLabels.values.first : null));
      }
    }
    
    return BookSearchResult(
      title: title,
      subtitle: subtitle,
      authors: authors,
      isbn: isbn,
      language: language,
      translator: translator,
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
      if (url != null) return _resolveImageUrl(url);
      
      final value = imageVal['value'] as String?;
      if (value != null) return _resolveImageUrl(value);
    }
    
    final imgStr = imageVal.toString().trim();
    if (imgStr.isEmpty || imgStr == 'null') return null;
    if (imgStr.startsWith('http')) return imgStr;
    
    if (imgStr.startsWith('/')) {
      return 'https://inventaire.io$imgStr';
    }
    
    // Check if it's a Wikimedia file reference
    if (imgStr.toLowerCase().contains('file:')) {
      final parts = imgStr.split(':');
      final fileName = parts.last;
      return 'https://inventaire.io/img/entities/${Uri.encodeComponent(fileName)}';
    }
    
    // If it looks like a hash (hexadecimal 32-40 chars)
    if (RegExp(r'^[0-9a-fA-F]{32,40}$').hasMatch(imgStr)) {
      return 'https://inventaire.io/img/entities/$imgStr';
    }
    
    // If it looks like a filename (contains dots and typical image extensions)
    if (imgStr.contains('.')) {
      return 'https://inventaire.io/img/entities/${Uri.encodeComponent(imgStr)}';
    }
    
    return null;
  }

  static String? _extractValue(dynamic claim) {
    if (claim is String) return claim;
    if (claim is Map) return claim['value']?.toString();
    return claim?.toString();
  }

  static Future<List<dynamic>> searchCovers(String query) async {
    final results = await search(query, limit: 10);
    return results
        .where((r) => r.coverUrl != null)
        .toList();
  }

  /// Maps BCP-47 language codes to Wikidata entity URIs (wdt:P407 values).
  static String? _langToWdUri(String? lang) {
    const map = {
      'es': 'http://www.wikidata.org/entity/Q1321',
      'en': 'http://www.wikidata.org/entity/Q1860',
      'fr': 'http://www.wikidata.org/entity/Q150',
      'de': 'http://www.wikidata.org/entity/Q188',
      'it': 'http://www.wikidata.org/entity/Q652',
      'pt': 'http://www.wikidata.org/entity/Q5146',
      'ca': 'http://www.wikidata.org/entity/Q7026',
      'nl': 'http://www.wikidata.org/entity/Q7411',
      'pl': 'http://www.wikidata.org/entity/Q809',
      'fi': 'http://www.wikidata.org/entity/Q1412',
    };
    return lang != null ? map[lang] : null;
  }

  /// Maps Wikidata entity URIs (wdt:P407 values) back to BCP-47 language codes.
  static String? _wdUriToLangCode(String? uri) {
    if (uri == null) return null;
    const map = {
      'http://www.wikidata.org/entity/Q1321': 'es',
      'http://www.wikidata.org/entity/Q1860': 'en',
      'http://www.wikidata.org/entity/Q150': 'fr',
      'http://www.wikidata.org/entity/Q188': 'de',
      'http://www.wikidata.org/entity/Q652': 'it',
      'http://www.wikidata.org/entity/Q5146': 'pt',
      'http://www.wikidata.org/entity/Q7026': 'ca',
      'http://www.wikidata.org/entity/Q7411': 'nl',
      'http://www.wikidata.org/entity/Q809': 'pl',
      'http://www.wikidata.org/entity/Q1412': 'fi',
    };
    return map[uri];
  }
}
