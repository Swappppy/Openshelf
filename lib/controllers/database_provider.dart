import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';

/// Provider for the Drift singleton database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Clean up resources when the provider is destroyed.
  ref.onDispose(() => db.close());
  
  return db;
});
