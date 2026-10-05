/// Core application constants for Momentra.
class AppConstants {
  AppConstants._();

  static const String appName = 'Momentra';
  static const String appTagline = 'Build Unbreakable Routines';
  static const String dbName = 'momentra.db';
  static const int dbVersion = 1;

  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';

  static const String supportEmail = 'muhammadhusnainkarimain8@gmail.com';
  static const String supportPhone = '+923098078066';

  static const List<String> weekDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<String> fullWeekDayLabels = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  /// Emerald / slate brand palette
  static const int primaryColorValue = 0xFF00C896;
  static const int backgroundColorValue = 0xFF0A0F1A;
  static const int surfaceColorValue = 0xFF111927;
  static const int cardColorValue = 0xFF17202E;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
}


