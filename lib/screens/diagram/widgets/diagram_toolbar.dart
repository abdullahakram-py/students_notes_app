import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/diagram_model.dart';
import '../../../providers/diagram_provider.dart';

class DiagramToolbar extends ConsumerWidget {
  const DiagramToolbar({super.key});

  final List<Color> _palette = const [
    Color(0xFF212121), // Black
    Color(0xFFD32F2F), // Red
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFFFA000), // Amber / Yellow
    Color(0xFF7B1FA2), // Purple
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagramProvider);
    final notifier = ref.read(diagramProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Tool Selectors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolBtn(
                  icon: Icons.edit_rounded,
                  label: 'Pen',
                  isSelected: state.selectedTool == DiagramToolType.pen,
                  onTap: () => notifier.setTool(DiagramToolType.pen),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildToolBtn(
                  icon: Icons.crop_square_rounded,
                  label: 'Rect',
                  isSelected: state.selectedTool == DiagramToolType.rectangle,
                  onTap: () => notifier.setTool(DiagramToolType.rectangle),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildToolBtn(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'Circle',
                  isSelected: state.selectedTool == DiagramToolType.circle,
                  onTap: () => notifier.setTool(DiagramToolType.circle),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildToolBtn(
                  icon: Icons.horizontal_rule_rounded,
                  label: 'Line',
                  isSelected: state.selectedTool == DiagramToolType.line,
                  onTap: () => notifier.setTool(DiagramToolType.line),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildToolBtn(
                  icon: Icons.arrow_right_alt_rounded,
                  label: 'Arrow',
                  isSelected: state.selectedTool == DiagramToolType.arrow,
                  onTap: () => notifier.setTool(DiagramToolType.arrow),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildToolBtn(
                  icon: Icons.text_fields_rounded,
                  label: 'Label',
                  isSelected: state.selectedTool == DiagramToolType.text,
                  onTap: () => notifier.setTool(DiagramToolType.text),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 2: Color Palette + Stroke Width
          Row(
            children: [
              // Colors
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _palette.map((color) {
                      final isSelected = state.selectedColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () => notifier.setColor(color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.lightPrimaryDark)
                                  : Colors.transparent,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Stroke Width Slider
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.line_weight_rounded, size: 16),
                  SizedBox(
                    width: 90,
                    child: Slider(
                      value: state.strokeWidth,
                      min: 1.0,
                      max: 8.0,
                      divisions: 7,
                      activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      onChanged: (val) => notifier.setStrokeWidth(val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolBtn({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final activeBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
