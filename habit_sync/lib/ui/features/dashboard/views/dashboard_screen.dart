import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';
import 'package:habit_sync/ui/core/widgets/progress_ring.dart';
import 'package:habit_sync/ui/core/widgets/habit_card.dart';
import 'package:go_router/go_router.dart';

/// The main dashboard screen showing today's progress and habits.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _motivationalMessage(double progress) {
    if (progress >= 1.0) return 'Amazing! All habits done! 🎉';
    if (progress >= 0.75) return 'Almost there, keep going! 💪';
    if (progress >= 0.5) return 'Halfway done, nice work! ⚡';
    if (progress > 0) return 'Great start, keep it up! 🌟';
    return 'Let\'s build great habits today! ✨';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitRepository>(
      builder: (context, repo, _) {
        if (!repo.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final completionRate = repo.todayCompletionRate;
        final completedCount = repo.totalCompletedToday;
        final totalCount = repo.totalHabitsCount;

        return CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'HabitSync',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${repo.overallCurrentStreak}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Greeting + Progress Card ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _motivationalMessage(completionRate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // ── Progress card ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Progress ring
                          ProgressRing(
                            progress: completionRate,
                            size: 100,
                            strokeWidth: 8,
                            progressColor: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            child: Text(
                              '${(completionRate * 100).round()}%',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Stats
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Progress',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$completedCount of $totalCount',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'habits completed',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'Today\'s Habits',
                  style: Theme.of(context).textTheme.titleLarge,
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
                        'Tap + to add your first habit',
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
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(
                        milliseconds: 300 + (index * 100),
                      ),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: HabitCard(
                        habit: habit,
                        onToggle: () {
                          repo.toggleHabitCompletion(
                            habit.id,
                            DateTime.now(),
                          );
                        },
                        onTap: () => context.push('/habit/${habit.id}'),
                        onDelete: () {
                          repo.deleteHabit(habit.id);
                        },
                      ),
                    );
                  },
                  childCount: repo.habits.length,
                ),
              ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }
}
