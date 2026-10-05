import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';

/// Individual habit card with spring-animated check toggle.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final String dateString;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    required this.dateString,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onCardTap() async {
    await _scaleController.forward();
    await _scaleController.reverse();
    widget.onTap();
  }

  Future<void> _onCheckToggle() async {
    HapticFeedback.lightImpact();
    await _scaleController.forward();
    await _scaleController.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final isCompleted =
        provider.isCompletedOn(widget.habit.id, widget.dateString);
    final color = Color(widget.habit.colorValue);
    final icon = IconData(widget.habit.iconCode, fontFamily: 'MaterialIcons');

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _onCardTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? color.withValues(alpha: 0.08)
                : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? color.withValues(alpha: 0.4)
                  : Theme.of(context).dividerTheme.color!,
              width: isCompleted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 14),
              // Title & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isCompleted
                                    ? Theme.of(context).textTheme.bodySmall!.color!
                                    : Theme.of(context).textTheme.displayLarge!.color!,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Theme.of(context).textTheme.bodySmall!.color!,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.habit.description.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        widget.habit.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (widget.habit.reminderTime != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.alarm_rounded,
                              size: 12, color: Theme.of(context).textTheme.bodySmall!.color!),
                          SizedBox(width: 4),
                          Text(
                            AppUtils.formatTime(widget.habit.reminderTime),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Check button with spring animation
              GestureDetector(
                onTap: _onCheckToggle,
                behavior: HitTestBehavior.opaque,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: isCompleted ? 0.0 : 1.0,
                    end: isCompleted ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, t, _) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          Colors.transparent,
                          color,
                          t,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.lerp(
                            Theme.of(context).textTheme.bodySmall!.color!,
                            color,
                            t,
                          )!,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


