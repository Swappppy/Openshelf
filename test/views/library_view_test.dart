import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:openshelf/views/library/library_view.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  testWidgets('Simplified LibraryView smoke test', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LibraryView(),
        ),
      ),
    );
    
    // Use pump instead of pumpAndSettle to avoid timing out on animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(NavigationBar), findsOneWidget);
    
    await db.close();
  });

  testWidgets('LibraryView displays books from database', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Insert a book
    await db.bookDao.insertBook(const BooksCompanion(
      title: Value('UI Test Book'),
      author: Value('Author'),
      status: Value(ReadingStatus.wantToRead),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LibraryView(),
        ),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); 

    expect(find.text('UI Test Book'), findsOneWidget);
    
    await db.close();
  });

  testWidgets('LibraryView search panel toggle', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LibraryView(),
        ),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Find search icon
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);

    await tester.tap(searchIcon);
    await tester.pump(const Duration(milliseconds: 200));

    // SearchPanel should be visible (contains TextFields)
    expect(find.byType(TextField), findsWidgets);
    
    await db.close();
  });
}
