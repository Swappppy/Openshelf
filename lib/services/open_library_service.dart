import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_utils.dart';
import 'package:collection/collection.dart';
import '../models/book_search_result.dart';
import '../services/database.dart';
import 'book_search_service.dart';

/// Integration for the Open Library Search API.
class OpenLibraryService {
  static const _host = 'openlibrary.org';
  static const _searchPath = '/search.json';
  /// Edition sub-fields requested inside search.json (one best edition per work).
  static const _editionFields =
      'editions,editions.key,editions.title,editions.subtitle,editions.isbn,editions.publisher,'
      'editions.language,editions.cover_i,editions.publish_date,editions.number_of_pages_median,'
      'editions.physical_format';

  static const _headers = {
    'User-Agent': kOpenLibraryUserAgent,
    'Accept': 'application/json',
  };

  /// Searches for books using structured query parameters.
  static Future<List<BookSearchResult>> searchStructured(
    BookSearchQuery query, {
    String? preferredLanguage,
    http.Client? client,
  }) async {
    try {
      final Map<String, String> params = {
        'limit': '40',
        'fields': 'key,title,subtitle,author_name,isbn,publisher,first_publish_year,cover_i,number_of_pages_median,number_of_pages,description,edition_count,language,subject,physical_format,$_editionFields',
      };

      // Biases the edition picked for each work towards the user's language
      // (it does not exclude works without such an edition).
      if (preferredLanguage != null && preferredLanguage.length >= 2) {
        params['lang'] = preferredLanguage.substring(0, 2).toLowerCase();
      }

      final bool hasPublisherFilter = query.publisher != null && query.publisher!.trim().isNotEmpty;

      if (query.hasIsbn) {
        params['isbn'] = query.isbn!;
      } else {
        // Build 'q' for Open Library general search so translated titles/editions (e.g. 'Yo, robot' -> 'I, Robot') are indexed
        final qParts = [
          if (query.hasTitle) query.title!,
          if (query.hasAuthor) query.author!,
          if (hasPublisherFilter) 'publisher:"${query.publisher!.trim().replaceAll('"', '')}"',
          if (!query.hasTitle && !query.hasAuthor && query.rawQuery != null) query.rawQuery!,
        ];
        if (qParts.isEmpty) return [];
        params['q'] = qParts.join(' ');

        if (query.hasAuthor) {
          params['author'] = query.author!;
        }
      }

      final uri = Uri.https(_host, _searchPath, params);
      debugPrint('Open Library: Searching $uri');
      final httpClient = client ?? sharedHttpClient;
      final response = await httpClient.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List?;
        if (docs == null) return [];

        // Each work already carries its most relevant edition for this query
        // (ISBN, publisher and language are forwarded by Open Library), so no
        // extra request per result is needed. Full edition lists are loaded on
        // demand by WorkEditionsView when the user opens a work.
        final resolved = docs.map((doc) {
          final res = _parseDoc(doc, preferredLanguage: preferredLanguage);
          if (res.openLibraryWorkKey == null || (res.editionCount ?? 0) <= 1) return res;

          final editions = doc['editions'];
          final edDocs = editions is Map ? editions['docs'] as List? : null;
          if (edDocs == null || edDocs.isEmpty) return res;

          final top = _parseEmbeddedEdition(
            edDocs.first,
            targetIsbn: query.hasIsbn ? query.isbn : null,
            targetPublisher: hasPublisherFilter ? query.publisher : null,
            preferredLanguage: preferredLanguage,
          );

          // Without a publisher filter the count is the work's edition_count, as before.
          // With one, it is the number of editions Open Library matched for that publisher.
          final matchedCount = editions is Map ? editions['numFound'] : null;
          final int? editionCount = hasPublisherFilter
              ? (matchedCount is int ? matchedCount : res.editionCount)
              : res.editionCount;

          return res.copyWith(
            title: top.title.isNotEmpty ? top.title : null,
            subtitle: top.subtitle,
            isbn: top.isbn,
            language: top.language,
            publisher: top.publisher,
            coverUrl: top.coverUrl,
            publishYear: top.publishYear,
            pageCount: top.pageCount,
            format: top.format,
            editionCount: editionCount,
          );
        }).toList();

        return resolved;
      } else {
        debugPrint('Open Library Search Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Open Library Search Error: $e');
    }
    return [];
  }

  /// Searches for books using a general query string.
  static Future<List<BookSearchResult>> search(String query, {String? preferredLanguage, http.Client? client}) {
    return searchStructured(BookSearchQuery.fromRawQuery(query), preferredLanguage: preferredLanguage, client: client);
  }

