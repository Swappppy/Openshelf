import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openshelf/main.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';

void main() {
  testWidgets('Openshelf smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const OpenshelfApp(),
      ),
    );
    // Smoke test: just ensure it builds
  });
}
