import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/habit.dart';

/// Repository handling all CRUD operations for habits, persisted via SharedPreferences.
class HabitRepository extends ChangeNotifier {
  static const String _storageKey = 'habits_v1';
  List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get todayHabits => _habits; // All habits shown daily for now.

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ── Initialization ────────────────────────────────────────────────────
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      _habits =
          jsonList
              .map((j) => Habit.fromJson(j as Map<String, dynamic>))
              .toList();
    } else {
      // Pre-populate with sample habits for first-time users
      _habits = _defaultHabits();
      await _save();
    }
    _isLoaded = true;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _save();
    notifyListeners();
  }

  Future<void> updateHabit(Habit updated) async {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final dayOnly = DateTime(date.year, date.month, date.day);
    final alreadyDone = habit.isCompletedOn(dayOnly);

    List<DateTime> updatedDates;
    if (alreadyDone) {
      updatedDates =
          habit.completedDates
              .where(
                (d) =>
                    !(d.year == dayOnly.year &&
                        d.month == dayOnly.month &&
                        d.day == dayOnly.day),
              )
              .toList();
    } else {
      updatedDates = [...habit.completedDates, dayOnly];
    }

    _habits[index] = habit.copyWith(completedDates: updatedDates);
    await _save();
    notifyListeners();
  }

  // ── Statistics helpers ────────────────────────────────────────────────
  double get todayCompletionRate {
    if (_habits.isEmpty) return 0.0;
    final completed = _habits.where((h) => h.isCompletedToday).length;
    return completed / _habits.length;
  }

  int get totalCompletedToday {
    return _habits.where((h) => h.isCompletedToday).length;
  }

  int get overallCurrentStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  /// Completion counts per day for the last 7 days.
  List<int> get weeklyCompletions {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return _habits.where((h) => h.isCompletedOn(date)).length;
    });
  }

  /// Total possible completions per day (number of habits).
  int get totalHabitsCount => _habits.length;

  double get overallConsistency {
    if (_habits.isEmpty) return 0.0;
    final now = DateTime.now();
    int totalPossible = 0;
    int totalCompleted = 0;
    for (final habit in _habits) {
      final daysSinceCreation =
          now.difference(habit.createdAt).inDays.clamp(1, 30);
      totalPossible += daysSinceCreation;
      totalCompleted +=
          habit.completedDates
              .where(
                (d) => d.isAfter(now.subtract(Duration(days: daysSinceCreation))),
              )
              .length;
    }
    if (totalPossible == 0) return 0.0;
    return (totalCompleted / totalPossible).clamp(0.0, 1.0);
  }

  // ── Persistence ───────────────────────────────────────────────────────
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _habits.map((h) => h.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // ── Export / Import ───────────────────────────────────────────────────
  String exportJson() {
    final jsonList = _habits.map((h) => h.toJson()).toList();
    return jsonEncode(jsonList);
  }

  Future<bool> importJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final imported = jsonList
          .map((j) => Habit.fromJson(j as Map<String, dynamic>))
          .toList();
      _habits = imported;
      await _save();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Default habits ────────────────────────────────────────────────────
  List<Habit> _defaultHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'default_1',
        name: 'Morning Exercise',
        iconCodePoint: Icons.fitness_center_rounded.codePoint,
        colorIndex: 1,
        category: HabitCategory.fitness,
        frequency: HabitFrequency.daily,
        createdAt: now.subtract(const Duration(days: 7)),
        completedDates: [
          now.subtract(const Duration(days: 6)),
          now.subtract(const Duration(days: 5)),
          now.subtract(const Duration(days: 4)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 1)),
        ],
      ),
      Habit(
        id: 'default_2',
        name: 'Read 20 Minutes',
        iconCodePoint: Icons.menu_book_rounded.codePoint,
        colorIndex: 4,
        category: HabitCategory.learning,
        frequency: HabitFrequency.daily,
        createdAt: now.subtract(const Duration(days: 10)),
        completedDates: [
          now.subtract(const Duration(days: 9)),
          now.subtract(const Duration(days: 8)),
          now.subtract(const Duration(days: 7)),
          now.subtract(const Duration(days: 6)),
          now.subtract(const Duration(days: 5)),
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 1)),
        ],
      ),
      Habit(
        id: 'default_3',
        name: 'Meditate',
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
        colorIndex: 6,
        category: HabitCategory.mindfulness,
        frequency: HabitFrequency.daily,
        createdAt: now.subtract(const Duration(days: 5)),
        completedDates: [
          now.subtract(const Duration(days: 4)),
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 1)),
        ],
      ),
      Habit(
        id: 'default_4',
        name: 'Drink 8 Glasses',
        iconCodePoint: Icons.water_drop_rounded.codePoint,
        colorIndex: 8,
        category: HabitCategory.health,
        frequency: HabitFrequency.daily,
        createdAt: now.subtract(const Duration(days: 3)),
        completedDates: [
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 1)),
        ],
      ),
    ];
  }
}
