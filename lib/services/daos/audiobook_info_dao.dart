import 'package:drift/drift.dart';
import '../database.dart';

part 'audiobook_info_dao.g.dart';

@DriftAccessor(tables: [AudiobookInfo])
class AudiobookInfoDao extends DatabaseAccessor<AppDatabase> with _$AudiobookInfoDaoMixin {
  AudiobookInfoDao(super.db);

  Future<AudiobookInfoData?> getForBook(int bookId) =>
      (select(audiobookInfo)..where((a) => a.bookId.equals(bookId))).getSingleOrNull();

  Stream<AudiobookInfoData?> watchForBook(int bookId) =>
      (select(audiobookInfo)..where((a) => a.bookId.equals(bookId))).watchSingleOrNull();

  /// All rows keyed by book id (few rows; used by list views).
  Stream<Map<int, AudiobookInfoData>> watchAll() =>
      select(audiobookInfo).watch().map((rows) => {for (final r in rows) r.bookId: r});

  Future<void> upsert(AudiobookInfoCompanion entry) =>
      into(audiobookInfo).insertOnConflictUpdate(entry);

  /// Autocomplete sources, split on the same delimiters as authors and
  /// publishers (; / ,), so co-narrators are suggested individually.
  Future<List<String>> getDistinctNarrators(String query) => _distinct(audiobookInfo.narrator, query);
  Future<List<String>> getDistinctPlatforms(String query) => _distinct(audiobookInfo.platform, query);

  Future<List<String>> _distinct(GeneratedColumn<String> column, String query) async {
    final q = selectOnly(audiobookInfo, distinct: true)
      ..addColumns([column])
      ..where(column.isNotNull() & column.equals('').not());
    final qLower = query.toLowerCase();
    final results = <String>{};
    for (final row in await q.get()) {
      for (final part in (row.read(column) ?? '').split(RegExp(r'[;/,]'))) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && trimmed.toLowerCase().contains(qLower)) results.add(trimmed);
        if (results.length >= 20) return results.toList()..sort();
      }
    }
    return results.toList()..sort();
  }
}
