import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/models/stats_widget.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('StatDao Tests', () {
    test('insertWidgetConfig and watchWidgetConfigs', () async {
      await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.readingProgress.name,
        size: StatWidgetSize.medium.name,
        sortOrder: 0,
      ));

      final configs = await db.statDao.watchWidgetConfigs().first;
      expect(configs.length, 1);
      expect(configs.first.type, StatWidgetType.readingProgress.name);
    });

    test('updateWidgetConfig', () async {
      final id = await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.readingProgress.name,
        size: StatWidgetSize.small.name,
        sortOrder: 0,
      ));

      final config = await db.statDao.watchWidgetConfig(id).first;
      await db.statDao.updateWidgetConfig(config!.copyWith(size: StatWidgetSize.large.name));

      final updated = await db.statDao.watchWidgetConfig(id).first;
      expect(updated!.size, StatWidgetSize.large.name);
    });

    test('deleteWidgetConfig', () async {
      final id = await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.booksRead.name,
        size: StatWidgetSize.small.name,
        sortOrder: 1,
      ));

      expect((await db.statDao.watchWidgetConfigs().first).length, 1);
      await db.statDao.deleteWidgetConfig(id);
      expect((await db.statDao.watchWidgetConfigs().first).length, 0);
    });
  });
}
