import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../services/database.dart';
import '../models/stats_widget.dart';
import 'database_provider.dart';

final statsWidgetsProvider = StreamProvider<List<StatWidgetConfig>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWidgetConfigs().asyncMap((configs) async {
    if (configs.isEmpty) {
      // Initialize default layout if empty
      final defaults = [
        ('pages', 's1x1'),
        ('streak', 's1x1'),
        ('goal', 's2x1'),
        ('currentBook', 's2x1'),
        ('status', 's1x1'),
        ('addedOverTime', 's2x2'),
        ('categories', 's2x2'),
      ];
      
      for (int i = 0; i < defaults.length; i++) {
        await db.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
          type: defaults[i].$1,
          size: defaults[i].$2,
          sortOrder: i,
        ));
      }
      return db.watchWidgetConfigs().first;
    }
    return configs;
  });
});

class StatsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> addWidget(StatWidgetType type, StatWidgetSize size, {int? goalId}) async {
    final db = ref.read(databaseProvider);
    final current = await db.watchWidgetConfigs().first;
    await db.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
      type: type.name,
      size: size.name,
      sortOrder: current.length,
      goalId: Value(goalId),
    ));
  }

  Future<void> resizeWidget(int id, StatWidgetSize newSize, {int? goalId}) async {
    final db = ref.read(databaseProvider);
    final current = await db.watchWidgetConfigs().first;
    final widget = current.firstWhere((c) => c.id == id);
    await db.updateWidgetConfig(widget.copyWith(
      size: newSize.name,
      goalId: goalId != null ? Value(goalId) : widget.goalId == null ? const Value.absent() : Value(widget.goalId),
    ));
  }

  Future<void> removeWidget(int id) async {
    await ref.read(databaseProvider).deleteWidgetConfig(id);
  }

  Future<void> reorderWidgets(List<StatWidgetConfig> newOrder) async {
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      for (int i = 0; i < newOrder.length; i++) {
        await db.updateWidgetConfig(newOrder[i].copyWith(sortOrder: i));
      }
    });
  }
}

final statsControllerProvider = NotifierProvider<StatsController, void>(
  StatsController.new,
);
