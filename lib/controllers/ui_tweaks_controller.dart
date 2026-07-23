import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
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
      
      // 2. Safely clear known media files
      final docDir = await CoverService.getCoverDirectory();
      
      if (await docDir.exists()) {
        // Delete imprints directory if it exists
        final imprintDir = Directory(p.join(docDir.path, 'imprints'));
        if (await imprintDir.exists()) {
          await imprintDir.delete(recursive: true).catchError((e) {
            debugPrint('ShelfAutomation: Error deleting imprints: $e');
            return imprintDir; // Return the entity to satisfy catchError type
          });
        }

        // List files asynchronously to avoid freezing the UI
        final entities = await docDir.list().toList();
        for (final entity in entities) {
          final fileName = p.basename(entity.path);
          
          // CRITICAL: Only delete files that match our naming patterns and ARE NOT the database
          // Pattern 1: Legacy covers (just timestamp.jpg)
          // Pattern 2: New covers (cover_timestamp.jpg)
          final isCover = entity is File && 
              fileName.endsWith('.jpg') && 
              (fileName.startsWith('cover_') || RegExp(r'^\d+\.jpg$').hasMatch(fileName));
          
          final isNotDatabase = !fileName.contains('openshelf_db.sqlite');

          if (isCover && isNotDatabase) {
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
