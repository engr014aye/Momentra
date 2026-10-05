import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/utils/app_utils.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

enum HabitProviderState { idle, loading, error }

class HabitProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<Habit> _habits = [];
  // date_string → set of habit_ids completed
  final Map<String, Set<String>> _completionCache = {};

  HabitProviderState _state = HabitProviderState.idle;
  String? _errorMessage;

  List<Habit> get habits => _habits;
  HabitProviderState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Active (non-archived) habits scheduled for a given date.
  List<Habit> habitsForDate(DateTime date) =>
      _habits.where((h) => !h.isArchived && h.isScheduledFor(date)).toList();

  /// Today's habits.
  List<Habit> get todayHabits => habitsForDate(DateTime.now());

  bool isCompletedOn(String habitId, String dateString) =>
      _completionCache[dateString]?.contains(habitId) ?? false;

  bool isCompletedToday(String habitId) =>
      isCompletedOn(habitId, AppUtils.todayString());

  /// Count of today's completed habits (for ring).
  int get todayCompletedCount {
    final today = AppUtils.todayString();
    final todayHabitIds = todayHabits.map((h) => h.id).toSet();
    return (_completionCache[today] ?? {})
        .where(todayHabitIds.contains)
        .length;
  }

  int get todayTotalCount => todayHabits.length;

  double get todayCompletionRatio {
    if (todayTotalCount == 0) return 0;
    return todayCompletedCount / todayTotalCount;
  }

  // ─── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _state = HabitProviderState.loading;
    notifyListeners();

    try {

      await _loadHabits();
      await _loadWeekCompletions();
      _state = HabitProviderState.idle;
    } catch (e) {
      _state = HabitProviderState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _loadHabits() async {
    _habits = await _db.getAllHabits();
  }

  Future<void> _loadWeekCompletions() async {
    final week = AppUtils.currentWeekDays();
    for (final day in week) {
      final ds = AppUtils.toDateString(day);
      final logs = await _db.getLogsForDate(ds);
      _completionCache[ds] = logs.map((l) => l.habitId).toSet();
    }
  }

  // ─── Toggle Completion ───────────────────────────────────────────────────────

  Future<void> toggleCompletion(String habitId, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    final ds = AppUtils.toDateString(d);
    final wasCompleted = isCompletedOn(habitId, ds);

    // Optimistic update
    if (wasCompleted) {
      _completionCache[ds]?.remove(habitId);
    } else {
      _completionCache.putIfAbsent(ds, () => {}).add(habitId);
    }
    notifyListeners();

    HapticFeedback.lightImpact();

    try {
      if (wasCompleted) {
        await _db.deleteLog(habitId, ds);
      } else {
        await _db.insertLog(HabitLog(
          id: _uuid.v4(),
          habitId: habitId,
          dateString: ds,
          completedAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (_) {
      // Rollback on failure
      if (wasCompleted) {
        _completionCache.putIfAbsent(ds, () => {}).add(habitId);
      } else {
        _completionCache[ds]?.remove(habitId);
      }
      notifyListeners();
    }
  }

  // ─── Habit CRUD ─────────────────────────────────────────────────────────────

  Future<void> addHabit(Habit habit) async {
    await _db.insertHabit(habit);
    await _loadHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    await _loadHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> archiveHabit(String id) async {
    await _db.archiveHabit(id);
    await _loadHabits();
    notifyListeners();
  }

  // ─── Analytics Getters ───────────────────────────────────────────────────────

  Future<int> getCurrentStreak(String habitId) =>
      _db.getCurrentStreak(habitId);

  Future<int> getBestStreak(String habitId) => _db.getBestStreak(habitId);

  Future<Map<String, int>> getMonthlyHeatmap(int year, int month) =>
      _db.getMonthlyHeatmap(year, month);

  Future<List<HabitLog>> getLogsForHabit(String habitId) =>
      _db.getLogsForHabit(habitId);

  /// Returns completion ratio for a habit over the last N days.
  Future<double> getCompletionRate(String habitId, int days) async {
    final habit = _habits.firstWhere((h) => h.id == habitId,
        orElse: () => throw Exception('Habit not found'));
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    int scheduled = 0;
    int completed = 0;
    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      if (habit.isScheduledFor(day)) {
        scheduled++;
        final ds = AppUtils.toDateString(day);
        if (isCompletedOn(habitId, ds) ||
            await _db.isCompleted(habitId, ds)) {
          completed++;
        }
      }
    }
    return scheduled == 0 ? 0 : completed / scheduled;
  }
}


