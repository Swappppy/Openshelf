import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openshelf/controllers/book_selection_controller.dart';
import 'package:openshelf/views/book_form/widgets/form_components.dart';

void main() {
  group('BookSelectionController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial selection state is empty', () {
      final state = container.read(bookSelectionProvider);
      expect(state, isEmpty);
    });

    test('toggle selects and deselects book ID', () {
      final notifier = container.read(bookSelectionProvider.notifier);

      notifier.toggle(101);
      expect(container.read(bookSelectionProvider), equals({101}));

      notifier.toggle(102);
      expect(container.read(bookSelectionProvider), equals({101, 102}));

      notifier.toggle(101);
      expect(container.read(bookSelectionProvider), equals({102}));
    });

    test('select and deselect modify selection set correctly', () {
      final notifier = container.read(bookSelectionProvider.notifier);

      notifier.select(1);
      notifier.select(2);
      expect(container.read(bookSelectionProvider), equals({1, 2}));

      notifier.deselect(1);
      expect(container.read(bookSelectionProvider), equals({2}));
    });

    test('selectAll and clear work as expected', () {
      final notifier = container.read(bookSelectionProvider.notifier);

      notifier.selectAll([1, 2, 3, 4]);
      expect(container.read(bookSelectionProvider), equals({1, 2, 3, 4}));

      notifier.clear();
      expect(container.read(bookSelectionProvider), isEmpty);
    });

    test('toggleAll toggles all provided book IDs', () {
      final notifier = container.read(bookSelectionProvider.notifier);

      notifier.toggleAll([1, 2, 3]);
      expect(container.read(bookSelectionProvider), equals({1, 2, 3}));

      notifier.toggleAll([1, 2, 3]);
      expect(container.read(bookSelectionProvider), isEmpty);
    });
  });

  group('DelimitedAutocompleteFormField Helpers', () {
    test('getCurrentQuerySegment extracts query after last delimiter', () {
      expect(DelimitedAutocompleteFormField.getCurrentQuerySegment('Gabriel Garcia; Marq'), equals('Marq'));
      expect(DelimitedAutocompleteFormField.getCurrentQuerySegment('Author A / Author B / Aut'), equals('Aut'));
      expect(DelimitedAutocompleteFormField.getCurrentQuerySegment('Author A, Author B, '), equals(''));
      expect(DelimitedAutocompleteFormField.getCurrentQuerySegment('Single Author'), equals('Single Author'));
    });

    test('applySelection replaces segment after last delimiter with selected option', () {
      expect(
        DelimitedAutocompleteFormField.applySelection('Gabriel Garcia; Marq', 'Gabriel García Márquez'),
        equals('Gabriel Garcia; Gabriel García Márquez'),
      );
      expect(
        DelimitedAutocompleteFormField.applySelection('Author A / ', 'Author B'),
        equals('Author A / Author B'),
      );
      expect(
        DelimitedAutocompleteFormField.applySelection('Single Author', 'Single Author'),
        equals('Single Author'),
      );
    });
  });
}
