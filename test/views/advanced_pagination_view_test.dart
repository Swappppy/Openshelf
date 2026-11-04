import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/views/book_form/advanced_pagination_view.dart';

void main() {
  Widget buildTestWidget({
    required PaginationConfig initialConfig,
    required Function(PaginationConfig) onSave,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: AdvancedPaginationView(
        initialConfig: initialConfig,
        totalPages: 200,
        onSave: onSave,
      ),
    );
  }

  testWidgets('Tapping restart numbering button enables visual mode and sets restartNumbering to true', (WidgetTester tester) async {
    final initialConfig = PaginationConfig(
      segments: [
        PaginationSegment(startPhysical: 1, endPhysical: 100, type: PageNumberingType.arabic),
        PaginationSegment(startPhysical: 101, endPhysical: 200, type: PageNumberingType.arabic),
      ],
      useVisualMode: false,
    );

    PaginationConfig? savedConfig;

    await tester.pumpWidget(buildTestWidget(
      initialConfig: initialConfig,
      onSave: (config) => savedConfig = config,
    ));

    await tester.pumpAndSettle();

    // Verify initial state: visual mode switch is OFF
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    // Find the restart numbering IconButton (Icons.restart_alt) for the second segment
    final restartButtons = find.byIcon(Icons.restart_alt);
    expect(restartButtons, findsNWidgets(2));

    // Tap restart button on second segment
    await tester.tap(restartButtons.at(1));
    await tester.pumpAndSettle();

    // Visual mode switch should now be ON automatically
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    // Save and verify configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(savedConfig, isNotNull);
    expect(savedConfig!.useVisualMode, isTrue);
    expect(savedConfig!.segments[1].restartNumbering, isTrue);
    // Offset for segment 1 (restarted) should be 0
    expect(savedConfig!.segments[1].offset, equals(0));
  });

  testWidgets('Deactivating restart numbering button does not turn off visual mode', (WidgetTester tester) async {
    final initialConfig = PaginationConfig(
      segments: [
        PaginationSegment(startPhysical: 1, endPhysical: 100, type: PageNumberingType.arabic),
        PaginationSegment(startPhysical: 101, endPhysical: 200, type: PageNumberingType.arabic, restartNumbering: true, offset: 0),
      ],
      useVisualMode: true,
    );

    PaginationConfig? savedConfig;

    await tester.pumpWidget(buildTestWidget(
      initialConfig: initialConfig,
      onSave: (config) => savedConfig = config,
    ));

    await tester.pumpAndSettle();

    // Verify visual mode switch is ON
    final switchFinder = find.byType(Switch);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    // Tap restart button on second segment to DEACTIVATE it
    final restartButtons = find.byIcon(Icons.restart_alt);
    await tester.tap(restartButtons.at(1));
    await tester.pumpAndSettle();

    // Visual mode switch MUST STILL BE ON ("si se desactiva, no se desactiva el modo visual automáticamente")
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    // Save and verify configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(savedConfig, isNotNull);
    expect(savedConfig!.useVisualMode, isTrue);
    expect(savedConfig!.segments[1].restartNumbering, isFalse);
    // Offset for segment 1 (no longer restarted) should accumulate from segment 0 (100)
    expect(savedConfig!.segments[1].offset, equals(100));
  });
}
