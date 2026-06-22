import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/habit.dart';
import '../theme/colors.dart';

/// A premium glassmorphic habit card with completion toggle and streak info.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final habitColor =
        AppColors.habitColors[habit.colorIndex % AppColors.habitColors.length];
    final isCompleted = habit.isCompletedToday;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? habitColor.withValues(alpha: 0.12)
                    : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isCompleted
                      ? habitColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow:
                isCompleted
                    ? [
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              // ── Completion button ─────────────────────────────────
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onToggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isCompleted
                            ? habitColor
                            : habitColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color:
                          isCompleted
                              ? habitColor
                              : habitColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 24,
                              key: ValueKey('check'),
                            )
                            : Icon(
                              IconData(
                                habit.iconCodePoint,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: habitColor,
                              size: 22,
                              key: const ValueKey('icon'),
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Habit info ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color:
                            isCompleted
                                ? Theme.of(context).textTheme.titleMedium?.color
                                    ?.withValues(alpha: 0.5)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          habit.category.icon,
                          size: 14,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habit.category.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Streak badge ──────────────────────────────────────
              if (habit.currentStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: habitColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: habitColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
