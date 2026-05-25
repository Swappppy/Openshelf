import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import '../../../controllers/stats_controller.dart';
import '../../../controllers/reading_goals_controller.dart';
import '../../../controllers/database_provider.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../models/stats_widget.dart';
import '../../../widgets/cover_mosaic.dart';
import '../../../widgets/cover_stack_fade.dart';
import 'widget_header.dart';
import 'stats_scale_helper.dart';
import '../../../l10n/l10n_extension.dart';

class GoalTile extends ConsumerStatefulWidget {
  final StatWidgetConfig config;
  final StatWidgetSize size;
  const GoalTile({super.key, required this.config, required this.size});

  @override
  ConsumerState<GoalTile> createState() => _GoalTileState();
}

class _GoalTileState extends ConsumerState<GoalTile> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(allGoalsProvider);

    return goalsAsync.maybeWhen(
      data: (goals) {
        if (goals.isEmpty) return _buildEmptyState(context, ref);

        return LayoutBuilder(
          builder: (context, constraints) {
            final scale = StatsScaleHelper.getScale(constraints);
            
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final index = _pageController.page?.round() ?? 0;
                if (index < goals.length) {
                  showGoalConfig(context, ref, config: widget.config, existingGoal: goals[index]);
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progressAsync = ref.watch(goalProgressProvider(goal.id));

                  return progressAsync.maybeWhen(
                    data: (current) => _buildGoalContent(context, ref, goal, current, scale),
                    orElse: () => const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          }
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => showGoalConfig(context, ref, config: widget.config),
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
            const SizedBox(height: 4),
            Text(context.l10n.statsGoalNew, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalContent(BuildContext context, WidgetRef ref, ReadingGoal goal, int current, double scale) {
    final theme = Theme.of(context);
    final progress = (current / goal.targetValue).clamp(0.0, 1.0);
    final isPages = goal.type == 'pages';
    final isShelf = goal.type == 'shelf';
    final unit = isPages ? context.l10n.statsGoalUnitPages : context.l10n.statsGoalUnitBooks;

    Widget? covers;
    if (isShelf && goal.shelfId != null) {
      final shelfAsync = ref.watch(allShelvesProvider);
      final shelf = shelfAsync.maybeWhen(
        data: (list) => list.firstWhereOrNull((s) => s.id == goal.shelfId),
        orElse: () => null,
      );
      if (shelf != null) {
        final booksAsync = ref.watch(shelfBooksProvider(shelf));
        covers = booksAsync.maybeWhen(
          data: (books) => widget.size == StatWidgetSize.s1x1 
            ? CoverMosaic(books: books, width: double.infinity, height: double.infinity, borderRadius: 0)
            : CoverStackFade(
                books: books, 
                height: 26 * scale,
                maxBooks: 3,
              ),
          orElse: () => null,
        );
      }
    }

    if (widget.size == StatWidgetSize.s1x1) {
      return Stack(
        children: [
          if (covers != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: covers,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(12 * scale.clamp(1.0, 1.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHeader(
                  title: context.l10n.statsGoalTitle, 
                  icon: Icons.track_changes,
                  trailing: Material(
                    type: MaterialType.transparency,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.add, size: 14 * scale.clamp(1.0, 1.5)),
                      onPressed: () => showGoalConfig(context, ref, config: widget.config),
                    ),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11 * scale), maxLines: 1, overflow: TextOverflow.ellipsis),
                const Spacer(),
                SizedBox(
                  child: Text(
                    '${(progress * 100).toInt()}%', 
                    style: TextStyle(
                      color: theme.colorScheme.primary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 26 * scale,
                    ),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4 * scale),
                  child: LinearProgressIndicator(value: progress, minHeight: 4 * scale, backgroundColor: theme.colorScheme.surfaceContainerHighest),
                ),
                SizedBox(height: 4 * scale),
                Text('$current/${goal.targetValue}', style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
    }
    
    return Padding(
      padding: EdgeInsets.all(8 * scale.clamp(1.0, 1.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(
            title: context.l10n.statsGoalFullTitle, 
            icon: Icons.track_changes, 
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.add, size: 14 * scale.clamp(1.0, 1.2)),
                    onPressed: () => showGoalConfig(context, ref, config: widget.config),
                  ),
                ),
                SizedBox(width: 4 * scale),
                Text('${(progress * 100).toInt()}%', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11 * scale)),
              ],
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9 * scale), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${DateFormat('d MMM').format(goal.startDate)} — ${DateFormat('d MMM').format(goal.endDate)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 6.5 * scale)),
                  ],
                ),
              ),
              if (covers != null) ...[
                SizedBox(width: 4 * scale),
                SizedBox(
                  width: 55 * scale, // Restricted width to push it left-wards
                  height: 22 * scale, // Reduced from 26
                  child: Center(child: covers),
                ),
                SizedBox(width: 8 * scale), // Margin safety on the right
              ],
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * scale),
            child: LinearProgressIndicator(
              value: progress, 
              minHeight: 2.5 * scale, // Reduced from 3
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          // Removed SizedBox between bar and text to save final 2px
          Row(
            children: [
              Text('$current/${goal.targetValue} $unit', style: TextStyle(fontSize: 7 * scale, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (current < goal.targetValue)
                Text(context.l10n.statsGoalRemaining(goal.targetValue - current), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 6.5 * scale))
              else
                Text(context.l10n.statsGoalCompleted, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 6.5 * scale)),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showGoalConfig(BuildContext context, WidgetRef ref, {required StatWidgetConfig config, ReadingGoal? existingGoal}) async {
    final titleCtrl = TextEditingController(text: existingGoal?.title);
    final targetCtrl = TextEditingController(text: existingGoal?.targetValue.toString());
    String type = existingGoal?.type ?? 'books';
    int? selectedShelfId = existingGoal?.shelfId;
    DateTime start = existingGoal?.startDate ?? DateTime(DateTime.now().year, 1, 1);
    DateTime end = existingGoal?.endDate ?? DateTime(DateTime.now().year, 12, 31);

    final shelvesAsync = ref.read(databaseProvider).watchAllShelves().first;
    final shelves = await shelvesAsync;

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingGoal == null ? context.l10n.statsGoalNew : context.l10n.statsGoalEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: context.l10n.statsGoalNameLabel),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: context.l10n.statsGoalTypeLabel),
                  items: [
                    DropdownMenuItem(value: 'books', child: Text(context.l10n.statsGoalTypeBooks)),
                    DropdownMenuItem(value: 'pages', child: Text(context.l10n.statsGoalTypePages)),
                    DropdownMenuItem(value: 'shelf', child: Text(context.l10n.navShelves)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 16),
                if (type == 'shelf')
                  DropdownButtonFormField<int>(
                    initialValue: selectedShelfId,
                    decoration: InputDecoration(labelText: context.l10n.statsGoalTargetShelf),
                    items: shelves.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setDialogState(() => selectedShelfId = v),
                  )
                else
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: context.l10n.statsGoalTargetLabel),
                  ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.statsGoalFromLabel, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('d MMM yyyy').format(start)),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: start, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setDialogState(() => start = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.statsGoalToLabel, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('d MMM yyyy').format(end)),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: end, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setDialogState(() => end = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            if (existingGoal != null)
              TextButton(
                onPressed: () {
                  ref.read(readingGoalsControllerProvider.notifier).deleteGoal(existingGoal.id);
                  Navigator.pop(ctx);
                },
                child: Text(context.l10n.statsGoalDelete, style: const TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                if (type != 'shelf' && targetCtrl.text.isEmpty) return;
                if (type == 'shelf' && selectedShelfId == null) return;
                Navigator.pop(ctx, true);
              },
              child: Text(existingGoal == null ? context.l10n.create : context.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final db = ref.read(databaseProvider);
      
      int targetValue = type == 'shelf' ? 0 : int.parse(targetCtrl.text);
      if (type == 'shelf' && selectedShelfId != null) {
        final shelf = shelves.firstWhere((s) => s.id == selectedShelfId);
        final books = await db.watchBooksFiltered(
          query: shelf.filterQuery,
          author: shelf.filterAuthor,
          publisher: shelf.filterPublisher,
          isbn: shelf.filterIsbn,
          collectionIds: shelf.filterCollectionIds != null ? (jsonDecode(shelf.filterCollectionIds!) as List).cast<int>() : null,
          tagIds: shelf.filterTagIds != null ? (jsonDecode(shelf.filterTagIds!) as List).cast<int>() : null,
          imprintIds: shelf.filterImprintIds != null ? (jsonDecode(shelf.filterImprintIds!) as List).cast<int>() : null,
          noCover: shelf.filterNoCover,
        ).first;
        targetValue = books.length;
      }

      if (existingGoal == null) {
        final goalId = await db.insertGoal(ReadingGoalsCompanion.insert(
          title: titleCtrl.text,
          type: type,
          targetValue: targetValue,
          startDate: start,
          endDate: end,
          shelfId: Value(selectedShelfId),
        ));
        ref.read(statsControllerProvider.notifier).resizeWidget(config.id, StatWidgetSize.values.firstWhere((e) => e.name == config.size), goalId: goalId);
      } else {
        await db.updateGoal(existingGoal.copyWith(
          title: titleCtrl.text,
          type: type,
          targetValue: targetValue,
          startDate: start,
          endDate: end,
          shelfId: Value(selectedShelfId),
        ));
      }
    }
}
