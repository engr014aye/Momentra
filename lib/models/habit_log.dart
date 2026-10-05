class HabitLog {
  final String id;
  final String habitId;
  final String dateString; // YYYY-MM-DD
  final int completedAt;   // Unix ms

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.dateString,
    required this.completedAt,
  });

  factory HabitLog.fromMap(Map<String, dynamic> map) => HabitLog(
        id: map['id'] as String,
        habitId: map['habit_id'] as String,
        dateString: map['date_string'] as String,
        completedAt: map['completed_at'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'date_string': dateString,
        'completed_at': completedAt,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.habitId == habitId &&
          other.dateString == dateString);

  @override
  int get hashCode => Object.hash(habitId, dateString);
}