  /// Looks up a book by its ISBN.
  static Future<BookSearchResult?> getByIsbn(String isbn, {String? preferredLanguage, http.Client? client}) async {
    final results = await searchStructured(BookSearchQuery(isbn: isbn), preferredLanguage: preferredLanguage, client: client);
    if (results.isEmpty) return null;
    return results.first;
  }

  /// Fetches editions for a given Open Library work key (e.g. "/works/OL46241W" or "OL46241W").
  /// Returns editions ordered strictly by preferred language matching in metadata first, then completeness.
  static Future<List<BookSearchResult>> getEditionsByWork(
    String workKey, {
    String? preferredLanguage,
    List<String>? baseAuthors,
    http.Client? client,
  }) async {
    try {
      String cleanKey = workKey.trim();
      if (cleanKey.contains('/works/')) {
        cleanKey = cleanKey.substring(cleanKey.indexOf('/works/'));
      } else if (!cleanKey.startsWith('/works/')) {
        cleanKey = '/works/${cleanKey.replaceAll(RegExp(r'^/+'), '')}';
      }
      if (cleanKey.endsWith('/')) {
        cleanKey = cleanKey.substring(0, cleanKey.length - 1);
      }

      final httpClient = client ?? sharedHttpClient;

      final workUri = Uri.https(_host, '$cleanKey.json');
      final editionsUri = Uri.https(_host, '$cleanKey/editions.json', {'limit': '100'});

      debugPrint('Open Library: Fetching work details and editions for $cleanKey');

      final responses = await Future.wait([
        httpClient.get(workUri, headers: _headers).timeout(const Duration(seconds: 10)).catchError((_) => http.Response('', 404)),
        httpClient.get(editionsUri, headers: _headers).timeout(const Duration(seconds: 12)),
      ]);

      final workResp = responses[0];
      final editionsResp = responses[1];

      String? workDescription;
      List<String>? workSubjects;
      String? workTitle;

      if (workResp.statusCode == 200) {
        try {
          final workData = json.decode(workResp.body);
          workDescription = _parseDescription(workData['description']);
          workTitle = workData['title'];
          if (workData['subjects'] is List) {
            workSubjects = (workData['subjects'] as List).map((s) => s.toString()).take(5).toList();
          }
        } catch (e) {
          debugPrint('Error parsing work JSON: $e');
        }
      }

      if (editionsResp.statusCode == 200) {
        final data = json.decode(editionsResp.body);
        final entries = data['entries'] as List?;
        if (entries == null) return [];

        final results = <BookSearchResult>[];
        final validPageCounts = <int>[];

        for (final entry in entries) {
          final title = entry['title'] ?? workTitle ?? 'Unknown Title';
          final subtitle = entry['subtitle'];

          final isbns13 = entry['isbn_13'] as List?;
          final isbns10 = entry['isbn_10'] as List?;
          final isbn = (isbns13?.isNotEmpty == true
              ? isbns13!.first
              : (isbns10?.isNotEmpty == true ? isbns10!.first : null)) as String?;

          final publishers = entry['publishers'] as List?;
          final publisher = publishers?.isNotEmpty == true ? publishers!.first.toString() : null;

          final publishDate = entry['publish_date']?.toString();
          final publishYear = _parsePublishYear(publishDate);

          final covers = entry['covers'] as List?;
          final coverId = covers?.isNotEmpty == true ? covers!.first : null;
          final coverUrl = (coverId != null && coverId is int && coverId > 0)
              ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
              : null;

          final languages = entry['languages'] as List?;
          String? language;
          if (languages?.isNotEmpty == true) {
            for (final langItem in languages!) {
              final langKey = langItem is Map ? langItem['key']?.toString() : langItem.toString();
              final code = _openLibraryLangToCode(langKey);
              if (code != null) {
                language = code;
                break;
              }
            }
          }

          final pageCount = _parsePageCount(entry['number_of_pages'] ?? entry['pagination']);
          if (pageCount != null && pageCount > 0) {
            validPageCounts.add(pageCount);
          }

          final description = _parseDescription(entry['description']) ?? workDescription;
          final physicalFormatRaw = entry['physical_format']?.toString();
          final format = _parseBookFormat(physicalFormatRaw);

          results.add(BookSearchResult(
            title: title,
            subtitle: subtitle,
            authors: baseAuthors ?? const ['Unknown Author'],
            isbn: isbn,
            language: language,
            publisher: publisher,
            coverUrl: coverUrl,
            publishYear: publishYear,
            pageCount: pageCount,
            description: description,
            categories: workSubjects ?? const [],
            source: 'Open Library',
            openLibraryWorkKey: cleanKey,
            format: format,
          ));
        }

        int? medianPages;
        if (validPageCounts.isNotEmpty) {
          validPageCounts.sort();
          medianPages = validPageCounts[validPageCounts.length ~/ 2];
        }

        final finalResults = results.map((ed) {
          if (ed.pageCount == null && medianPages != null) {
            return ed.copyWith(pageCount: medianPages);
          }
          return ed;
        }).toList();

        // Sort editions: Metadata preferred language match first, then cover, then ISBN, then year desc
        finalResults.sort((a, b) {
          final langComp = _compareByLanguage(a, b, preferredLanguage);
          if (langComp != 0) return langComp;

          final aCover = a.coverUrl != null ? 0 : 1;
          final bCover = b.coverUrl != null ? 0 : 1;
          if (aCover != bCover) return aCover.compareTo(bCover);

          final aIsbn = a.isbn != null ? 0 : 1;
          final bIsbn = b.isbn != null ? 0 : 1;
          if (aIsbn != bIsbn) return aIsbn.compareTo(bIsbn);

          return (b.publishYear ?? 0).compareTo(a.publishYear ?? 0);
        });

        return finalResults;
      }
    } catch (e) {
      debugPrint('Open Library Editions Error ($workKey): $e');
    }
    return [];
  }

