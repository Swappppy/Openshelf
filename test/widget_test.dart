import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openshelf/main.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/services/database.dart';

void main() {
  testWidgets('Openshelf smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Use a memory database for tests to avoid disk I/O and pending timers from background processes
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const OpenshelfApp(),
      ),
    );

    // Wait for all initializations and animations to settle
    await tester.pumpAndSettle();

    // Verify that the app builds and shows something
    expect(find.byType(OpenshelfApp), findsOneWidget);

    // Close the database to clean up resources
    await db.close();
    
    // Explicitly dispose the widget tree and wait for cleanup timers
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}
