import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/book_selection_controller.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import '../views/book_form/bulk_edit_view.dart';
import 'library_app_bar.dart';

/// Contextual Top App Bar displayed when books are selected in multi-select mode.
class SelectionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final List<int> visibleBookIds;

  const SelectionAppBar({
    super.key,
    required this.visibleBookIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(bookSelectionProvider);
    final selectionController = ref.read(bookSelectionProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final isAllSelected = visibleBookIds.isNotEmpty &&
        visibleBookIds.every((id) => selectedIds.contains(id));

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surfaceContainerHighest,
      leading: BoxedIconButton(
        icon: Icons.close,
        onPressed: () => selectionController.clear(),
      ),
      title: Text(
        l10n.bulkSelectionCount(selectedIds.length),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      toolbarHeight: 64,
      actions: [
        // Select All / Deselect All
        BoxedIconButton(
          icon: isAllSelected ? Icons.deselect : Icons.select_all,
          onPressed: () {
            selectionController.toggleAll(visibleBookIds);
          },
        ),
        const SizedBox(width: 8),

        // Bulk Edit Action
        BoxedIconButton(
          icon: Icons.edit_outlined,
          onPressed: () {
            if (selectedIds.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BulkEditView(selectedBookIds: selectedIds.toList()),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Bulk Duplicate Action
        BoxedIconButton(
          icon: Icons.copy,
          onPressed: () async {
            if (selectedIds.isEmpty) return;
            final count = selectedIds.length;
            final messenger = ScaffoldMessenger.of(context);
            
            await ref.read(databaseProvider).bookDao.bulkDuplicateBooks(selectedIds.toList());
            selectionController.clear();
            
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.bulkDuplicateSuccess(count))),
            );
          },
        ),
        const SizedBox(width: 8),

        // Bulk Delete Action
        BoxedIconButton(
          icon: Icons.delete_outline,
          onPressed: () => _confirmBulkDelete(context, ref, selectedIds.toList()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Future<void> _confirmBulkDelete(BuildContext context, WidgetRef ref, List<int> bookIds) async {
    if (bookIds.isEmpty) return;
    final l10n = context.l10n;
    final count = bookIds.length;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bulkDeleteTitle),
        content: Text(l10n.bulkDeleteConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(databaseProvider).bookDao.bulkDeleteBooks(bookIds);
      ref.read(bookSelectionProvider.notifier).clear();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bulkDeleteSuccess(count))),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
