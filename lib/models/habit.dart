import 'dart:convert';

class Habit {
  final String id;
  final String title;
  final String description;
  final int iconCode;
  final int colorValue;
  final List<int> frequencyDays; // 0=Mon … 6=Sun
  final String? reminderTime;   // "HH:mm" or null
  final int createdAt;           // Unix ms
  final bool isArchived;

  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.iconCode = 57669, // Icons.self_improvement
    required this.colorValue,
    this.frequencyDays = const [0, 1, 2, 3, 4, 5, 6],
    this.reminderTime,
    required this.createdAt,
    this.isArchived = false,
  });

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as String,
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        iconCode: map['icon_code'] as int,
        colorValue: map['color_value'] as int,
        frequencyDays: List<int>.from(
            jsonDecode(map['frequency_days'] as String? ?? '[0,1,2,3,4,5,6]')),
        reminderTime: map['reminder_time'] as String?,
        createdAt: map['created_at'] as int,
        isArchived: (map['is_archived'] as int?) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon_code': iconCode,
        'color_value': colorValue,
        'frequency_days': jsonEncode(frequencyDays),
        'reminder_time': reminderTime,
        'created_at': createdAt,
        'is_archived': isArchived ? 1 : 0,
      };

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    int? iconCode,
    int? colorValue,
    List<int>? frequencyDays,
    String? reminderTime,
    int? createdAt,
    bool? isArchived,
  }) =>
      Habit(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        iconCode: iconCode ?? this.iconCode,
        colorValue: colorValue ?? this.colorValue,
        frequencyDays: frequencyDays ?? this.frequencyDays,
        reminderTime: reminderTime ?? this.reminderTime,
        createdAt: createdAt ?? this.createdAt,
        isArchived: isArchived ?? this.isArchived,
      );

  bool isScheduledFor(DateTime date) {
    // weekday: Mon=1 … Sun=7; frequencyDays: 0=Mon … 6=Sun
    return frequencyDays.contains(date.weekday - 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Habit && other.id == id);

  @override
  int get hashCode => id.hashCode;
}


