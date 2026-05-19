import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../controllers/stats_controller.dart';
import '../../../controllers/reading_goals_controller.dart';
import '../../../controllers/database_provider.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../models/stats_widget.dart';
import '../../../widgets/cover_mosaic.dart';
import '../../../widgets/cover_stack_fade.dart';
import 'widget_header.dart';
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

        return PageView.builder(
          controller: _pageController,
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final progressAsync = ref.watch(goalProgressProvider(goal.id));

            return InkWell(
              onTap: () => showGoalConfig(context, ref, config: widget.config, existingGoal: goal),
              borderRadius: BorderRadius.circular(20),
              child: progressAsync.maybeWhen(
                data: (current) => _buildGoalContent(context, ref, goal, current),
                orElse: () => const Center(child: CircularProgressIndicator()),
              ),
            );
          },
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

  Widget _buildGoalContent(BuildContext context, WidgetRef ref, ReadingGoal goal, int current) {
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
                height: 52,
                maxBooks: 5,
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHeader(
                  title: context.l10n.statsGoalTitle, 
                  icon: Icons.track_changes,
                  trailing: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: () => showGoalConfig(context, ref, config: widget.config),
                  ),
                ),
                const SizedBox(height: 4),
                Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const Spacer(),
                SizedBox(
                  child: Text(
                    '${(progress * 100).toInt()}%', 
                    style: TextStyle(
                      color: theme.colorScheme.primary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 26,
                    ),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: theme.colorScheme.surfaceContainerHighest),
                ),
                const SizedBox(height: 4),
                Text('$current/${goal.targetValue}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(
            title: context.l10n.statsGoalFullTitle, 
            icon: Icons.track_changes, 
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add, size: 14),
                  onPressed: () => showGoalConfig(context, ref, config: widget.config),
                ),
                const SizedBox(width: 8),
                Text('${(progress * 100).toInt()}%', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${DateFormat('d MMM').format(goal.startDate)} — ${DateFormat('d MMM').format(goal.endDate)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (covers != null) ...[
                const SizedBox(width: 12),
                covers,
              ],
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress, 
              minHeight: 5, 
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('$current/${goal.targetValue} $unit', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (current < goal.targetValue)
                Text(context.l10n.statsGoalRemaining(goal.targetValue - current), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 9))
              else
                Text(context.l10n.statsGoalCompleted, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
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
    DateTime start = existingGoal?.startDate ?? DateTime(DateTime.now().year, 1, 1);
    DateTime end = existingGoal?.endDate ?? DateTime(DateTime.now().year, 12, 31);

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
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 16),
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
                if (titleCtrl.text.isEmpty || targetCtrl.text.isEmpty) return;
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
      if (existingGoal == null) {
        final goalId = await db.insertGoal(ReadingGoalsCompanion.insert(
          title: titleCtrl.text,
          type: type,
          targetValue: int.parse(targetCtrl.text),
          startDate: start,
          endDate: end,
        ));
        ref.read(statsControllerProvider.notifier).resizeWidget(config.id, StatWidgetSize.values.firstWhere((e) => e.name == config.size), goalId: goalId);
      } else {
        await db.updateGoal(existingGoal.copyWith(
          title: titleCtrl.text,
          type: type,
          targetValue: int.parse(targetCtrl.text),
          startDate: start,
          endDate: end,
        ));
      }
    }
  }
