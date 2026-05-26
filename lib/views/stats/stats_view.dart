import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_staggered_grid_view/reorderable_staggered_grid_view.dart';
import 'package:collection/collection.dart';
import '../../controllers/stats_controller.dart';
import '../../controllers/fab_visibility_controller.dart';
import '../../services/database.dart';
import '../../models/stats_widget.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/add_entity_fab.dart';
import 'widgets/pages_tile.dart';
import 'widgets/streak_tile.dart';
import 'widgets/status_tile.dart';
import 'widgets/current_book_tile.dart';
import 'widgets/goal_tile.dart';
import 'widgets/chart_tiles.dart';
import 'widgets/last_added_tile.dart';
import 'widgets/avg_pages_tile.dart';
import 'widgets/read_list_tile.dart';
import 'widgets/avg_completion_tile.dart';

class StatsView extends ConsumerStatefulWidget {
  const StatsView({super.key});

  @override
  ConsumerState<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends ConsumerState<StatsView> {
  bool _isEditing = false;
  List<StatWidgetConfig> _localConfigs = [];
  final Map<int, GlobalKey> _animationKeys = {};
  bool _initialized = false;

  GlobalKey _animationKey(int id) =>
      _animationKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Sincroniza desde DB solo en la primera carga o si no estamos editando
  void _syncFromDb(List<StatWidgetConfig> configs) {
    if (!_initialized || !_isEditing) {
      _localConfigs = List.from(configs);
      _initialized = true;
    }
  }

  void _handleResize(StatWidgetConfig config, StatWidgetSize newSize) {
    setState(() {
      final idx = _localConfigs.indexWhere((c) => c.id == config.id);
      if (idx == -1) return;
      _localConfigs[idx] = config.copyWith(size: newSize.name);
    });
    ref.read(statsControllerProvider.notifier).resizeWidget(config.id, newSize);
  }

  void _handleRemove(int id) {
    setState(() {
      _localConfigs.removeWhere((c) => c.id == id);
      _animationKeys.remove(id);
    });
    ref.read(statsControllerProvider.notifier).removeWidget(id);
  }

  @override
  Widget build(BuildContext context) {
    final widgetsAsync = ref.watch(statsWidgetsProvider);
    final isFabVisible = ref.watch(fabVisibilityProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.navStats,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        toolbarHeight: 64,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
        data: (configs) {
          _syncFromDb(configs);

          if (_localConfigs.isEmpty && !_isEditing) {
            return _buildEmptyState();
          }
          return _buildGrid();
        },
      ),
      floatingActionButton: _isEditing
          ? null
          : AddEntityFab(
        onPressed: _showAddWidgetSheet,
        visible: isFabVisible,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(context.l10n.statsPlaceholder),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddWidgetSheet,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.statsAddFirstWidget),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    // Generate a key based on sizes but independent of order.
    // This allows smooth reordering but forces a rebuild when resizing.
    final sizesKey = _localConfigs.map((c) => "${c.id}:${c.size}").toList()..sort();
    final gridKey = ValueKey(sizesKey.join(','));

    final gridItems = _localConfigs.map((c) {
      final size = StatWidgetSize.values
          .firstWhereOrNull((e) => e.name == c.size) ??
          StatWidgetSize.s1x1;

      int cross = 1, main = 1;
      switch (size) {
        case StatWidgetSize.s1x1: cross = 1; main = 1; break;
        case StatWidgetSize.s2x1: cross = 2; main = 1; break;
        case StatWidgetSize.s1x2: cross = 1; main = 2; break;
        case StatWidgetSize.s2x2: cross = 2; main = 2; break;
      }

      return ReorderableStaggeredGridViewItem<StatWidgetConfig>(
        data: c,
        animationKey: _animationKey(c.id),
        crossAxisCellCount: cross,
        mainAxisCellCount: main,
        child: GestureDetector(
          onLongPressStart: (_) {
            if (_isEditing) HapticFeedback.mediumImpact();
          },
          child: _StatTile(
            config: c,
            isEditing: _isEditing,
            onRemove: () => _handleRemove(c.id),
            onResize: (newSize) => _handleResize(c, newSize),
          ),
        ),
      );
    }).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        ref.read(fabVisibilityProvider.notifier).handleScrollNotification(notification);
        return false;
      },
      child: ReorderableStaggeredGridView(
        key: gridKey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        enable: _isEditing,
        isLongPressDraggable: true,
        onAcceptWithDetails: (details, index) {
          // Library handles visual move, we handle DB persistence
          final dragged = details.data as StatWidgetConfig;
          final List<StatWidgetConfig> newList = List.from(_localConfigs);
          final oldIdx = newList.indexWhere((c) => c.id == dragged.id);
          if (oldIdx != -1) {
            newList.removeAt(oldIdx);
            newList.insert(index.clamp(0, newList.length), dragged);
            _localConfigs = newList; // Immediate local update
            ref.read(statsControllerProvider.notifier).reorderWidgets(newList);
          }
        },
        items: gridItems,
      ),
    );
  }

  void _showAddWidgetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddWidgetSheet(),
    );
  }
}

