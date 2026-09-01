import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/books_controller.dart';
import 'package:openshelf/views/book_detail/book_detail_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';

void main() {
  final testBook = Book(
    id: 1,
    title: 'Test Book',
    author: 'Test Author',
    status: ReadingStatus.wantToRead,
    copies: 1,
    createdAt: DateTime.now(),
  );

  testWidgets('BookDetailView displays book information', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bookByIdProvider(1).overrideWith((ref) => Stream.value(testBook)),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: BookDetailView(book: testBook),
        ),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Test Book'), findsWidgets);
    expect(find.text('Test Author'), findsWidgets);
    await db.close();
  });

  testWidgets('BookDetailView shows delete dialog', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bookByIdProvider(1).overrideWith((ref) => Stream.value(testBook)),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: BookDetailView(book: testBook),
        ),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(AlertDialog), findsOneWidget);
    await db.close();
  });
}
