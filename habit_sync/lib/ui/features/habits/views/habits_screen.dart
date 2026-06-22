import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/ui/core/widgets/habit_card.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';
import 'package:habit_sync/ui/features/habits/views/add_habit_sheet.dart';
import 'package:go_router/go_router.dart';

/// Screen listing all habits with management capabilities.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitRepository>(
      builder: (context, repo, _) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'My Habits',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showAddHabit(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Stats summary ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.format_list_bulleted_rounded,
                      label: 'Total',
                      value: '${repo.totalHabitsCount}',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.check_circle_rounded,
                      label: 'Done Today',
                      value: '${repo.totalCompletedToday}',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Best Streak',
                      value: '${repo.overallCurrentStreak}',
                      color: const Color(0xFFFFB74D),
                    ),
                  ],
                ),
              ),
            ),

            // ── Habit list ──────────────────────────────────────────
            if (repo.habits.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_task_rounded,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No habits yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to create one',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = repo.habits[index];
                    return HabitCard(
                      habit: habit,
                      onToggle: () {
                        repo.toggleHabitCompletion(habit.id, DateTime.now());
                      },
                      onTap: () {
                        context.push('/habit/${habit.id}');
                      },
                      onDelete: () {
                        repo.deleteHabit(habit.id);
                      },
                    );
                  },
                  childCount: repo.habits.length,
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
