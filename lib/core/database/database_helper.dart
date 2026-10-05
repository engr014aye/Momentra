import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.habitsTable} (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        icon_code INTEGER NOT NULL DEFAULT 57669,
        color_value INTEGER NOT NULL DEFAULT ${AppConstants.primaryColorValue},
        frequency_days TEXT NOT NULL DEFAULT '[0,1,2,3,4,5,6]',
        reminder_time TEXT,
        created_at INTEGER NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.habitLogsTable} (
        id TEXT PRIMARY KEY NOT NULL,
        habit_id TEXT NOT NULL,
        date_string TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES ${AppConstants.habitsTable}(id)
          ON DELETE CASCADE,
        UNIQUE (habit_id, date_string)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  // ─── Habits CRUD ────────────────────────────────────────────────────────────

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return db.insert(AppConstants.habitsTable, habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived ? null : 'is_archived = 0';
    final rows = await db.query(
      AppConstants.habitsTable,
      where: whereClause,
      orderBy: 'created_at ASC',
    );
    return rows.map(Habit.fromMap).toList();
  }

  Future<Habit?> getHabitById(String id) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.habitsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Habit.fromMap(rows.first);
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return db.update(
      AppConstants.habitsTable,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await database;
    return db.delete(
      AppConstants.habitsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> archiveHabit(String id, {bool archive = true}) async {
    final db = await database;
    return db.update(
      AppConstants.habitsTable,
      {'is_archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasAnyHabits() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.habitsTable}'),
    );
    return (count ?? 0) > 0;
  }

  // ─── Habit Logs CRUD ────────────────────────────────────────────────────────

  Future<int> insertLog(HabitLog log) async {
    final db = await database;
    return db.insert(AppConstants.habitLogsTable, log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteLog(String habitId, String dateString) async {
    final db = await database;
    return db.delete(
      AppConstants.habitLogsTable,
      where: 'habit_id = ? AND date_string = ?',
      whereArgs: [habitId, dateString],
    );
  }

  Future<bool> isCompleted(String habitId, String dateString) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.habitLogsTable} '
        'WHERE habit_id = ? AND date_string = ?',
        [habitId, dateString],
      ),
    );
    return (count ?? 0) > 0;
  }

  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.habitLogsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date_string DESC',
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<List<HabitLog>> getLogsForDate(String dateString) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.habitLogsTable,
      where: 'date_string = ?',
      whereArgs: [dateString],
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<List<HabitLog>> getLogsInRange(
      String habitId, String startDate, String endDate) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.habitLogsTable,
      where: 'habit_id = ? AND date_string >= ? AND date_string <= ?',
      whereArgs: [habitId, startDate, endDate],
      orderBy: 'date_string ASC',
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  /// Returns map of date_string → completion count across all habits.
  Future<Map<String, int>> getMonthlyHeatmap(int year, int month) async {
    final db = await database;
    final startDate =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final endDate =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-31';
    final rows = await db.rawQuery(
      '''
      SELECT date_string, COUNT(*) as cnt
      FROM ${AppConstants.habitLogsTable}
      WHERE date_string >= ? AND date_string <= ?
      GROUP BY date_string
      ''',
      [startDate, endDate],
    );
    return {for (final r in rows) r['date_string'] as String: r['cnt'] as int};
  }

  /// Returns the current streak for a habit (consecutive days up to today).
  Future<int> getCurrentStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    if (logs.isEmpty) return 0;

    final dates = logs.map((l) => l.dateString).toSet();
    var streak = 0;
    var day = DateTime.now();

    while (true) {
      final ds = _fmt(day);
      if (dates.contains(ds)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns the best streak (all-time longest) for a habit.
  Future<int> getBestStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    if (logs.isEmpty) return 0;

    final dates = logs.map((l) => l.dateString).toList()..sort();
    var best = 1;
    var current = 1;

    for (var i = 1; i < dates.length; i++) {
      final prev = DateTime.parse(dates[i - 1]);
      final curr = DateTime.parse(dates[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}


