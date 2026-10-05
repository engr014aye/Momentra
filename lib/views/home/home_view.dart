import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/completion_ring.dart';
import '../../widgets/week_timeline.dart';
import '../habit_editor/habit_editor_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    HapticFeedback.selectionClick();
  }

  Future<void> _openEditor({Habit? habit}) async {
    HapticFeedback.mediumImpact();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            HabitEditorView(habit: habit),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final selectedDateStr = AppUtils.toDateString(_selectedDate);
    final habitsForDate = provider.habitsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(provider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: WeekTimeline(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _DailyCompletionCard(
                provider: provider,
                selectedDate: _selectedDate,
              ),
            ),
          ),
          if (habitsForDate.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(onAdd: _openEditor),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = habitsForDate[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HabitCard(
                        habit: habit,
                        dateString: selectedDateStr,
                        onTap: () => _openEditor(habit: habit),
                        onToggle: () => provider.toggleCompletion(
                            habit.id, date: _selectedDate),
                      ),
                    );
                  },
                  childCount: habitsForDate.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _AnimatedFab(
        controller: _fabController,
        scale: _fabScale,
        onTap: () => _openEditor(),
      ),
    );
  }

  SliverAppBar _buildAppBar(HabitProvider provider) {
    final dateLabel = AppUtils.relativeDayLabel(_selectedDate);
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 100,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).textTheme.displayLarge!.color!,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Completion Card ────────────────────────────────────────────────────

class _DailyCompletionCard extends StatelessWidget {
  final HabitProvider provider;
  final DateTime selectedDate;

  const _DailyCompletionCard({
    required this.provider,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = AppUtils.toDateString(selectedDate) ==
        AppUtils.toDateString(today);
    final total = provider.habitsForDate(selectedDate).length;
    final completed = isToday
        ? provider.todayCompletedCount
        : provider.habitsForDate(selectedDate)
            .where((h) => provider.isCompletedOn(
                h.id, AppUtils.toDateString(selectedDate)))
            .length;
    final ratio = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerTheme.color!, width: 1),
      ),
      child: Row(
        children: [
          CompletionRing(
            progress: ratio,
            size: 72,
            strokeWidth: 7,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed of $total habits',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.displayLarge!.color!,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  ratio == 1.0 && total > 0
                      ? '🎉 All done for the day!'
                      : ratio >= 0.5
                          ? 'Great momentum, keep going!'
                          : total == 0
                              ? 'No habits scheduled'
                              : 'Start building momentum',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Theme.of(context).dividerTheme.color!,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    minHeight: 4,
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerTheme.color!),
              ),
              child: Icon(Icons.add_task_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 40),
            ),
            SizedBox(height: 24),
            Text(
              'No habits for this day',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).textTheme.displayLarge!.color!),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first habit and start building your routine.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_rounded),
              label: const Text('Add Habit'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated FAB ─────────────────────────────────────────────────────────────

class _AnimatedFab extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scale;
  final VoidCallback onTap;

  const _AnimatedFab({
    required this.controller,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: GestureDetector(
        onTapDown: (_) => controller.forward(),
        onTapUp: (_) {
          controller.reverse();
          onTap();
        },
        onTapCancel: () => controller.reverse(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded,
              color: Colors.black, size: 30),
        ),
      ),
    );
  }
}




