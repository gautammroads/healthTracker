import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';
import 'package:habit_sync/ui/core/widgets/progress_ring.dart';

/// Statistics screen showing weekly charts, streaks, and consistency.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitRepository>(
      builder: (context, repo, _) {
        final weeklyData = repo.weeklyCompletions;
        final totalHabits = repo.totalHabitsCount;
        final consistency = repo.overallConsistency;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Statistics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Consistency card ───────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.successGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ProgressRing(
                            progress: consistency,
                            size: 90,
                            strokeWidth: 8,
                            progressColor: Colors.white,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            child: Text(
                              '${(consistency * 100).round()}%',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Consistency',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Based on the last 30 days',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Weekly chart ──────────────────────────────────
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 220,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.cardDark
                                : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: totalHabits.toDouble().clamp(1, double.infinity),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.primary,
                              getTooltipItem: (group, gIndex, rod, rIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} / $totalHabits',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final now = DateTime.now();
                                  final date = now.subtract(
                                    Duration(days: 6 - value.toInt()),
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('E').format(date).substring(0, 2),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (index) {
                            final value = weeklyData[index].toDouble();
                            final isToday = index == 6;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  width: 28,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors:
                                        isToday
                                            ? [
                                              AppColors.primary,
                                              AppColors.primaryLight,
                                            ]
                                            : [
                                              AppColors.primary.withValues(
                                                alpha: 0.4,
                                              ),
                                              AppColors.primary.withValues(
                                                alpha: 0.7,
                                              ),
                                            ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Streak leaderboard ────────────────────────────
                    Text(
                      'Streak Leaderboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    if (repo.habits.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Add habits to see streaks',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                    else
                      ...(repo.habits.toList()
                            ..sort(
                              (a, b) =>
                                  b.currentStreak.compareTo(a.currentStreak),
                            ))
                          .map((habit) {
                            final color =
                                AppColors
                                    .habitColors[habit.colorIndex %
                                        AppColors.habitColors.length];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.cardDark
                                        : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconData(
                                        habit.iconCodePoint,
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          habit.name,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Best: ${habit.longestStreak} days',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        color: color,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${habit.currentStreak}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }
}
