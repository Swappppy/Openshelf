import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';

final ownershipLogProvider = StreamProvider.family<List<OwnershipLogData>, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.ownershipDao.watchLogForBook(bookId);
});
