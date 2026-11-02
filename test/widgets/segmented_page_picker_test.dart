import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openshelf/l10n/app_localizations.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/widgets/segmented_page_picker.dart';

void main() {
  Widget buildPickerWidget({
    required int totalPages,
    required PaginationConfig config,
    required Function(int, Map<int, int>, PaginationConfig) onSave,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: SegmentedPagePicker(
          totalPages: totalPages,
          config: config,
          onSave: onSave,
        ),
      ),
    );
  }

  testWidgets('SegmentedPagePicker renders carousel with +N badge for remaining segments', (WidgetTester tester) async {
    // 15 segments
    final List<PaginationSegment> segments = List.generate(
      15,
      (i) => PaginationSegment(
        startPhysical: i * 10 + 1,
        endPhysical: (i + 1) * 10,
        type: PageNumberingType.arabic,
        label: 'Segment ${i + 1}',
      ),
    );

    final config = PaginationConfig(segments: segments, markers: []);

    await tester.pumpWidget(
      buildPickerWidget(
        totalPages: 150,
        config: config,
        onSave: (_, _, _) {},
      ),
    );

    await tester.pumpAndSettle();

    // With 15 segments and maxVisible = 7:
    // Right badge '+8' should be rendered because 15 - 7 = 8 segments remaining after visible window.
    expect(find.text('+8'), findsOneWidget);

    // Initial segment is Segment 1
    expect(find.text('Segment 1'), findsOneWidget);
  });

  testWidgets('SegmentedPagePicker does not show +N badge when segments <= 7', (WidgetTester tester) async {
    // 5 segments
    final List<PaginationSegment> segments = List.generate(
      5,
      (i) => PaginationSegment(
        startPhysical: i * 10 + 1,
        endPhysical: (i + 1) * 10,
        type: PageNumberingType.arabic,
        label: 'Block ${i + 1}',
      ),
    );

    final config = PaginationConfig(segments: segments, markers: []);

    await tester.pumpWidget(
      buildPickerWidget(
        totalPages: 50,
        config: config,
        onSave: (_, _, _) {},
      ),
    );

    await tester.pumpAndSettle();

    // No +N badge should be rendered when total segments <= 7
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('SegmentedPagePicker constrains very long segment titles with maxLines: 2', (WidgetTester tester) async {
    final List<PaginationSegment> segments = [
      PaginationSegment(
        startPhysical: 1,
        endPhysical: 100,
        type: PageNumberingType.arabic,
        label: 'Very Long Segment Title That Extends Further Than Normal Display Limits To Test Line Wrapping',
      ),
    ];

    final config = PaginationConfig(segments: segments, markers: []);

    await tester.pumpWidget(
      buildPickerWidget(
        totalPages: 100,
        config: config,
        onSave: (_, _, _) {},
      ),
    );

    await tester.pumpAndSettle();

    final textWidget = tester.widget<Text>(find.textContaining('Very Long Segment Title'));
    expect(textWidget.maxLines, equals(2));
    expect(textWidget.overflow, equals(TextOverflow.ellipsis));
  });
}
