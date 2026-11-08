import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../services/daos/search_history_dao.dart';

/// Provider for the Drift singleton database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Clean up resources when the provider is destroyed.
  ref.onDispose(() => db.close());
  
  return db;
});

final searchHistoryDaoProvider = Provider<SearchHistoryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SearchHistoryDao(db);
});

