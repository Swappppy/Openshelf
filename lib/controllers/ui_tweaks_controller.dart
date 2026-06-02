import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cover_service.dart';
import 'database_provider.dart';

/// Controller for maintenance and specific UI-triggered logic (non-persistence).
class UiTweaksController {
  static Future<int> optimizeImages(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    return await CoverService.batchCompressAll(db);
  }

  static Future<void> clearDatabase(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.clearAllData();
    // Also clear covers directory
    final dir = await CoverService.getCoverDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }
}
