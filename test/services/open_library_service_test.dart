import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:openshelf/services/open_library_service.dart';
import 'package:openshelf/services/book_search_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    registerFallbackValue(Uri());
  });

  group('OpenLibraryService Tests', () {
    test('searchStructured parses description and median page count', () async {
      final mockResponse = {
        'docs': [
          {
            'key': '/works/OL123W',
            'title': 'I, Robot',
            'author_name': ['Isaac Asimov'],
            'description': 'A classic sci-fi collection of stories about robots.',
            'number_of_pages_median': 256,
            'edition_count': 42,
            'cover_i': 12345,
            'isbn': ['9780553294385'],
            'publisher': ['Spectra'],
            'first_publish_year': 1950,
          }
        ]
      };

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await OpenLibraryService.searchStructured(
        const BookSearchQuery(title: 'I, Robot'),
        client: mockClient,
      );

      expect(results, isNotEmpty);
      final book = results.first;
      expect(book.title, 'I, Robot');
      expect(book.authors.first, 'Isaac Asimov');
      expect(book.description, 'A classic sci-fi collection of stories about robots.');
      expect(book.pageCount, 256);
      expect(book.editionCount, 42);
      expect(book.openLibraryWorkKey, '/works/OL123W');
    });

    test('getEditionsByWork inherits work description and computes page counts', () async {
      final workResponse = {
        'title': 'I, Robot',
        'key': '/works/OL123W',
        'description': 'Work synopsis from Open Library work object.',
        'subjects': ['Science Fiction', 'Robots'],
      };

      final editionsResponse = {
        'entries': [
          {
            'title': 'I, Robot - English Edition',
            'publishers': ['Spectra'],
            'publish_date': '1991',
            'isbn_13': ['9780553294385'],
            'pagination': '256 p.',
            'languages': [
              {'key': '/languages/eng'}
            ],
            'covers': [111],
          },
          {
            'title': 'Yo, Robot - Spanish Edition',
            'publishers': ['Edhasa'],
            'publish_date': '2010',
            'isbn_13': ['9788435018364'],
            'number_of_pages': 320,
            'languages': [
              {'key': '/languages/spa'}
            ],
            'covers': [222],
          },
        ]
      };

      when(() => mockClient.get(
            Uri.https('openlibrary.org', '/works/OL123W.json'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(jsonEncode(workResponse), 200));

      when(() => mockClient.get(
            Uri.https('openlibrary.org', '/works/OL123W/editions.json', {'limit': '100'}),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(jsonEncode(editionsResponse), 200));

      final editions = await OpenLibraryService.getEditionsByWork(
        '/works/OL123W',
        preferredLanguage: 'es',
        client: mockClient,
      );

      expect(editions.length, 2);

      // Preferred language 'es' should sort Spanish edition first
      final spanishEd = editions.first;
      expect(spanishEd.title, 'Yo, Robot - Spanish Edition');
      expect(spanishEd.description, 'Work synopsis from Open Library work object.');
      expect(spanishEd.pageCount, 320);
      expect(spanishEd.isbn, '9788435018364');

      final englishEd = editions.last;
      expect(englishEd.description, 'Work synopsis from Open Library work object.');
      expect(englishEd.pageCount, 256);
    });

    test('getByIsbn forwards first sorted edition when work key has multiple editions', () async {
      final searchResponse = {
        'docs': [
          {
            'key': '/works/OL123W',
            'title': 'I, Robot',
            'author_name': ['Isaac Asimov'],
            'edition_count': 10,
          }
        ]
      };

      final workResponse = {
        'title': 'I, Robot',
        'key': '/works/OL123W',
        'description': 'Work synopsis from Open Library.',
      };

      final editionsResponse = {
        'entries': [
          {
            'title': 'I, Robot',
            'publishers': ['Spectra'],
            'isbn_13': ['9780553294385'],
            'number_of_pages': 256,
            'covers': [999],
          }
        ]
      };

      when(() => mockClient.get(
            any(that: predicate<Uri>((uri) => uri.path == '/search.json')),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(jsonEncode(searchResponse), 200));

      when(() => mockClient.get(
            Uri.https('openlibrary.org', '/works/OL123W.json'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(jsonEncode(workResponse), 200));

      when(() => mockClient.get(
            Uri.https('openlibrary.org', '/works/OL123W/editions.json', {'limit': '100'}),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(jsonEncode(editionsResponse), 200));

      final result = await OpenLibraryService.getByIsbn('9780553294385', client: mockClient);

      expect(result, isNotNull);
      expect(result!.isbn, '9780553294385');
      expect(result.description, 'Work synopsis from Open Library.');
      expect(result.pageCount, 256);
      expect(result.publisher, 'Spectra');
    });
  });
}
