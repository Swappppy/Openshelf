import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../controllers/app_settings_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../services/permission_service.dart';
import '../../../widgets/os_permission_dialog.dart';
import '../widgets/section_header.dart';

class StorageSection extends ConsumerWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coversPath = ref.watch(appSettingsProvider.select((s) => s.coversPath));
    final dbPath = ref.watch(appSettingsProvider.select((s) => s.dbPath));
    final controller = ref.read(appSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.settingsSectionStorage),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _PathTile(
                icon: Icons.image_outlined,
                label: context.l10n.settingsCoversFolder,
                path: coversPath,
                onTap: () async {
                  if (!await _checkAndRequestStorage(context)) return;
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  await _StorageMigrationHelper.migrateCovers(coversPath, result);
                  await controller.setCoversPath(result);
                },
              ),
              const Divider(height: 1, indent: 56),
              _PathTile(
                icon: Icons.storage_outlined,
                label: context.l10n.settingsDatabase,
                path: dbPath,
                onTap: () async {
                  if (!await _checkAndRequestStorage(context)) return;
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  if (context.mounted) {
                    _StorageMigrationHelper.showDbMoveWarning(context, ref, result);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? path;
  final VoidCallback onTap;

  const _PathTile({
    required this.icon,
    required this.label,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        path ?? context.l10n.settingsDefaultDir,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _StorageMigrationHelper {
  static Future<void> migrateCovers(String? oldPath, String newPath) async {
    final sourceDir = oldPath != null
        ? Directory(oldPath)
        : Directory(p.join(
        (await getApplicationDocumentsDirectory()).path, 'covers'));
    if (!await sourceDir.exists()) return;
    final destDir = Directory(newPath);
    if (!await destDir.exists()) await destDir.create(recursive: true);
    await for (final file in sourceDir.list()) {
      if (file is File) {
        final dest = File(p.join(newPath, p.basename(file.path)));
        await file.copy(dest.path);
        await file.delete();
      }
    }
  }

  static void showDbMoveWarning(
      BuildContext context, WidgetRef ref, String newPath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsDbMoveTitle),
        content: Text(context.l10n.settingsDbMoveContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await migrateDb(ref, newPath);
            },
            child: Text(context.l10n.settingsDbMoveConfirm),
          ),
        ],
      ),
    );
  }

  static Future<void> migrateDb(WidgetRef ref, String newPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final currentDb = File(p.join(appDir.path, 'openshelf_db.sqlite'));
    if (await currentDb.exists()) {
      final dest = File(p.join(newPath, 'openshelf_db.sqlite'));
      await currentDb.copy(dest.path);
      await currentDb.delete();
    }
    await ref.read(appSettingsProvider.notifier).setDbPath(newPath);
  }
}

Future<bool> _checkAndRequestStorage(BuildContext context) async {
  if (!await PermissionService.requestStorage()) {
    if (context.mounted) {
      await OsPermissionDialog.show(
        context,
        title: context.l10n.permissionRequired,
        content: context.l10n.storagePermissionExplanation,
      );
    }
    return false;
  }
  return true;
}
