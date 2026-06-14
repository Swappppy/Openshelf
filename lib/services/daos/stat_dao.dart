import 'package:drift/drift.dart';
import '../database.dart';

part 'stat_dao.g.dart';

@DriftAccessor(tables: [StatWidgetConfigs])
class StatDao extends DatabaseAccessor<AppDatabase> with _$StatDaoMixin {
  StatDao(super.db);

  Stream<List<StatWidgetConfig>> watchWidgetConfigs() =>
      (select(statWidgetConfigs)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  Stream<StatWidgetConfig?> watchWidgetConfig(int id) =>
      (select(statWidgetConfigs)..where((t) => t.id.equals(id))).watchSingleOrNull();
  Future<int> insertWidgetConfig(StatWidgetConfigsCompanion config) => into(statWidgetConfigs).insert(config);
  Future<bool> updateWidgetConfig(StatWidgetConfig config) => update(statWidgetConfigs).replace(config);
  Future<void> deleteWidgetConfig(int id) => (delete(statWidgetConfigs)..where((t) => t.id.equals(id))).go();
}
