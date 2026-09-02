import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('StatDao Tests', () {
    test('insertWidgetConfig and watchWidgetConfigs', () async {
      await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.goal.name,
        size: StatWidgetSize.s2x1.name,
        sortOrder: 0,
      ));

      final configs = await db.statDao.watchWidgetConfigs().first;
      expect(configs.length, 1);
      expect(configs.first.type, StatWidgetType.goal.name);
    });

    test('updateWidgetConfig', () async {
      final id = await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.goal.name,
        size: StatWidgetSize.s1x1.name,
        sortOrder: 0,
      ));

      final config = await db.statDao.watchWidgetConfig(id).first;
      await db.statDao.updateWidgetConfig(config!.copyWith(size: StatWidgetSize.s2x2.name));

      final updated = await db.statDao.watchWidgetConfig(id).first;
      expect(updated!.size, StatWidgetSize.s2x2.name);
    });

    test('deleteWidgetConfig', () async {
      final id = await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: StatWidgetType.readByYear.name,
        size: StatWidgetSize.s1x1.name,
        sortOrder: 1,
      ));

      expect((await db.statDao.watchWidgetConfigs().first).length, 1);
      await db.statDao.deleteWidgetConfig(id);
      expect((await db.statDao.watchWidgetConfigs().first).length, 0);
    });
  });
}
