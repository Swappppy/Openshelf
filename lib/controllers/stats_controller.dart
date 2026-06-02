import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../services/database.dart';
import '../models/stats_widget.dart';
import 'database_provider.dart';

final statsWidgetsProvider = StreamProvider<List<StatWidgetConfig>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.statDao.watchWidgetConfigs();
});

class StatsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> addWidget(StatWidgetType type, StatWidgetSize size, {int? goalId}) async {
    final db = ref.read(databaseProvider);
    final current = await db.statDao.watchWidgetConfigs().first;
    await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
      type: type.name,
      size: size.name,
      sortOrder: current.length,
      goalId: Value(goalId),
    ));
  }

  Future<void> resizeWidget(int id, StatWidgetSize newSize, {int? goalId}) async {
    final db = ref.read(databaseProvider);
    final current = await db.statDao.watchWidgetConfigs().first;
    final widget = current.firstWhere((c) => c.id == id);
    await db.statDao.updateWidgetConfig(widget.copyWith(
      size: newSize.name,
      goalId: goalId != null ? Value(goalId) : widget.goalId == null ? const Value.absent() : Value(widget.goalId),
    ));
  }

  Future<void> removeWidget(int id) async {
    await ref.read(databaseProvider).statDao.deleteWidgetConfig(id);
  }

  Future<void> reorderWidgets(List<StatWidgetConfig> newOrder) async {
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      for (int i = 0; i < newOrder.length; i++) {
        await db.statDao.updateWidgetConfig(newOrder[i].copyWith(sortOrder: i));
      }
    });
  }

  Future<void> updateWidgetConfig(StatWidgetConfig config) async {
    await ref.read(databaseProvider).statDao.updateWidgetConfig(config);
  }
}

final statsControllerProvider = NotifierProvider<StatsController, void>(
  StatsController.new,
);
