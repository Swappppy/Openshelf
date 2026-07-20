import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';

final readHistoryProvider = StreamProvider.family<List<ReadHistoryData>, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.readHistoryDao.watchHistoryForBook(bookId);
});
