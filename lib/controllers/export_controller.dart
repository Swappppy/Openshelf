import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/bookshelf_export_service.dart';
import '../services/goodreads_export_service.dart';
import '../services/data_migration_service.dart';
import '../l10n/l10n_extension.dart';
import 'database_provider.dart';

class ExportController {
  static Future<void> exportToNative(BuildContext context, WidgetRef ref, {required bool includeCovers}) async {
    final db = ref.read(databaseProvider);
    
    try {
      final migration = DataMigrationService(db);
      await migration.shareBackup(includeCovers: includeCovers);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    }
  }

  static Future<void> exportToBookshelf(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final exportService = BookshelfExportService(db);
      final result = await exportService.export();
      
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'bookshelf_export_${DateTime.now().millisecondsSinceEpoch}.csv'));
      await exportService.writeToFile(result, file);

      await Share.shareXFiles([XFile(file.path)], subject: 'Bookshelf Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    }
  }

  static Future<void> exportToGoodreads(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final exportService = GoodreadsExportService(db);
      final result = await exportService.export();
      
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'goodreads_export_${DateTime.now().millisecondsSinceEpoch}.csv'));
      await exportService.writeToFile(result, file);

      await Share.shareXFiles([XFile(file.path)], subject: 'Goodreads Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    }
  }
}
