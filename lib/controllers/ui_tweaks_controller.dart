import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/cover_service.dart';
import 'database_provider.dart';
import 'shelf_automation_controller.dart';

/// Controller for maintenance and specific UI-triggered logic (non-persistence).
class UiTweaksController {
  static Future<int> optimizeImages(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    return await CoverService.batchCompressAll(db);
  }

  static Future<void> clearDatabase(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      
      // 1. Clear database tables first (ensures UI reflects emptiness quickly)
      await db.clearAllData();
      
      // 2. Safely clear known media files (covers may live in a custom folder)
      final docDir = await getApplicationDocumentsDirectory();
      final coverDir = await CoverService.getCoverDirectory();

      if (await docDir.exists()) {
        // Delete imprints directory if it exists
        final imprintDir = Directory(p.join(docDir.path, 'imprints'));
        if (await imprintDir.exists()) {
          await imprintDir.delete(recursive: true).catchError((e) {
            debugPrint('ShelfAutomation: Error deleting imprints: $e');
            return imprintDir; // Return the entity to satisfy catchError type
          });
        }
      }
      // Only delete files whose names match what CoverService creates, so a
      // user-chosen covers folder never loses unrelated files.
      for (final dir in {docDir.path, coverDir.path}) {
        final d = Directory(dir);
        if (!await d.exists()) continue;
        for (final entity in await d.list().toList()) {
          if (entity is File && CoverService.managedCoverName.hasMatch(p.basename(entity.path))) {
            await entity.delete().catchError((e) => entity);
          }
        }
      }
    } catch (e, stack) {
      debugPrint('ShelfAutomation: Error during clearDatabase: $e\n$stack');
    } finally {
      // 3. Always refresh automation to ensure "No cover" shelf is removed/hidden
      await ref.read(shelfAutomationProvider.notifier).checkNoCoverShelf();
      debugPrint('ShelfAutomation: Database cleared and automation refreshed.');
    }
  }
}
