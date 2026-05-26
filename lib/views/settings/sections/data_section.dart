import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/import_controller.dart';
import '../../../controllers/export_controller.dart';
import '../../../controllers/ui_tweaks_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../widgets/section_header.dart';

class DataSection extends ConsumerWidget {
  final void Function(bool, [String?]) onLoading;

  const DataSection({super.key, required this.onLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(l10n.settingsSectionData),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(l10n.dataManagementOpenShelf),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showServiceOptions(
                  context,
                  title: l10n.dataManagementOpenShelf,
                  importLabel: l10n.dataManagementRestoreBackup,
                  importHint: l10n.dataManagementRestoreBackupHint,
                  onImport: () => _handleNativeImport(context, ref),
                  exportLabel: l10n.dataManagementCreateBackup,
                  exportHint: l10n.dataManagementCreateBackupHint,
                  onExport: () => _handleNativeExport(context, ref),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(l10n.dataManagementBookshelf),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showServiceOptions(
                  context,
                  title: l10n.dataManagementBookshelf,
                  importLabel: l10n.dataManagementImport,
                  importHint: l10n.dataManagementImportHint(l10n.dataManagementBookshelf),
                  onImport: () => ImportController.importBookshelf(context, ref, onLoading),
                  exportLabel: l10n.dataManagementExport,
                  exportHint: l10n.dataManagementExportHint(l10n.dataManagementBookshelf),
                  onExport: () => ExportController.exportToBookshelf(context, ref, onLoading),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.dataManagementGoodreads),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showServiceOptions(
                  context,
                  title: l10n.dataManagementGoodreads,
                  importLabel: l10n.dataManagementImport,
                  importHint: l10n.dataManagementImportHint(l10n.dataManagementGoodreads),
                  onImport: () => ImportController.importGoodreads(context, ref, onLoading),
                  exportLabel: l10n.dataManagementExport,
                  exportHint: l10n.dataManagementExportHint(l10n.dataManagementGoodreads),
                  onExport: () => ExportController.exportToGoodreads(context, ref, onLoading),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined, color: Colors.red),
                title: Text(l10n.devDeleteAllBooks, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.settingsDevClearDbSub),
                onTap: () => _showDevDeleteConfirm(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showServiceOptions(
    BuildContext context, {
    required String title,
    required String importLabel,
    required String importHint,
    required VoidCallback onImport,
    required String exportLabel,
    required String exportHint,
    required VoidCallback onExport,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(importLabel),
              subtitle: Text(importHint),
              onTap: () {
                Navigator.pop(context);
                onImport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(exportLabel),
              subtitle: Text(exportHint),
              onTap: () {
                Navigator.pop(context);
                onExport();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDevDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.devDeleteConfirmTitle),
        content: Text(context.l10n.devDeleteConfirmContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await UiTweaksController.clearDatabase(ref);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.settingsDevDbCleared)),
                );
              }
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNativeExport(BuildContext context, WidgetRef ref) async {
    final includeCovers = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.exportTitle),
        content: Text(context.l10n.exportCoversPrompt),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.no)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.yes)),
        ],
      ),
    );
    if (includeCovers != null && context.mounted) {
      ExportController.exportToNative(context, ref, onLoading, includeCovers: includeCovers);
    }
  }

  Future<void> _handleNativeImport(BuildContext context, WidgetRef ref) async {
    ImportController.importNative(context, ref, onLoading);
  }
}
