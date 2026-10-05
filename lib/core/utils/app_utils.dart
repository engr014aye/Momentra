
/// Formatting and date utilities.
class AppUtils {
  AppUtils._();

  /// Returns YYYY-MM-DD string for a given DateTime.
  static String toDateString(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static String todayString() => toDateString(DateTime.now());

  /// Returns the start of the ISO week (Monday) for a given date.
  static DateTime weekStart(DateTime dt) {
    final weekday = dt.weekday; // 1=Mon, 7=Sun
    return DateTime(dt.year, dt.month, dt.day - (weekday - 1));
  }

  /// Returns the 7 dates for the current week (Mon–Sun).
  static List<DateTime> currentWeekDays() {
    final start = weekStart(DateTime.now());
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// Friendly relative date label.
  static String relativeDayLabel(DateTime dt) {
    final today = DateTime.now();
    final diff = DateTime(dt.year, dt.month, dt.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return _dayName(dt.weekday);
  }

  static String _dayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1) % 7];
  }

  /// Formats 24h time string "HH:mm" to a human-friendly form.
  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return 'No Reminder';
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${hour.toString()}:${m.toString().padLeft(2, '0')} $suffix';
  }

  /// Streak label with emoji.
  static String streakLabel(int streak) {
    if (streak == 0) return 'Start today!';
    if (streak == 1) return '🔥 1 day streak';
    return '🔥 $streak day streak';
  }

  /// Month name for a given month index (1-12).
  static String monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month % 13];
  }

  /// Returns a color-blended value (0.0–1.0) from count and max.
  static double heatmapIntensity(int count, int max) {
    if (max == 0) return 0;
    return (count / max).clamp(0.0, 1.0);
  }
}


