import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/bookshelf_export_service.dart';
import '../services/goodreads_export_service.dart';
import '../services/librarything_export_service.dart';
import '../services/data_migration_service.dart';
import '../l10n/l10n_extension.dart';
import 'database_provider.dart';

class ExportController {
  static Future<void> exportToNative(
    BuildContext context, 
    WidgetRef ref, 
    void Function(bool, [String?]) onLoading,
    {required bool includeCovers}
  ) async {
    final db = ref.read(databaseProvider);
    final l10n = context.l10n;
    try {
      onLoading(true, l10n.loadingExport);
      final migration = DataMigrationService(db);
      await migration.shareBackup(
        includeCovers: includeCovers,
        onProgress: (step) {
          final msg = switch (step) {
            'data' => l10n.exportProgressData,
            'media' => l10n.exportProgressMedia,
            'compress' => l10n.exportProgressCompress,
            'finalize' => l10n.exportProgressFinalize,
            _ => l10n.loadingExport,
          };
          onLoading(true, msg);
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      onLoading(false);
    }
  }

  static Future<void> exportToBookshelf(
    BuildContext context, 
    WidgetRef ref,
    void Function(bool, [String?]) onLoading,
  ) async {
    final db = ref.read(databaseProvider);
    try {
      onLoading(true, 'Exporting to Bookshelf...');
      final exportService = BookshelfExportService(db);
      final result = await exportService.export();
      
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'bookshelf_export_${DateTime.now().millisecondsSinceEpoch}.csv'));
      await exportService.writeToFile(result, file);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], subject: 'Bookshelf Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      onLoading(false);
    }
  }

  static Future<void> exportToGoodreads(
    BuildContext context, 
    WidgetRef ref,
    void Function(bool, [String?]) onLoading,
  ) async {
    final db = ref.read(databaseProvider);
    try {
      onLoading(true, 'Exporting to Goodreads...');
      final exportService = GoodreadsExportService(db);
      final result = await exportService.export();
      
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'goodreads_export_${DateTime.now().millisecondsSinceEpoch}.csv'));
      await exportService.writeToFile(result, file);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], subject: 'Goodreads Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      onLoading(false);
    }
  }

  static Future<void> exportToLibraryThing(
    BuildContext context, 
    WidgetRef ref,
    void Function(bool, [String?]) onLoading,
  ) async {
    final db = ref.read(databaseProvider);
    try {
      onLoading(true, 'Exporting to LibraryThing...');
      final exportService = LibrarythingExportService(db);
      final result = await exportService.export();
      
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'librarything_export_${DateTime.now().millisecondsSinceEpoch}.json'));
      await exportService.writeToFile(result, file);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], subject: 'LibraryThing Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      onLoading(false);
    }
  }
}
