import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../services/bookshelf_import_service.dart';
import '../services/goodreads_import_service.dart';
import '../services/data_migration_service.dart';
import '../l10n/l10n_extension.dart';
import 'database_provider.dart';
import 'app_settings_controller.dart';
import 'shelf_automation_controller.dart';
import 'books_controller.dart';

class ImportController {
  static void _refreshAllProviders(WidgetRef ref) {
    ref.invalidate(allBooksProvider);
    ref.invalidate(allShelvesProvider);
    ref.invalidate(allShelvesWithStatsProvider);
    ref.invalidate(allTagsProvider);
    ref.invalidate(allTagsWithCountsProvider);
    ref.invalidate(allImprintsProvider);
    ref.invalidate(allImprintsWithCountsProvider);
    ref.invalidate(allCollectionsProvider);
    ref.invalidate(allCollectionsWithCountsProvider);
    ref.invalidate(filteredBooksProvider);
    ref.read(shelfAutomationProvider.notifier).checkNoCoverShelf();
  }

  static Future<void> importNative(BuildContext context, WidgetRef ref, Function(bool, [String?]) setLoading) async {
    try {
      final backupResult = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'csv'],
        dialogTitle: context.l10n.settingsImportSelectBackup,
      );

      if (backupResult == null) return;
      if (!context.mounted) return;
      final backupFile = File(backupResult.files.single.path!);

      File? zipFile;
      if (p.extension(backupFile.path).toLowerCase() == '.csv') {
        if (!context.mounted) return;
        final restoreCovers = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.importRestoreCoversTitle),
            content: Text(context.l10n.importRestoreCoversPrompt),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.no)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.yes)),
            ],
          ),
        );

        if (restoreCovers == true) {
          if (!context.mounted) return;
          final zipResult = await FilePicker.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['zip'],
            dialogTitle: context.l10n.settingsImportSelectCovers,
          );
          if (zipResult != null) {
            zipFile = File(zipResult.files.single.path!);
          }
        }
      }

      if (!context.mounted) return;
      setLoading(true, context.l10n.loadingImport);
      final db = ref.read(databaseProvider);
      final migration = DataMigrationService(db);
      final count = await migration.importFromBackup(
        backupFile, 
        zipFile: zipFile,
        compress: ref.read(appSettingsProvider).compressImages,
      );

      _refreshAllProviders(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.importSuccess(count))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  static Future<void> importBookshelf(BuildContext context, WidgetRef ref, Function(bool, [String?]) setLoading) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return;

      if (!context.mounted) return;
      setLoading(true, context.l10n.loadingImport);
      final db = ref.read(databaseProvider);
      final file = File(result.files.single.path!);
      final importService = BookshelfImportService(db);
      final importResult = await importService.importFromFile(file);

      _refreshAllProviders(ref);

      if (context.mounted) {
        final message = importResult.skipped == 0
            ? context.l10n.importSuccess(importResult.imported)
            : context.l10n.importPartial(importResult.imported, importResult.skipped);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  static Future<void> importGoodreads(BuildContext context, WidgetRef ref, Function(bool, [String?]) setLoading) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return;

      if (!context.mounted) return;
      setLoading(true, context.l10n.loadingImport);
      final db = ref.read(databaseProvider);
      final file = File(result.files.single.path!);
      final importService = GoodreadsImportService(db);
      final importResult = await importService.importFromFile(file);

      _refreshAllProviders(ref);

      if (context.mounted) {
        final message = importResult.skipped == 0
            ? context.l10n.importSuccess(importResult.imported)
            : context.l10n.importPartial(importResult.imported, importResult.skipped);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
