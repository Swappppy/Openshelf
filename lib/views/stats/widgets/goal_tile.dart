import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../controllers/stats_controller.dart';
import '../../../controllers/reading_goals_controller.dart';
import '../../../controllers/database_provider.dart';
import '../../../services/database.dart';
import '../../../models/stats_widget.dart';
import 'widget_header.dart';

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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text('Nueva meta', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalContent(BuildContext context, WidgetRef ref, ReadingGoal goal, int current) {
    final theme = Theme.of(context);
    final progress = (current / goal.targetValue).clamp(0.0, 1.0);
    final isPages = goal.type == 'pages';
    final unit = isPages ? 'págs' : 'libros';

    if (widget.size == StatWidgetSize.s1x1) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetHeader(
              title: 'META', 
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
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 22)),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: theme.colorScheme.surfaceContainerHighest),
            ),
            const SizedBox(height: 4),
            Text('$current/${goal.targetValue}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(
            title: 'META DE LECTURA', 
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
          const SizedBox(height: 4),
          Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${DateFormat('d MMM').format(goal.startDate)} — ${DateFormat('d MMM').format(goal.endDate)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 9)),
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
                Text('Faltan ${goal.targetValue - current}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 9))
              else
                const Text('¡Listo! 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
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
          title: Text(existingGoal == null ? 'Nueva meta' : 'Editar meta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre (ej: Reto 2026)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'books', child: Text('Libros leídos')),
                    DropdownMenuItem(value: 'pages', child: Text('Páginas leídas')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Objetivo numérico'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Desde', style: TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('d MMM yyyy').format(start)),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: start, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) setDialogState(() => start = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hasta', style: TextStyle(fontSize: 14)),
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
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || targetCtrl.text.isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: Text(existingGoal == null ? 'Crear' : 'Guardar'),
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
