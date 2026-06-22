import 'dart:convert';
import 'package:flutter/material.dart';

/// Frequency options for a habit.
enum HabitFrequency { daily, weekly }

/// Category tags for habits.
enum HabitCategory {
  health,
  fitness,
  mindfulness,
  learning,
  productivity,
  social,
  creativity,
  other;

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.creativity:
        return 'Creativity';
      case HabitCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.health:
        return Icons.favorite_rounded;
      case HabitCategory.fitness:
        return Icons.fitness_center_rounded;
      case HabitCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case HabitCategory.learning:
        return Icons.menu_book_rounded;
      case HabitCategory.productivity:
        return Icons.rocket_launch_rounded;
      case HabitCategory.social:
        return Icons.people_rounded;
      case HabitCategory.creativity:
        return Icons.palette_rounded;
      case HabitCategory.other:
        return Icons.star_rounded;
    }
  }
}

/// Core domain model for a habit.
class Habit {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorIndex;
  final HabitCategory category;
  final HabitFrequency frequency;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final String? description;
  final String? targetTime;

  Habit({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorIndex,
    required this.category,
    required this.frequency,
    required this.createdAt,
    List<DateTime>? completedDates,
    this.description,
    this.targetTime,
  }) : completedDates = completedDates ?? [];

  /// Whether this habit is completed for a given date.
  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Whether this habit is completed today.
  bool get isCompletedToday => isCompletedOn(DateTime.now());

  /// Current streak count (consecutive days completed ending today or yesterday).
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sorted = [...completedDates]..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the streak is still active (completed today or yesterday)
    final lastDate = DateTime(
      sorted.first.year,
      sorted.first.month,
      sorted.first.day,
    );
    if (lastDate != today && lastDate != yesterday) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final current = DateTime(
        sorted[i - 1].year,
        sorted[i - 1].month,
        sorted[i - 1].day,
      );
      final previous = DateTime(
        sorted[i].year,
        sorted[i].month,
        sorted[i].day,
      );
      if (current.difference(previous).inDays == 1) {
        streak++;
      } else if (current.difference(previous).inDays == 0) {
        // Same day, skip duplicate
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Longest streak ever.
  int get longestStreak {
    if (completedDates.isEmpty) return 0;

    final sorted = [...completedDates]..sort();
    final uniqueDays = <DateTime>[];
    for (final date in sorted) {
      final dayOnly = DateTime(date.year, date.month, date.day);
      if (uniqueDays.isEmpty || uniqueDays.last != dayOnly) {
        uniqueDays.add(dayOnly);
      }
    }

    int maxStreak = 1;
    int currentStreak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      if (uniqueDays[i].difference(uniqueDays[i - 1]).inDays == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    return maxStreak;
  }

  /// Number of completions in the last 7 days.
  int get completionsThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return completedDates.where((d) => d.isAfter(weekAgo)).length;
  }

  /// Returns a copy with updated fields.
  Habit copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorIndex,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    String? description,
    String? targetTime,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorIndex: colorIndex ?? this.colorIndex,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      description: description ?? this.description,
      targetTime: targetTime ?? this.targetTime,
    );
  }

  /// JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorIndex': colorIndex,
      'category': category.index,
      'frequency': frequency.index,
      'createdAt': createdAt.toIso8601String(),
      'completedDates':
          completedDates.map((d) => d.toIso8601String()).toList(),
      'description': description,
      'targetTime': targetTime,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      colorIndex: json['colorIndex'] as int,
      category: HabitCategory.values[json['category'] as int],
      frequency: HabitFrequency.values[json['frequency'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedDates:
          (json['completedDates'] as List)
              .map((d) => DateTime.parse(d as String))
              .toList(),
      description: json['description'] as String?,
      targetTime: json['targetTime'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory Habit.fromJsonString(String s) =>
      Habit.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
