import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';

class AddSubjectDialog extends StatefulWidget {
  final Subject? initialSubject;
  final Function(String name, int colorValue, int iconCodePoint) onSave;

  const AddSubjectDialog({
    super.key,
    this.initialSubject,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Subject? initialSubject,
    required Function(String name, int colorValue, int iconCodePoint) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        initialSubject: initialSubject,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  late TextEditingController _nameController;
  late int _selectedColorValue;
  late int _selectedIconCodePoint;
  final _formKey = GlobalKey<FormState>();

  final List<IconData> _availableIcons = const [
    Icons.menu_book_rounded,
    Icons.science_rounded,
    Icons.calculate_rounded,
    Icons.biotech_rounded,
    Icons.auto_stories_rounded,
    Icons.language_rounded,
    Icons.psychology_rounded,
    Icons.computer_rounded,
    Icons.brush_rounded,
    Icons.history_edu_rounded,
    Icons.public_rounded,
    Icons.school_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSubject?.name ?? '');
    _selectedColorValue = widget.initialSubject?.colorValue ?? AppColors.subjectColors.first.toARGB32();
    _selectedIconCodePoint = widget.initialSubject?.iconCodePoint ?? Icons.menu_book_rounded.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialSubject != null;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(20),
      title: Text(
        isEditing ? 'Edit Subject' : 'Add New Subject',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Name Field
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g. Organic Chemistry',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Color Palette Picker
              Text(
                'Color Theme',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.subjectColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = AppColors.subjectColors[index];
                    final isSelected = _selectedColorValue == color.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorValue = color.toARGB32()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 38 : 32,
                        height: isSelected ? 38 : 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: isDark ? Colors.white : AppColors.lightTextPrimary, width: 2.5)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Icon Picker
              Text(
                'Subject Icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableIcons.map((iconData) {
                  final isSelected = _selectedIconCodePoint == iconData.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCodePoint = iconData.codePoint),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColorValue).withValues(alpha: 0.2)
                            : (isDark ? AppColors.darkBackground : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? Color(_selectedColorValue) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(_nameController.text.trim(), _selectedColorValue, _selectedIconCodePoint);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightTextPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            isEditing ? 'Update Subject' : 'Create Subject',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
