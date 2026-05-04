import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/main.dart';

void main() {
  testWidgets('Openshelf smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenshelfApp());
    expect(find.text('Openshelf'), findsOneWidget);
  });
}