  static int _compareByLanguage(BookSearchResult a, BookSearchResult b, String? preferredLanguage) {
    if (preferredLanguage == null || preferredLanguage.isEmpty) return 0;
    final targetLang = preferredLanguage.toLowerCase().substring(0, 2);

    final aLang = a.language?.toLowerCase().substring(0, 2);
    final bLang = b.language?.toLowerCase().substring(0, 2);

    final aMatch = (aLang == targetLang) ? 0 : (aLang != null ? 2 : 1);
    final bMatch = (bLang == targetLang) ? 0 : (bLang != null ? 2 : 1);

    return aMatch.compareTo(bMatch);
  }

  static String? _parseDescription(dynamic descRaw) {
    if (descRaw == null) return null;
    if (descRaw is String) return descRaw.trim().isNotEmpty ? descRaw.trim() : null;
    if (descRaw is Map) {
      final val = descRaw['value']?.toString().trim();
      if (val != null && val.isNotEmpty) return val;
    }
    return null;
  }

  static int? _parsePageCount(dynamic pageRaw) {
    if (pageRaw == null) return null;
    if (pageRaw is int) return pageRaw > 0 ? pageRaw : null;
    if (pageRaw is List && pageRaw.isNotEmpty) {
      return _parsePageCount(pageRaw.first);
    }
    final str = pageRaw.toString().trim();
    if (str.isEmpty) return null;
    final matches = RegExp(r'\d+').allMatches(str);
    if (matches.isNotEmpty) {
      int maxVal = 0;
      for (final m in matches) {
        final val = int.tryParse(m.group(0)!);
        if (val != null && val > maxVal) {
          maxVal = val;
        }
      }
      return maxVal > 0 ? maxVal : null;
    }
    return null;
  }

  static BookFormat? _parseBookFormat(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final norm = raw.toLowerCase();
    if (norm.contains('paperback') || norm.contains('pocket') || norm.contains('softcover') || norm.contains('rústica')) {
      return BookFormat.paperback;
    }
    if (norm.contains('hardcover') || norm.contains('hardback') || norm.contains('tapa dura')) {
      return BookFormat.hardcover;
    }
    if (norm.contains('ebook') || norm.contains('digital') || norm.contains('kindle') || norm.contains('pdf') || norm.contains('epub')) {
      return BookFormat.digital;
    }
    if (norm.contains('leather')) {
      return BookFormat.leatherbound;
    }
    return null;
  }

  static int? _parsePublishYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final match = RegExp(r'\b(18|19|20)\d{2}\b').firstMatch(dateStr);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  static String? _openLibraryLangToCode(String? langKey) {
    if (langKey == null) return null;
    final norm = langKey.toLowerCase();
    if (norm.contains('spa')) return 'es';
    if (norm.contains('eng')) return 'en';
    if (norm.contains('fre') || norm.contains('fra')) return 'fr';
    if (norm.contains('ger') || norm.contains('deu')) return 'de';
    if (norm.contains('ita')) return 'it';
    if (norm.contains('por')) return 'pt';
    if (norm.contains('cat')) return 'ca';
    if (norm.contains('rus')) return 'ru';
    if (norm.contains('est')) return 'et';
    if (norm.contains('jpn')) return 'ja';
    if (norm.contains('rum') || norm.contains('ron')) return 'ro';
    if (norm.contains('tur')) return 'tr';
    return null;
  }

