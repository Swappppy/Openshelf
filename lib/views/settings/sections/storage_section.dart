import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../controllers/app_settings_controller.dart';
import '../../../controllers/database_provider.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../services/permission_service.dart';
import '../../../widgets/os_permission_dialog.dart';
import '../widgets/section_header.dart';

class StorageSection extends ConsumerStatefulWidget {
  const StorageSection({super.key});

  @override
  ConsumerState<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends ConsumerState<StorageSection> {
  bool _isManageGranted = true;
  bool _isAndroid11Plus = false;
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (!mounted) return;
    try {
      final granted = await PermissionService.isManageExternalStorageGranted();
      bool isAndroid11Plus = false;
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        isAndroid11Plus = info.version.sdkInt >= 30;
      }
      if (mounted) {
        setState(() {
          _isManageGranted = granted;
          _isAndroid11Plus = isAndroid11Plus;
        });
      }
    } catch (e) {
      debugPrint('StorageSection: Error checking permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh permission when widget is built to ensure it's up to date 
    // without needing an observer for now, as it might be causing crashes.
    // We can also trigger it manually after returning from settings.
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
                  if (_isMigrating) return;
                  if (!await _checkAndRequestStorage(context)) return;
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  
                  setState(() => _isMigrating = true);
                  try {
                    await _StorageMigrationHelper.migrateCovers(coversPath, result);
                    await controller.setCoversPath(result);
                  } finally {
                    if (mounted) setState(() => _isMigrating = false);
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _PathTile(
                icon: Icons.storage_outlined,
                label: context.l10n.settingsDatabase,
                path: dbPath,
                onTap: () async {
                  if (_isMigrating) return;
                  if (!await _checkAndRequestStorage(context)) return;
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  
                  if (context.mounted) {
                    _StorageMigrationHelper.showDbMoveWarning(context, ref, result, (migrating) {
                      if (mounted) setState(() => _isMigrating = migrating);
                    });
                  }
                },
              ),
              if (_isAndroid11Plus) ...[
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.folder_shared_outlined),
                  title: Text(context.l10n.settingsAllFilesAccess),
                  subtitle: Text(context.l10n.settingsAllFilesAccessSub),
                  trailing: Switch(
                    value: _isManageGranted,
                    onChanged: (value) => _handleToggle(value),
                  ),
                  onTap: () => _handleToggle(!_isManageGranted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleToggle(bool value) async {
    if (value && !_isManageGranted) {
      if (mounted) {
        await OsPermissionDialog.show(
          context,
          title: context.l10n.settingsAllFilesAccess,
          content: context.l10n.settingsAllFilesAccessInfo,
          onConfirm: () async {
            await PermissionService.requestManageExternalStorage();
          },
        );
        // Refresh after returning from settings
        await _checkPermission();
      }
    } else {
      await PermissionService.requestManageExternalStorage();
      await _checkPermission();
    }
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
      BuildContext context, WidgetRef ref, String newPath, Function(bool) onMigrating) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              onMigrating(true);
              await migrateDb(context, ref, newPath);
              onMigrating(false);
            },
            child: Text(context.l10n.settingsDbMoveConfirm),
          ),
        ],
      ),
    );
  }

  static Future<void> migrateDb(BuildContext context, WidgetRef ref, String newPath) async {
    try {
      debugPrint('StorageSection: Starting DB migration to $newPath');
      
      // 1. Verify destination is writable
      final testFile = File(p.join(newPath, '.write_test'));
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        debugPrint('StorageSection: Destination not writable: $e');
        final isAndroid11Plus = Platform.isAndroid && 
            (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 30;
        
        if (isAndroid11Plus) {
          final granted = await PermissionService.isManageExternalStorageGranted();
          if (!granted) {
            throw Exception('Selected directory is not writable. On Android 11+, you might need to enable "All Files Access" in Storage settings to use external folders.');
          }
        }
        throw Exception('Selected directory is not writable ($e). Try a different location.');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final currentDb = File(p.join(appDir.path, 'openshelf_db.sqlite'));
      
      final prefs = await SharedPreferences.getInstance();
      final oldCustomPath = prefs.getString('app_db_path');
      final sourceFile = oldCustomPath != null && oldCustomPath.isNotEmpty
          ? File(p.join(oldCustomPath, 'openshelf_db.sqlite'))
          : currentDb;

      debugPrint('StorageSection: Source DB: ${sourceFile.path}');
      final dest = File(p.join(newPath, 'openshelf_db.sqlite'));
      debugPrint('StorageSection: Destination DB: ${dest.path}');

      if (sourceFile.path == dest.path) {
        throw Exception('The database is already in the selected folder.');
      }

      if (!await sourceFile.exists()) {
        throw Exception('Source database file not found at ${sourceFile.path}');
      }

      // 2. IMPORTANT: Close connection before moving
      debugPrint('StorageSection: Closing database connection...');
      try {
        // Drift's close() can sometimes hang if there are active streams or transactions.
        // We give it a short timeout and proceed anyway as we are restarting the app soon.
        await ref.read(databaseProvider).close().timeout(const Duration(seconds: 2));
        debugPrint('StorageSection: Database connection closed successfully.');
      } catch (e) {
        debugPrint('StorageSection: Database close timed out or failed ($e). Proceeding with copy...');
      }
      
      // Give it a moment to release file handles
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 3. Perform copy
      debugPrint('StorageSection: Copying file...');
      await sourceFile.copy(dest.path);
      debugPrint('StorageSection: Main DB file copied.');
      
      // Also copy WAL and SHM files if they exist (common in Drift/SQLite on Android)
      await _copyOptionalFile('${sourceFile.path}-wal', '${dest.path}-wal');
      await _copyOptionalFile('${sourceFile.path}-shm', '${dest.path}-shm');
      
      // 4. Update settings
      debugPrint('StorageSection: Updating settings in SharedPreferences...');
      await ref.read(appSettingsProvider.notifier).setDbPath(newPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database moved successfully. Restarting app...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      debugPrint('StorageSection: Migration complete. Triggering restart...');
      // Wait for snackbar to be visible
      await Future.delayed(const Duration(seconds: 2));
      
      final activeIcon = ref.read(appSettingsProvider).activeIconName;
      await PermissionService.restartApp(activeIcon);
    } catch (e) {
      debugPrint('StorageSection: Migration error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static Future<void> _copyOptionalFile(String sourcePath, String destPath) async {
    final source = File(sourcePath);
    if (await source.exists()) {
      try {
        await source.copy(destPath);
        debugPrint('StorageSection: Copied optional file: $sourcePath');
      } catch (e) {
        debugPrint('StorageSection: Failed to copy optional file $sourcePath: $e');
      }
    }
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
