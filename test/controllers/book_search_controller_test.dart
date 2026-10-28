import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openshelf/controllers/book_search_controller.dart';

void main() {
  late ProviderContainer container;
  late BookSearchController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(bookSearchControllerProvider);
  });

  tearDown(() {
    container.dispose();
  });

  test('notifies listeners and updates hasAnyInput when text is typed', () {
    int notifyCount = 0;
    controller.addListener(() {
      notifyCount++;
    });

    expect(controller.hasAnyInput, false);

    controller.titleController.text = 'Dune';
    expect(controller.hasAnyInput, true);
    expect(notifyCount, greaterThan(0));

    controller.clearAll();
    expect(controller.hasAnyInput, false);
  });

  test('initQuery sets titleController when initialQuery is text', () {
    controller.initQuery('Dune');
    expect(controller.titleController.text, 'Dune');
    expect(controller.isbnController.text, isEmpty);
  });

  test('initQuery sets isbnController when initialQuery is a 13-digit ISBN', () {
    controller.initQuery('9788413622416');
    expect(controller.titleController.text, isEmpty);
    expect(controller.isbnController.text, '9788413622416');
  });

  test('initQuery sets isbnController when initialQuery is a formatted 10-digit ISBN', () {
    controller.initQuery('84-136-2241-6');
    expect(controller.titleController.text, isEmpty);
    expect(controller.isbnController.text, '8413622416');
  });
}
