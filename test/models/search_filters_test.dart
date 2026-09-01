import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/models/search_filters.dart';

void main() {
  group('SearchFilters Model Tests', () {
    test('SearchFilters isEmpty identifies correctly', () {
      const filters = SearchFilters();
      expect(filters.isEmpty, true);

      final withQuery = filters.copyWith(query: 'test');
      expect(withQuery.isEmpty, false);
      expect(withQuery.query, 'test');
    });

    test('BooleanCondition serialization and copyWith', () {
      const condition = BooleanCondition(
        field: SearchField.title,
        operator: BooleanOperator.contains,
        value: 'flutter',
        connector: BooleanConnector.and,
      );

      final json = condition.toJson();
      final fromJson = BooleanCondition.fromJson(json);

      expect(fromJson.field, SearchField.title);
      expect(fromJson.operator, BooleanOperator.contains);
      expect(fromJson.value, 'flutter');
      expect(fromJson.connector, BooleanConnector.and);
      
      final updated = fromJson.copyWith(value: 'dart', connector: BooleanConnector.or);
      expect(updated.value, 'dart');
      expect(updated.connector, BooleanConnector.or);
    });

    test('BooleanQuery serialization edge cases', () {
      const query = BooleanQuery(conditions: [
        BooleanCondition(
          field: SearchField.title,
          operator: BooleanOperator.contains,
          value: 'dart',
        ),
      ]);

      final json = query.toJson();
      final fromJson = BooleanQuery.fromJson(json);

      expect(fromJson.conditions.length, 1);
      expect(fromJson.conditions.first.value, 'dart');
      
      const emptyQuery = BooleanQuery(conditions: []);
      expect(emptyQuery.conditions, isEmpty);
    });

    test('SearchFilters toBooleanQuery handles all fields', () {
      final filters = const SearchFilters().copyWith(
        query: 'Title',
        author: 'Author',
        subtitle: 'Sub',
        publisher: 'Pub',
        isbn: '123',
        notes: 'Note',
        language: 'en',
      );

      final bq = filters.toBooleanQuery();
      // query, author, subtitle, publisher, isbn, notes, language
      expect(bq.conditions.length, 7);
      expect(bq.conditions.any((c) => c.field == SearchField.title && c.value == 'Title'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.author && c.value == 'Author'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.subtitle && c.value == 'Sub'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.publisher && c.value == 'Pub'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.isbn && c.value == '123'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.notes && c.value == 'Note'), true);
      expect(bq.conditions.any((c) => c.field == SearchField.language && c.value == 'en'), true);
    });
  });
}
