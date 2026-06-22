import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/domain/models/habit.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';

/// Bottom sheet for adding or editing a habit.
class AddHabitSheet extends StatefulWidget {
  final Habit? existingHabit; // null for new habit

  const AddHabitSheet({super.key, this.existingHabit});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  TimeOfDay? _targetTime;
  int _selectedColorIndex = 0;
  HabitCategory _selectedCategory = HabitCategory.health;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  int _selectedIconIndex = 0;

  static const List<IconData> _habitIcons = [
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.self_improvement_rounded,
    Icons.water_drop_rounded,
    Icons.directions_run_rounded,
    Icons.restaurant_rounded,
    Icons.bedtime_rounded,
    Icons.code_rounded,
    Icons.music_note_rounded,
    Icons.brush_rounded,
    Icons.pets_rounded,
    Icons.eco_rounded,
    Icons.favorite_rounded,
    Icons.school_rounded,
    Icons.savings_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingHabit?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingHabit?.description ?? '',
    );
    if (widget.existingHabit != null) {
      if (widget.existingHabit!.targetTime != null) {
        final parts = widget.existingHabit!.targetTime!.split(':');
        if (parts.length == 2) {
          _targetTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      _selectedColorIndex = widget.existingHabit!.colorIndex;
      _selectedCategory = widget.existingHabit!.category;
      _selectedFrequency = widget.existingHabit!.frequency;
      _selectedIconIndex = _habitIcons.indexWhere(
        (icon) => icon.codePoint == widget.existingHabit!.iconCodePoint,
      );
      if (_selectedIconIndex < 0) _selectedIconIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final repo = context.read<HabitRepository>();
    final habit = Habit(
      id:
          widget.existingHabit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      targetTime: _targetTime != null
          ? '${_targetTime!.hour.toString().padLeft(2, '0')}:${_targetTime!.minute.toString().padLeft(2, '0')}'
          : null,
      iconCodePoint: _habitIcons[_selectedIconIndex].codePoint,
      colorIndex: _selectedColorIndex,
      category: _selectedCategory,
      frequency: _selectedFrequency,
      createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
      completedDates: widget.existingHabit?.completedDates ?? [],
    );

    if (widget.existingHabit != null) {
      repo.updateHabit(habit);
    } else {
      repo.addHabit(habit);
    }

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ───────────────────────────────────────────────
            Text(
              isEditing ? 'Edit Habit' : 'New Habit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // ── Name input ──────────────────────────────────────────
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Habit name (e.g., Morning Run)',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description input ───────────────────────────────────
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // ── Target Time ─────────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Target Time'),
              subtitle: Text(
                _targetTime != null ? _targetTime!.format(context) : 'None set',
              ),
              trailing: _targetTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _targetTime = null),
                    )
                  : null,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _targetTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _targetTime = time);
                }
              },
            ),
            const SizedBox(height: 24),

            // ── Icon picker ─────────────────────────────────────────
            Text('Icon', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_habitIcons.length, (index) {
                final isSelected = _selectedIconIndex == index;
                final color =
                    AppColors
                        .habitColors[_selectedColorIndex %
                            AppColors.habitColors.length];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? color.withValues(alpha: 0.2)
                              : (isDark ? AppColors.cardDarkAlt : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                    ),
                    child: Icon(
                      _habitIcons[index],
                      color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      size: 22,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Color picker ────────────────────────────────────────
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(AppColors.habitColors.length, (index) {
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.habitColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.habitColors[index]
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                              : null,
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                            : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Category picker ─────────────────────────────────────
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  HabitCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.displayName),
                      avatar: Icon(cat.icon, size: 18),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Frequency picker ────────────────────────────────────
            Text('Frequency', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children:
                  HabitFrequency.values.map((freq) {
                    final isSelected = _selectedFrequency == freq;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: freq == HabitFrequency.daily ? 8 : 0,
                          left: freq == HabitFrequency.weekly ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap:
                              () =>
                                  setState(() => _selectedFrequency = freq),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary.withValues(
                                        alpha: 0.15,
                                      )
                                      : (isDark ? AppColors.cardDarkAlt : AppColors.backgroundLight),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                freq == HabitFrequency.daily
                                    ? 'Daily'
                                    : 'Weekly',
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : null,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Update Habit' : 'Create Habit'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
