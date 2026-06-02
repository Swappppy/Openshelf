import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/display_preferences_controller.dart';
import '../models/display_preferences.dart';
import '../l10n/l10n_extension.dart';
import 'display_settings_menu.dart';

class LibraryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool searchVisible;
  final VoidCallback onSearchToggle;

  const LibraryAppBar({
    super.key,
    required this.searchVisible,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final controller = ref.read(displayPreferencesProvider.notifier);

    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
        context.l10n.libraryTitle,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
        ),
      ),
      toolbarHeight: 64,
      actions: [
        BoxedIconButton(
          icon: searchVisible ? Icons.close : Icons.search,
          onPressed: onSearchToggle,
        ),
        const SizedBox(width: 8),
        BoxedIconButton(
          icon: viewMode == LibraryViewMode.list
              ? Icons.grid_view
              : Icons.view_list,
          onPressed: controller.toggleViewMode,
          isActive: false,
        ),
        const SizedBox(width: 8),
        BoxedIconButton(
          icon: Icons.settings_outlined,
          onPressed: () => DisplaySettingsMenu.show(context),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class BoxedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const BoxedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: isActive ? colorScheme.primary : colorScheme.onSurface,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
