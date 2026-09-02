import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/views/book_form/book_form_view.dart';
import 'package:openshelf/models/book_search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestWidget({BookSearchResult? prefill, Book? existingBook}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
        home: BookFormView(prefill: prefill, existingBook: existingBook),
      ),
    );
  }

  group('BookFormView Widget Tests', () {
    testWidgets('renders all initial fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Main Tab
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3)); 
      
      // Switch to Details Tab
      // Using a more robust way to find the tab
      await tester.tap(find.byIcon(Icons.label_outline));
      await tester.pumpAndSettle();
      
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
      expect(find.byKey(const ValueKey('save_text')), findsOneWidget);
    });

    testWidgets('prefills fields correctly from BookSearchResult', (tester) async {
      const result = BookSearchResult(
        title: 'Prefilled Title',
        authors: ['Jane Doe'],
        isbn: '1234567890',
        publisher: 'Test Publisher',
        source: 'Test',
      );

      await tester.pumpWidget(createTestWidget(prefill: result));
      await tester.pumpAndSettle();

      expect(find.text('Prefilled Title'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      
      // Ensure Publisher is visible and check it
      await tester.drag(find.byType(ListView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(find.text('Test Publisher'), findsOneWidget); 
      
      // ISBN is in Details Tab
      await tester.tap(find.byIcon(Icons.label_outline));
      await tester.pumpAndSettle();
      
      expect(find.text('1234567890'), findsOneWidget);
    });

    testWidgets('validation works for empty title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('save_text')));
      await tester.pumpAndSettle();

      // Check for error text in Main Tab (default)
      expect(find.textContaining('title'), findsWidgets);
    });
  });
}