class _StatTile extends ConsumerWidget {
  final StatWidgetConfig config;
  final bool isEditing;
  final VoidCallback onRemove;
  final Function(StatWidgetSize) onResize;

  const _StatTile({
    required this.config,
    required this.isEditing,
    required this.onRemove,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = StatWidgetType.values.firstWhereOrNull((e) => e.name == config.type) ?? StatWidgetType.pages;
    final size = StatWidgetSize.values.firstWhereOrNull((e) => e.name == config.size) ?? StatWidgetSize.s1x1;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEditing ? Colors.grey[800]! : Colors.transparent,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildContent(context, type, size, config),
        ),
        if (isEditing) ...[
          Positioned(
            top: -4,
            right: -4,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
              onPressed: onRemove,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildResizeButton(context, type, size),
          ),
        ],
      ],
    );
  }

  Widget _buildResizeButton(BuildContext context, StatWidgetType type, StatWidgetSize current) {
    final available = _getAvailableSizes(type);
    if (available.length <= 1) return const SizedBox.shrink();

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.aspect_ratio, size: 16),
      ),
      onPressed: () {
        final idx = available.indexOf(current);
        final next = available[(idx + 1) % available.length];
        onResize(next);
      },
    );
  }

  List<StatWidgetSize> _getAvailableSizes(StatWidgetType type) {
    switch (type) {
      case StatWidgetType.pages:
      case StatWidgetType.streak:
      case StatWidgetType.status:
        return [StatWidgetSize.s1x1];
      case StatWidgetType.goal:
      case StatWidgetType.currentBook:
        return [StatWidgetSize.s2x1, StatWidgetSize.s1x1];
      case StatWidgetType.addedOverTime:
        return [StatWidgetSize.s2x2, StatWidgetSize.s2x1, StatWidgetSize.s1x1];
      case StatWidgetType.readByYear:
        return [StatWidgetSize.s2x2, StatWidgetSize.s2x1, StatWidgetSize.s1x2];
      case StatWidgetType.categories:
      case StatWidgetType.collections:
        return [StatWidgetSize.s2x2, StatWidgetSize.s1x2];
      case StatWidgetType.publishYear:
        return [StatWidgetSize.s2x2, StatWidgetSize.s2x1, StatWidgetSize.s1x2];
      case StatWidgetType.readList:
        return [StatWidgetSize.s2x2, StatWidgetSize.s1x2];
      case StatWidgetType.lastAdded:
        return [StatWidgetSize.s2x1, StatWidgetSize.s1x2, StatWidgetSize.s1x1];
      case StatWidgetType.avgPages:
      case StatWidgetType.avgCompletionTime:
        return [StatWidgetSize.s1x1];
    }
  }

  Widget _buildContent(BuildContext context, StatWidgetType type, StatWidgetSize size, StatWidgetConfig config) {
    switch (type) {
      case StatWidgetType.pages: return const PagesTile();
      case StatWidgetType.streak: return const StreakTile();
      case StatWidgetType.status: return const StatusDistributionTile();
      case StatWidgetType.currentBook: return CurrentBookTile(size: size);
      case StatWidgetType.addedOverTime: return AddedOverTimeTile(size: size);
      case StatWidgetType.categories: return CategoriesDistributionTile(size: size);
      case StatWidgetType.publishYear: return PublishYearTile(size: size);
      case StatWidgetType.goal: return GoalTile(config: config, size: size);
      case StatWidgetType.readByYear: return ReadByYearTile(size: size);
      case StatWidgetType.collections: return CollectionsDistributionTile(size: size);
      case StatWidgetType.lastAdded: return LastAddedTile(size: size);
      case StatWidgetType.avgPages: return const AvgPagesTile();
      case StatWidgetType.readList: return ReadListTile(config: config, size: size);
      case StatWidgetType.avgCompletionTime: return const AvgCompletionTimeTile();
    }
  }
}

