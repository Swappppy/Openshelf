import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/views/book_form/advanced_pagination_view.dart';

void main() {
  Widget buildTestWidget({
    required PaginationConfig initialConfig,
    required void Function(PaginationConfig config, Map<int, int>? segmentProgress) onSave,
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
      onSave: (config, _) => savedConfig = config,
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
      onSave: (config, _) => savedConfig = config,
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

  testWidgets('Reordering segments preserves segment lengths and adjusts physical bounds contiguously', (WidgetTester tester) async {
    // Segment A: 1..50 (50 pages), Segment B: 51..150 (100 pages)
    final initialConfig = PaginationConfig(
      segments: [
        PaginationSegment(startPhysical: 1, endPhysical: 50, type: PageNumberingType.arabic, label: 'Segment A'),
        PaginationSegment(startPhysical: 51, endPhysical: 150, type: PageNumberingType.arabic, label: 'Segment B'),
      ],
      useVisualMode: false,
    );

    PaginationConfig? savedConfig;

    await tester.pumpWidget(buildTestWidget(
      initialConfig: initialConfig,
      onSave: (config, _) => savedConfig = config,
    ));

    await tester.pumpAndSettle();

    // Find drag handle for Segment B (second segment) and drag it above Segment A
    final dragHandles = find.byIcon(Icons.drag_handle);
    expect(dragHandles, findsNWidgets(2));

    // Drag second handle upwards
    await tester.drag(dragHandles.at(1), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Save and verify configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(savedConfig, isNotNull);
    expect(savedConfig!.segments.length, equals(2));

    // First segment is now Segment B (length 100): physical 1..100
    final newSeg0 = savedConfig!.segments[0];
    expect(newSeg0.label, equals('Segment B'));
    expect(newSeg0.startPhysical, equals(1));
    expect(newSeg0.endPhysical, equals(100));

    // Second segment is now Segment A (length 50): physical 101..150
    final newSeg1 = savedConfig!.segments[1];
    expect(newSeg1.label, equals('Segment A'));
    expect(newSeg1.startPhysical, equals(101));
    expect(newSeg1.endPhysical, equals(150));
  });

  testWidgets('Reordering segments remaps segment progress map and preserves reading progress per segment', (WidgetTester tester) async {
    // Segment A (index 0, 50 pages): 50 pages read (100%)
    // Segment B (index 1, 100 pages): 50 pages read (50%)
    final initialConfig = PaginationConfig(
      segments: [
        PaginationSegment(startPhysical: 1, endPhysical: 50, type: PageNumberingType.arabic, label: 'Segment A'),
        PaginationSegment(startPhysical: 51, endPhysical: 150, type: PageNumberingType.arabic, label: 'Segment B'),
      ],
      useVisualMode: false,
    );

    final initialProgress = {0: 50, 1: 50};
    PaginationConfig? savedConfig;
    Map<int, int>? savedProgress;

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: AdvancedPaginationView(
        initialConfig: initialConfig,
        initialSegmentProgress: initialProgress,
        totalPages: 150,
        onSave: (config, segProg) {
          savedConfig = config;
          savedProgress = segProg;
        },
      ),
    ));

    await tester.pumpAndSettle();

    // Drag Segment B (index 1) to index 0
    final dragHandles = find.byIcon(Icons.drag_handle);
    await tester.drag(dragHandles.at(1), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(savedConfig, isNotNull);
    expect(savedConfig!.segments[0].label, equals('Segment B'));
    expect(savedConfig!.segments[1].label, equals('Segment A'));

    // Segment B is now index 0 -> should have 50 pages read out of 100 (50%)
    // Segment A is now index 1 -> should have 50 pages read out of 50 (100%)
    expect(savedProgress, isNotNull);
    expect(savedProgress![0], equals(50));
    expect(savedProgress![1], equals(50));
  });

  testWidgets('Modifying physical end page of a non-last segment cascades and preserves subsequent segment lengths', (WidgetTester tester) async {
    // Segment 0: 1..50 (50 pages), Segment 1: 51..150 (100 pages)
    final initialConfig = PaginationConfig(
      segments: [
        PaginationSegment(startPhysical: 1, endPhysical: 50, type: PageNumberingType.arabic, label: 'Segment 0'),
        PaginationSegment(startPhysical: 51, endPhysical: 150, type: PageNumberingType.arabic, label: 'Segment 1'),
      ],
      useVisualMode: false,
    );

    PaginationConfig? savedConfig;

    await tester.pumpWidget(buildTestWidget(
      initialConfig: initialConfig,
      onSave: (config, _) => savedConfig = config,
    ));

    await tester.pumpAndSettle();

    // Find the end page TextFormField for Segment 0 (first end input field)
    final textFields = find.byType(TextFormField);
    // Index 0: Label 0, Index 1: Start 0, Index 2: End 0
    final endTextField0 = textFields.at(2);

    // Enter '60' and submit (unfocus/submit)
    await tester.enterText(endTextField0, '60');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Save and verify configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(savedConfig, isNotNull);
    expect(savedConfig!.segments.length, equals(2));

    // Segment 0 is now 1..60
    expect(savedConfig!.segments[0].startPhysical, equals(1));
    expect(savedConfig!.segments[0].endPhysical, equals(60));

    // Segment 1 should be 61..160 (length 100 preserved)
    expect(savedConfig!.segments[1].startPhysical, equals(61));
    expect(savedConfig!.segments[1].endPhysical, equals(160));
  });
}
