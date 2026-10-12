import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:openshelf/models/book_search_query.dart';
import 'package:openshelf/models/book_search_result.dart';
import 'package:openshelf/services/google_books_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    registerFallbackValue(Uri());
  });

  group('GoogleBooksService Tests', () {
    test('searchStructured parses items with title, authors, cover, pageCount, and year', () async {
      final mockResponse = {
        'items': [
          {
            'volumeInfo': {
              'title': 'Cien años de soledad',
              'subtitle': 'Edición conmemorativa',
              'authors': ['Gabriel García Márquez'],
              'publisher': 'RAE',
              'publishedDate': '2007-03-15',
              'description': 'Una de las obras más importantes de la literatura hispanoamericana.',
              'industryIdentifiers': [
                {'type': 'ISBN_10', 'identifier': '8420471836'},
                {'type': 'ISBN_13', 'identifier': '9788420471839'},
              ],
              'pageCount': 608,
              'categories': ['Fiction / Magical Realism'],
              'imageLinks': {
                'smallThumbnail': 'http://books.google.com/books/content?id=123&edge=curl&source=gbs_api',
                'thumbnail': 'http://books.google.com/books/content?id=123&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
              },
              'language': 'es',
            }
          }
        ]
      };

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      final results = await GoogleBooksService.searchStructured(
        const BookSearchQuery(title: 'Cien años de soledad', author: 'García Márquez'),
        preferredLanguage: 'es',
        client: mockClient,
      );

      expect(results, isNotEmpty);
      final book = results.first;

      expect(book.title, 'Cien años de soledad');
      expect(book.subtitle, 'Edición conmemorativa');
      expect(book.authors.first, 'Gabriel García Márquez');
      expect(book.publisher, 'RAE');
      expect(book.publishYear, 2007);
      expect(book.isbn, '9788420471839');
      expect(book.pageCount, 608);
      expect(book.language, 'es');
      expect(book.coverUrl, startsWith('https://'));
      expect(book.coverUrl, isNot(contains('&edge=curl')));
      expect(book.source, 'Google Books');
    });

    test('getEditionsByWork fetches and sorts editions by preferred language', () async {
      final mockResponse = {
        'items': [
          {
            'volumeInfo': {
              'title': 'The Hobbit',
              'authors': ['J. R. R. Tolkien'],
              'publisher': 'HarperCollins',
              'publishedDate': '2012',
              'language': 'en',
              'industryIdentifiers': [
                {'type': 'ISBN_13', 'identifier': '9780007458424'}
              ]
            }
          },
          {
            'volumeInfo': {
              'title': 'El Hobbit',
              'authors': ['J. R. R. Tolkien'],
              'publisher': 'Minotauro',
              'publishedDate': '2010',
              'language': 'es',
              'industryIdentifiers': [
                {'type': 'ISBN_13', 'identifier': '9788445071410'}
              ]
            }
          }
        ]
      };

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      final work = BookSearchResult(
        title: 'El hobbit',
        authors: ['J. R. R. Tolkien'],
        source: 'Google Books',
      );

      final editions = await GoogleBooksService.getEditionsByWork(
        work,
        preferredLanguage: 'es',
        client: mockClient,
      );

      expect(editions.length, 2);
      expect(editions.first.title, 'El Hobbit');
      expect(editions.first.language, 'es');
      expect(editions.last.title, 'The Hobbit');
    });

    test('searchStructured falls back to search without publisher when publisher search is empty', () async {
      final emptyResponse = {'items': []};
      final successResponse = {
        'items': [
          {
            'volumeInfo': {
              'title': 'Dune',
              'authors': ['Frank Herbert'],
              'publisher': 'Chilton Books',
              'publishedDate': '1965',
            }
          }
        ]
      };

      int callCount = 0;
      when(() => mockClient.get(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return http.Response(jsonEncode(emptyResponse), 200);
        } else {
          return http.Response(jsonEncode(successResponse), 200);
        }
      });

      final results = await GoogleBooksService.searchStructured(
        const BookSearchQuery(title: 'Dune', author: 'Herbert', publisher: 'NonExistentPublisher'),
        client: mockClient,
      );

      expect(callCount, 2);
      expect(results, isNotEmpty);
      expect(results.first.title, 'Dune');
    });

    test('searchStructured falls back to title/author search when ISBN lookup finds no matches', () async {
      final emptyIsbnResponse = {'items': []};
      final titleSearchResponse = {
        'items': [
          {
            'volumeInfo': {
              'title': 'Fahrenheit 451',
              'authors': ['Ray Bradbury'],
              'publishedDate': '1953',
              'industryIdentifiers': [
                {'type': 'ISBN_13', 'identifier': '9781451673319'}
              ]
            }
          }
        ]
      };

      when(() => mockClient.get(any(that: predicate((Uri u) => u.query.contains('isbn:'))))).thenAnswer(
        (_) async => http.Response(jsonEncode(emptyIsbnResponse), 200),
      );

      when(() => mockClient.get(any(that: predicate((Uri u) => !u.query.contains('isbn:'))))).thenAnswer(
        (_) async => http.Response(jsonEncode(titleSearchResponse), 200),
      );

      final results = await GoogleBooksService.searchStructured(
        const BookSearchQuery(title: 'Fahrenheit 451', author: 'Ray Bradbury', isbn: '9780000000000'),
        client: mockClient,
      );

      expect(results, isNotEmpty);
      expect(results.first.title, 'Fahrenheit 451');
      expect(results.first.authors.first, 'Ray Bradbury');
    });

    test('getByIsbn returns BookSearchResult on success with HTTPS cover and clean ISBN', () async {
      final mockResponse = {
        'items': [
          {
            'volumeInfo': {
              'title': '1984',
              'authors': ['George Orwell'],
              'publishedDate': '1949-06-08',
              'industryIdentifiers': [
                {'type': 'ISBN_13', 'identifier': '9780451524935'}
              ],
              'imageLinks': {
                'medium': 'http://books.google.com/books/content?id=xyz&edge=curl',
              }
            }
          }
        ]
      };

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      final result = await GoogleBooksService.getByIsbn('978-0-451-52493-5', client: mockClient);

      expect(result, isNotNull);
      expect(result!.title, '1984');
      expect(result.isbn, '9780451524935');
      expect(result.publishYear, 1949);
      expect(result.coverUrl, 'https://books.google.com/books/content?id=xyz');
    });

    test('getByIsbn returns null on HTTP error or empty items', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      final result = await GoogleBooksService.getByIsbn('9780000000000', client: mockClient);

      expect(result, isNull);
    });
  });
}
