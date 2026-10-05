import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_utils.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/completion_ring.dart';

/// Analytics dashboard showing streaks and heatmap.
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final activeHabits = provider.habits.where((h) => !h.isArchived).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Analytics',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _OverallCard(provider: provider),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _MonthlyHeatmap(
                year: _currentYear,
                month: _currentMonth,
                onPrev: _prevMonth,
                onNext: _nextMonth,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'STREAKS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          if (activeHabits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No active habits yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HabitStreakCard(habit: activeHabits[index]),
                    );
                  },
                  childCount: activeHabits.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final HabitProvider provider;
  const _OverallCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final ratio = provider.todayCompletionRatio;
    final completed = provider.todayCompletedCount;
    final total = provider.todayTotalCount;
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerTheme.color!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CompletionRing(
              progress: ratio,
              size: 80,
              strokeWidth: 8,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$completed / $total completed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyHeatmap extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthlyHeatmap({
    required this.year,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerTheme.color!;
    final textPrimary = Theme.of(context).textTheme.displayLarge?.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppUtils.monthName(month)} $year',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: textPrimary),
                    onPressed: onPrev,
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: textPrimary),
                    onPressed: onNext,
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: provider.getMonthlyHeatmap(year, month),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data!;
              return _buildGrid(context, data);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, Map<String, int> heatmap) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final totalCells = startOffset + daysInMonth;
    final numRows = (totalCells / 7).ceil();
    final dividerColor = Theme.of(context).dividerTheme.color!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(d, style: Theme.of(context).textTheme.bodySmall),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        for (int row = 0; row < numRows; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIdx = row * 7 + col;
              final dayNum = cellIdx - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return SizedBox(width: 32, height: 32);
              }

              final dateString = AppUtils.toDateString(DateTime(year, month, dayNum));
              final completed = heatmap[dateString] ?? 0;
              Color cellColor = dividerColor.withOpacity(0.3);
              if (completed > 0) {
                final intensity = (completed / 5).clamp(0.2, 1.0);
                cellColor = primaryColor.withOpacity(intensity);
              }

              return Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 12,
                      color: completed > 0 ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: completed > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ]
      ],
    );
  }
}

class _HabitStreakCard extends StatelessWidget {
  final dynamic habit; // Habit type from model
  const _HabitStreakCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerTheme.color!;
    final textPrimary = Theme.of(context).textTheme.displayLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
      ),
      child: FutureBuilder<List<int>>(
        future: Future.wait([
          provider.getCurrentStreak(habit.id),
          provider.getBestStreak(habit.id),
        ]),
        builder: (context, snapshot) {
          int currentStreak = 0;
          int bestStreak = 0;
          if (snapshot.hasData) {
            currentStreak = snapshot.data![0];
            bestStreak = snapshot.data![1];
          }
          return Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(habit.colorValue).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  // ignore: non_const_argument_for_const_parameter
                  IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                  color: Color(habit.colorValue),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  habit.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppUtils.streakLabel(currentStreak)} 🔥',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Best: $bestStreak',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

