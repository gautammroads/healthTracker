import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/domain/models/habit.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';
import 'package:habit_sync/ui/features/habits/views/add_habit_sheet.dart';

class HabitDetailsScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final habit = repo.habits.where((h) => h.id == habitId).firstOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final color = AppColors.habitColors[habit.colorIndex % AppColors.habitColors.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddHabitSheet(existingHabit: habit),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, repo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon and Name
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(habit.category.icon, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            habit.category.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Target Time and Frequency
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    context,
                    icon: Icons.access_time_rounded,
                    title: 'Target Time',
                    value: habit.targetTime ?? 'Anytime',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _infoCard(
                    context,
                    icon: Icons.repeat_rounded,
                    title: 'Frequency',
                    value: habit.frequency == HabitFrequency.daily ? 'Daily' : 'Weekly',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (habit.description != null && habit.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkAlt : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habit.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Statistics Section
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context,
                    title: 'Current Streak',
                    value: '${habit.currentStreak}',
                    subtitle: 'days',
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    context,
                    title: 'Longest Streak',
                    value: '${habit.longestStreak}',
                    subtitle: 'days',
                    icon: Icons.emoji_events_rounded,
                    color: Colors.amber,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context,
                    title: 'Total Completed',
                    value: '${habit.completedDates.length}',
                    subtitle: 'times',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, {required IconData icon, required String title, required String value, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkAlt : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, {required String title, required String value, required String subtitle, required IconData icon, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkAlt : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '$title ($subtitle)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, HabitRepository repo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              repo.deleteHabit(habitId);
              Navigator.of(context).pop(); // Close dialog
              if (context.mounted) {
                context.pop(); // Go back to dashboard/habits list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
