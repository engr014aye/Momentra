import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/habit_provider.dart';

/// Horizontal 7-day timeline strip with completion dots.
class WeekTimeline extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeekTimeline({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final weekDays = AppUtils.currentWeekDays();
    final today = DateTime.now();
    final todayStr = AppUtils.toDateString(today);
    final selectedStr = AppUtils.toDateString(selectedDate);

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: weekDays.asMap().entries.map((entry) {
          final idx = entry.key;
          final day = entry.value;
          final dayStr = AppUtils.toDateString(day);
          final isSelected = dayStr == selectedStr;
          final isToday = dayStr == todayStr;
          final isFuture = day.isAfter(today);

          // Completion dot
          final habitsForDay = provider.habitsForDate(day);
          final completedCount = habitsForDay
              .where((h) => provider.isCompletedOn(h.id, dayStr))
              .length;
          final total = habitsForDay.length;
          final isFullyDone = total > 0 && completedCount == total;
          final isPartial = completedCount > 0 && completedCount < total;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onDateSelected(day);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayLetter(idx),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodySmall!.color!,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                                ? Theme.of(context).textTheme.displayLarge!.color!
                                : isFuture
                                    ? Theme.of(context).textTheme.bodySmall!.color!
                                    : Theme.of(context).textTheme.displayLarge!.color!,
                      ),
                    ),
                    SizedBox(height: 5),
                    _CompletionDot(
                      isFuture: isFuture,
                      isFullyDone: isFullyDone,
                      isPartial: isPartial,
                      hasHabits: total > 0,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _dayLetter(int index) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[index];
  }
}

class _CompletionDot extends StatelessWidget {
  final bool isFuture;
  final bool isFullyDone;
  final bool isPartial;
  final bool hasHabits;

  const _CompletionDot({
    required this.isFuture,
    required this.isFullyDone,
    required this.isPartial,
    required this.hasHabits,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (!hasHabits || isFuture) {
      color = Colors.transparent;
    } else if (isFullyDone) {
      color = Theme.of(context).colorScheme.primary;
    } else if (isPartial) {
      color = AppTheme.warning;
    } else {
      color = Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.4);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}