  /// Parses an edition doc embedded in a search.json work result. Only the
  /// edition-specific fields are filled; the caller merges them over the work.
  static BookSearchResult _parseEmbeddedEdition(
    dynamic ed, {
    String? targetIsbn,
    String? targetPublisher,
    String? preferredLanguage,
  }) {
    String clean(String s) => s.replaceAll(RegExp(r'[^0-9X]'), '');

    final isbns = (ed['isbn'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    String? isbn;
    if (targetIsbn != null) {
      final target = clean(targetIsbn);
      isbn = isbns.firstWhereOrNull((i) => clean(i) == target);
    }
    isbn ??= isbns.firstWhereOrNull((i) => clean(i).length == 13) ?? isbns.firstOrNull;

    final coverId = ed['cover_i'];
    final coverUrl = (coverId is int && coverId > 0)
        ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
        : null;

    String? language;
    final prefPrefix = (preferredLanguage != null && preferredLanguage.length >= 2)
        ? preferredLanguage.substring(0, 2).toLowerCase()
        : null;
    for (final langItem in (ed['language'] as List?) ?? const []) {
      final code = _openLibraryLangToCode(langItem?.toString());
      if (code == null) continue;
      language ??= code;
      if (prefPrefix != null && code.startsWith(prefPrefix)) {
        language = code;
        break;
      }
    }

    final publishers = (ed['publisher'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final publisher = (targetPublisher != null
            ? publishers.firstWhereOrNull((p) => BookSearchService.matchesPublisher(p, targetPublisher))
            : null) ??
        publishers.firstOrNull;

    final physicalFormatRaw = (ed['physical_format'] as List?)?.firstOrNull?.toString() ?? ed['physical_format']?.toString();
    final publishDate = (ed['publish_date'] as List?)?.firstOrNull?.toString() ?? ed['publish_date']?.toString();

    return BookSearchResult(
      title: ed['title']?.toString() ?? '',
      subtitle: ed['subtitle']?.toString(),
      authors: const [],
      isbn: isbn,
      language: language,
      publisher: publisher,
      coverUrl: coverUrl,
      publishYear: _parsePublishYear(publishDate),
      pageCount: _parsePageCount(ed['number_of_pages_median'] ?? ed['number_of_pages']),
      format: _parseBookFormat(physicalFormatRaw),
      source: 'Open Library',
    );
  }

  static BookSearchResult _parseDoc(dynamic doc, {String? preferredLanguage}) {
    final coverId = doc['cover_i'];
    final coverUrl = coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg' : null;

    final editionCountRaw = doc['edition_count'];
    final int? editionCount = editionCountRaw is int ? editionCountRaw : int.tryParse(editionCountRaw?.toString() ?? '');
    final pageCount = _parsePageCount(doc['number_of_pages_median'] ?? doc['number_of_pages']);
    final description = _parseDescription(doc['description']);
    final physicalFormatRaw = (doc['physical_format'] as List?)?.firstOrNull?.toString() ?? doc['physical_format']?.toString();
    final format = _parseBookFormat(physicalFormatRaw);
    final subjects = (doc['subject'] as List?)?.take(5).cast<String>().toList() ?? [];

    final languagesRaw = doc['language'] as List?;
    String? language;
    if (languagesRaw?.isNotEmpty == true) {
      final prefPrefix = preferredLanguage?.toLowerCase().substring(0, 2);
      for (final langItem in languagesRaw!) {
        final code = _openLibraryLangToCode(langItem?.toString());
        if (code != null) {
          language ??= code;
          if (prefPrefix != null && code.startsWith(prefPrefix)) {
            language = code;
            break;
          }
        }
      }
    }

    return BookSearchResult(
      title: doc['title'] ?? 'Unknown Title',
      subtitle: doc['subtitle'],
      authors: (doc['author_name'] as List?)?.cast<String>() ?? ['Unknown Author'],
      isbn: (doc['isbn'] as List?)?.first,
      language: language,
      publisher: (doc['publisher'] as List?)?.first,
      coverUrl: coverUrl,
      publishYear: doc['first_publish_year'],
      pageCount: pageCount,
      description: description,
      categories: subjects,
      source: 'Open Library',
      openLibraryWorkKey: doc['key'] as String?,
      editionCount: editionCount,
      format: format,
    );
  }
}
