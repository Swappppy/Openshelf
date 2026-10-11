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
}
