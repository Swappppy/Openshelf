import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/stats_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/models/stats_widget.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('StatsController Tests', () {
    test('addWidget adds a widget to the database', () async {
      final container = createContainer();
      final controller = container.read(statsControllerProvider.notifier);

      await controller.addWidget(StatWidgetType.readByYear, StatWidgetSize.s2x1);

      final widgets = await db.statDao.watchWidgetConfigs().first;
      expect(widgets.length, 1);
      expect(widgets.first.type, StatWidgetType.readByYear.name);
      expect(widgets.first.size, StatWidgetSize.s2x1.name);
    });

    test('removeWidget deletes a widget', () async {
      final container = createContainer();
      final controller = container.read(statsControllerProvider.notifier);

      await controller.addWidget(StatWidgetType.pages, StatWidgetSize.s1x1);
      final initialWidgets = await db.statDao.watchWidgetConfigs().first;
      expect(initialWidgets.length, 1);

      await controller.removeWidget(initialWidgets.first.id);
      final finalWidgets = await db.statDao.watchWidgetConfigs().first;
      expect(finalWidgets, isEmpty);
    });

    test('reorderWidgets updates sort orders', () async {
      final container = createContainer();
      final controller = container.read(statsControllerProvider.notifier);

      await controller.addWidget(StatWidgetType.readByYear, StatWidgetSize.s1x1);
      await controller.addWidget(StatWidgetType.pages, StatWidgetSize.s1x1);

      final widgets = await db.statDao.watchWidgetConfigs().first;
      expect(widgets[0].type, StatWidgetType.readByYear.name);
      expect(widgets[1].type, StatWidgetType.pages.name);

      await controller.reorderWidgets([widgets[1], widgets[0]]);

      final reordered = await db.statDao.watchWidgetConfigs().first;
      expect(reordered[0].type, StatWidgetType.pages.name);
      expect(reordered[1].type, StatWidgetType.readByYear.name);
    });
  });
}