class _AddWidgetSheet extends ConsumerWidget {
  const _AddWidgetSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(context.l10n.statsAddWidgetTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildOption(context, ref, StatWidgetType.pages, context.l10n.statsOptPagesTitle, context.l10n.statsOptPagesSub, Icons.menu_book, StatWidgetSize.s1x1),
              _buildOption(context, ref, StatWidgetType.streak, context.l10n.statsOptStreakTitle, context.l10n.statsOptStreakSub, Icons.local_fire_department, StatWidgetSize.s1x1),
              _buildOption(context, ref, StatWidgetType.goal, context.l10n.statsOptGoalTitle, context.l10n.statsOptGoalSub, Icons.track_changes, StatWidgetSize.s2x1),
              _buildOption(context, ref, StatWidgetType.status, context.l10n.statsOptStatusTitle, context.l10n.statsOptStatusSub, Icons.pie_chart_outline, StatWidgetSize.s1x1),
              _buildOption(context, ref, StatWidgetType.currentBook, context.l10n.statsOptCurrentTitle, context.l10n.statsOptCurrentSub, Icons.auto_stories, StatWidgetSize.s2x1),
              _buildOption(context, ref, StatWidgetType.addedOverTime, context.l10n.statsOptAddedTimeTitle, context.l10n.statsOptAddedTimeSub, Icons.timeline, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.categories, context.l10n.statsOptCategoriesTitle, context.l10n.statsOptCategoriesSub, Icons.bar_chart, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.publishYear, context.l10n.statsOptYearsTitle, context.l10n.statsOptYearsSub, Icons.history, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.readByYear, context.l10n.statsOptReadYearTitle, context.l10n.statsOptReadYearSub, Icons.bar_chart, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.collections, context.l10n.statsOptCollectionsTitle, context.l10n.statsOptCollectionsSub, Icons.collections_bookmark, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.lastAdded, context.l10n.statsOptLastAddedTitle, context.l10n.statsOptLastAddedSub, Icons.history, StatWidgetSize.s2x1),
              _buildOption(context, ref, StatWidgetType.avgPages, context.l10n.statsOptAvgPagesTitle, context.l10n.statsOptAvgPagesSub, Icons.analytics, StatWidgetSize.s1x1),
              _buildOption(context, ref, StatWidgetType.readList, context.l10n.statsOptReadListTitle, context.l10n.statsOptReadListSub, Icons.checklist_rtl, StatWidgetSize.s2x2),
              _buildOption(context, ref, StatWidgetType.avgCompletionTime, context.l10n.statsOptAvgCompletionTitle, context.l10n.statsOptAvgCompletionSub, Icons.timer_outlined, StatWidgetSize.s1x1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, WidgetRef ref, StatWidgetType type, String title, String sub, IconData icon, StatWidgetSize size) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(sub),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: Text(size == StatWidgetSize.s1x1 ? '½' : (size == StatWidgetSize.s2x2 ? '▢' : '—'), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ),
      onTap: () async {
        await ref.read(statsControllerProvider.notifier).addWidget(type, size);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}
