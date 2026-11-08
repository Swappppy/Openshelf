import 'package:drift/drift.dart';
import '../database.dart';

part 'search_history_dao.g.dart';

@DriftAccessor(tables: [SearchHistory])
class SearchHistoryDao extends DatabaseAccessor<AppDatabase> with _$SearchHistoryDaoMixin {
  SearchHistoryDao(super.db);

  Stream<List<SearchHistoryData>> watchAllHistory() =>
      (select(searchHistory)..orderBy([(h) => OrderingTerm(expression: h.timestamp, mode: OrderingMode.desc)])).watch();

  Future<List<SearchHistoryData>> getAllHistory() =>
      (select(searchHistory)..orderBy([(h) => OrderingTerm(expression: h.timestamp, mode: OrderingMode.desc)])).get();

  Future<int> insertEntry(SearchHistoryCompanion entry) => into(searchHistory).insert(entry);

  Future<bool> updateEntry(SearchHistoryData entry) => update(searchHistory).replace(entry);

  Future<void> deleteEntry(int id) =>
      (delete(searchHistory)..where((h) => h.id.equals(id))).go();

  Future<void> clearHistory() => delete(searchHistory).go();
}
