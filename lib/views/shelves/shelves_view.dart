import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tag_type.dart';
import '../../controllers/database_provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/scrollable_selection_bar.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../controllers/fab_visibility_controller.dart';
import '../../widgets/add_entity_fab.dart';
import '../../widgets/shelves_section.dart';
import '../../widgets/categories_cloud.dart';
import '../../widgets/imprints_list.dart';
import '../../widgets/collections_list.dart';
import '../../widgets/shelf_form_sheet.dart';
import '../../widgets/tag_form_dialog.dart';
import '../../widgets/library_app_bar.dart';
import '../../controllers/search_filters_controller.dart';
import '../settings/settings_view.dart';

enum _ShelvesTab { shelves, categories, imprints, collections }

/// Redesigned screen for managing library organization with a thin tabbed layout.
class ShelvesScreen extends ConsumerStatefulWidget {
  const ShelvesScreen({super.key});

  @override
  ConsumerState<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends ConsumerState<ShelvesScreen> {
  late _ShelvesTab _activeTab;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final savedIndex = ref.read(searchFiltersProvider.notifier).getActiveShelvesTab();
    _activeTab = _ShelvesTab.values[savedIndex.clamp(0, _ShelvesTab.values.length - 1)];
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    ref.read(fabVisibilityProvider.notifier).handleScroll(_scrollController);
  }

  void _showCreateShelfDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ShelfFormSheet(
        onSave: (shelf) async {
          await ref.read(databaseProvider).insertShelf(shelf);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAddEntityDialog() {
    String title = '';
    TagType type = TagType.tag;

    switch (_activeTab) {
      case _ShelvesTab.categories:
        title = context.l10n.tagNewDialogTitle;
        type = TagType.tag;
        break;
      case _ShelvesTab.imprints:
        title = context.l10n.imprintNewDialogTitle;
        type = TagType.imprint;
        break;
      case _ShelvesTab.collections:
        title = context.l10n.managementCollections;
        type = TagType.collection;
        break;
      default: return;
    }

    showTagFormDialog(context, ref, title: title, type: type);
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final controller = ref.read(displayPreferencesProvider.notifier);
    final l10n = context.l10n;

    switch (_activeTab) {
      case _ShelvesTab.shelves:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.shelfSortOrder,
          directionsSelector: (p) => p.shelfSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalPages, 
            'progress': l10n.fieldReadingProgress,
          },
          onReorder: controller.reorderShelfSort,
          onToggleDirection: controller.toggleShelfSortDirection,
        );
        break;
      case _ShelvesTab.categories:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.categorySortOrder,
          directionsSelector: (p) => p.categorySortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'usage': l10n.managementCategoryCount,
            'color': l10n.tagColorLabel,
          },
          onReorder: controller.reorderCategorySort,
          onToggleDirection: controller.toggleCategorySortDirection,
          showNumericField: true,
          numericLabel: context.l10n.managementCategoryCloudCurve,
          numericValueSelector: (p) => p.tagCloudMaxCount,
          onNumericChanged: (val) => controller.setTagCloudMaxCount(val),
        );
        break;
      case _ShelvesTab.imprints:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.imprintSortOrder,
          directionsSelector: (p) => p.imprintSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalBooks,
          },
          onReorder: controller.reorderImprintSort,
          onToggleDirection: controller.toggleImprintSortDirection,
        );
        break;
      case _ShelvesTab.collections:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.collectionSortOrder,
          directionsSelector: (p) => p.collectionSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalBooks,
          },
          onReorder: controller.reorderCollectionSort,
          onToggleDirection: controller.toggleCollectionSortDirection,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFabVisible = ref.watch(fabVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.shelvesTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.white,
          ),
        ),
        toolbarHeight: 64,
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
        actions: [
          BoxedIconButton(
            icon: Icons.settings_outlined,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          ScrollableSelectionBar<_ShelvesTab>(
            items: [
              SelectionItem(value: _ShelvesTab.shelves, label: context.l10n.shelvesSectionMine, color: colorScheme.primary),
              SelectionItem(value: _ShelvesTab.categories, label: context.l10n.managementCategories, color: Colors.blue),
              SelectionItem(value: _ShelvesTab.imprints, label: context.l10n.managementImprints, color: Colors.deepPurple),
              SelectionItem(value: _ShelvesTab.collections, label: context.l10n.managementCollections, color: Colors.teal),
            ],
            selectedValue: _activeTab,
            onSelected: (tab) {
              setState(() => _activeTab = tab);
              ref.read(searchFiltersProvider.notifier).setActiveShelvesTab(tab.index);
            },
            onSortTap: () => _showSortOptions(context, ref),
          ),
          Expanded(
            child: _TabContent(
              activeTab: _activeTab,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
      floatingActionButton: AddEntityFab(
        visible: isFabVisible,
        onPressed: _activeTab == _ShelvesTab.shelves ? _showCreateShelfDialog : _showAddEntityDialog,
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final _ShelvesTab activeTab;
  final ScrollController scrollController;
  
  const _TabContent({
    required this.activeTab,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case _ShelvesTab.shelves: return ShelvesSection(scrollController: scrollController);
      case _ShelvesTab.categories: return CategoriesCloud(scrollController: scrollController);
      case _ShelvesTab.imprints: return ImprintsList(scrollController: scrollController);
      case _ShelvesTab.collections: return CollectionsList(scrollController: scrollController);
    }
  }
}
