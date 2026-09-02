import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:openshelf/services/inventaire_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    registerFallbackValue(Uri());
  });

  group('InventaireService Tests', () {
    test('search returns list of BookSearchResult on success', () async {
      final mockResponse = {
        'results': [
          {
            'label': 'Test Book',
            'uri': 'inv:123',
            'description': 'A test book description',
            'image': '0123456789abcdef0123456789abcdef01234567',
            'claims': {
              'P50': ['wd:Q1']
            },
            'entities': {
              'wd:Q1': {
                'label': 'Test Author',
                'labels': {'en': 'Test Author'}
              }
            }
          }
        ]
      };

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await InventaireService.search('test', client: mockClient);

      expect(results, isNotEmpty);
      expect(results.first.title, 'Test Book');
      expect(results.first.authors.first, 'Test Author');
      expect(results.first.coverUrl, contains('0123456789abcdef0123456789abcdef01234567'));
      expect(results.first.source, 'Inventaire');
    });

    test('search handles author fallback from description', () async {
      final mockResponse = {
        'results': [
          {
            'label': 'No Author Entity Book',
            'description': 'novel by Jane Doe',
            'uri': 'inv:999'
          }
        ]
      };

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final results = await InventaireService.search('test', client: mockClient);

      expect(results, isNotEmpty);
      expect(results.first.authors.first, 'Jane Doe');
    });

    test('search returns empty list on HTTP error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final results = await InventaireService.search('test', client: mockClient);

      expect(results, isEmpty);
    });

    test('getByIsbn returns BookSearchResult on success', () async {
      final mockResponse = {
        'entities': {
          'inv:456': {
            'type': 'edition',
            'labels': {'en': 'ISBN Book'},
            'claims': {
              'wdt:P50': ['wd:Q2'],
              'wdt:P577': ['2023-01-01']
            }
          },
          'wd:Q2': {
            'labels': {'en': 'ISBN Author'}
          }
        }
      };

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await InventaireService.getByIsbn('1234567890', client: mockClient);

      expect(result, isNotNull);
      expect(result!.title, 'ISBN Book');
      expect(result.authors.first, 'ISBN Author');
      expect(result.publishYear, 2023);
    });

    test('getEditionsByWork successfully fetches and parses editions', () async {
      // 1. Mock SPARQL response
      final sparqlResponse = {
        'results': {
          'bindings': [
            {
              'edition': {'value': 'https://inventaire.io/entity/ed1'}
            }
          ]
        }
      };

      // 2. Mock Entities fetch response
      final entitiesResponse = {
        'entities': {
          'inv:ed1': {
            'type': 'edition',
            'labels': {'en': 'Edition Title'},
            'claims': {
              'wdt:P212': ['9781234567890'],
              'wdt:P577': ['2020-05-15']
            },
            'image': '0123456789abcdef0123456789abcdef01234567'
          }
        }
      };

      // Sequential response setup
      int callCount = 0;
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((invocation) async {
        final uri = invocation.positionalArguments.first as Uri;
        if (uri.host == 'query.inventaire.io') {
          return http.Response(jsonEncode(sparqlResponse), 200);
        } else {
          return http.Response(jsonEncode(entitiesResponse), 200);
        }
      });

      final results = await InventaireService.getEditionsByWork('wd:Q123', client: mockClient);

      expect(results, isNotEmpty);
      expect(results.first.title, 'Edition Title');
      expect(results.first.isbn, '9781234567890');
      expect(results.first.publishYear, 2020);
      expect(results.first.coverUrl, contains('0123456789abcdef0123456789abcdef01234567'));
    });

    test('getEditionsByWork returns empty list on SPARQL failure', () async {
      when(() => mockClient.get(any(that: predicate((Uri u) => u.host == 'query.inventaire.io')), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final results = await InventaireService.getEditionsByWork('wd:Q123', client: mockClient);
      expect(results, isEmpty);
    });
  });
}
