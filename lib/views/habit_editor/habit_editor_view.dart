import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';

/// Habit creation and editing screen.
class HabitEditorView extends StatefulWidget {
  final Habit? habit; // null = create mode

  const HabitEditorView({super.key, this.habit});

  @override
  State<HabitEditorView> createState() => _HabitEditorViewState();
}

class _HabitEditorViewState extends State<HabitEditorView> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  late int _selectedIconCode;
  late int _selectedColorValue;
  late List<int> _frequencyDays;
  String? _reminderTime;

  bool _isSaving = false;

  final List<int> _iconOptions = [
    0xe4f8, // water_drop
    0xe3f5, // menu_book
    0xe55c, // directions_walk
    0xe52c, // fitness_center
    0xe63e, // self_improvement
    0xe1b8, // bedtime
    0xe25a, // restaurant
    0xe553, // code
    0xe40e, // music_note
    0xe0c8, // brush
    0xe547, // favorite
    0xe558, // star
  ];

  final List<int> _colorOptions = [
    0xFF00C896, // emerald
    0xFF2196F3, // blue
    0xFFFF9800, // orange
    0xFF9C27B0, // purple
    0xFFE91E63, // pink
    0xFF4CAF50, // green
    0xFFF44336, // red
    0xFF00BCD4, // cyan
    0xFFFF5722, // deep orange
    0xFF607D8B, // blue grey
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleCtrl = TextEditingController(text: h?.title ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _selectedIconCode = h?.iconCode ?? _iconOptions.first;
    _selectedColorValue = h?.colorValue ?? _colorOptions.first;
    _frequencyDays = List.from(h?.frequencyDays ?? [0, 1, 2, 3, 4, 5, 6]);
    _reminderTime = h?.reminderTime;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.habit != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequencyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one day for the habit.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final provider = context.read<HabitProvider>();
    final now = DateTime.now().millisecondsSinceEpoch;

    final habit = Habit(
      id: widget.habit?.id ?? _uuid.v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      iconCode: _selectedIconCode,
      colorValue: _selectedColorValue,
      frequencyDays: List.from(_frequencyDays)..sort(),
      reminderTime: _reminderTime,
      createdAt: widget.habit?.createdAt ?? now,
    );

    try {
      if (_isEditing) {
        await provider.updateHabit(habit);
      } else {
        await provider.addHabit(habit);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save habit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Habit',
            style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color!)),
        content: Text(
          'Are you sure you want to delete "${widget.habit!.title}"? '
          'All log history will be permanently removed.',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      await context
          .read<HabitProvider>()
          .deleteHabit(widget.habit!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickReminderTime() async {
    HapticFeedback.selectionClick();
    final initial = _reminderTime != null
        ? TimeOfDay(
            hour: int.parse(_reminderTime!.split(':')[0]),
            minute: int.parse(_reminderTime!.split(':')[1]),
          )
        : const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Theme.of(context).colorScheme.primary,
            surface: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _reminderTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(_selectedColorValue);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error),
              tooltip: 'Delete Habit',
              onPressed: _deleteHabit,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Preview
                  _PreviewTile(
                    iconCode: _selectedIconCode,
                    colorValue: _selectedColorValue,
                    title: _titleCtrl.text.isNotEmpty
                        ? _titleCtrl.text
                        : 'Habit Name',
                  ),
                  SizedBox(height: 24),

                  // Title
                  _SectionLabel(label: 'Title'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Morning Meditation',
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a habit title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Description
                  _SectionLabel(label: 'Description (optional)'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      hintText: 'What is this habit about?',
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 24),

                  // Icon
                  _SectionLabel(label: 'Icon'),
                  SizedBox(height: 12),
                  _IconPicker(
                    iconOptions: _iconOptions,
                    selectedIconCode: _selectedIconCode,
                    selectedColor: Color(_selectedColorValue),
                    onSelected: (code) =>
                        setState(() => _selectedIconCode = code),
                  ),
                  SizedBox(height: 24),

                  // Color
                  _SectionLabel(label: 'Color'),
                  SizedBox(height: 12),
                  _ColorPicker(
                    colorOptions: _colorOptions,
                    selectedColorValue: _selectedColorValue,
                    onSelected: (val) =>
                        setState(() => _selectedColorValue = val),
                  ),
                  SizedBox(height: 24),

                  // Frequency
                  _SectionLabel(label: 'Repeat'),
                  SizedBox(height: 12),
                  _FrequencySelector(
                    frequencyDays: _frequencyDays,
                    accentColor: accentColor,
                    onChanged: (days) =>
                        setState(() => _frequencyDays = days),
                  ),
                  SizedBox(height: 24),

                  // Reminder
                  _SectionLabel(label: 'Reminder'),
                  SizedBox(height: 8),
                  _ReminderTile(
                    reminderTime: _reminderTime,
                    onTap: _pickReminderTime,
                    onClear: () =>
                        setState(() => _reminderTime = null),
                  ),
                  SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall!.color!,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      );
}

class _PreviewTile extends StatelessWidget {
  final int iconCode;
  final int colorValue;
  final String title;

  const _PreviewTile({
    required this.iconCode,
    required this.colorValue,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              IconData(iconCode, fontFamily: 'MaterialIcons'),
              color: color,
              size: 26,
            ),
          ),
          SizedBox(width: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).textTheme.displayLarge!.color!,
                ),
          ),
        ],
      ),
    );
  }
}

class _IconPicker extends StatelessWidget {
  final List<int> iconOptions;
  final int selectedIconCode;
  final Color selectedColor;
  final ValueChanged<int> onSelected;

  const _IconPicker({
    required this.iconOptions,
    required this.selectedIconCode,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: iconOptions.map((code) {
        final isSelected = code == selectedIconCode;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(code);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.2)
                  : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? selectedColor : Theme.of(context).dividerTheme.color!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              IconData(code, fontFamily: 'MaterialIcons'),
              color: isSelected ? selectedColor : Theme.of(context).textTheme.bodySmall!.color!,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final List<int> colorOptions;
  final int selectedColorValue;
  final ValueChanged<int> onSelected;

  const _ColorPicker({
    required this.colorOptions,
    required this.selectedColorValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colorOptions.map((val) {
        final isSelected = val == selectedColorValue;
        final color = Color(val);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(val);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final List<int> frequencyDays;
  final Color accentColor;
  final ValueChanged<List<int>> onChanged;

  const _FrequencySelector({
    required this.frequencyDays,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isSelected = frequencyDays.contains(i);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            final newDays = List<int>.from(frequencyDays);
            if (isSelected) {
              newDays.remove(i);
            } else {
              newDays.add(i);
            }
            onChanged(newDays);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.2)
                  : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? accentColor : Theme.of(context).dividerTheme.color!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? accentColor : Theme.of(context).textTheme.bodySmall!.color!,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final String? reminderTime;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _ReminderTile({
    required this.reminderTime,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasReminder = reminderTime != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReminder
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Theme.of(context).dividerTheme.color!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.alarm_rounded,
              color: hasReminder ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall!.color!,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                hasReminder
                    ? _formatTime(reminderTime!)
                    : 'Set a daily reminder',
                style: TextStyle(
                  color: hasReminder
                      ? Theme.of(context).textTheme.displayLarge!.color!
                      : Theme.of(context).textTheme.bodySmall!.color!,
                  fontSize: 15,
                ),
              ),
            ),
            if (hasReminder)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 18, color: Theme.of(context).textTheme.bodySmall!.color!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }
}





