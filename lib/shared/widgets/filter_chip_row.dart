import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Data model for a single filter chip.
class FilterChipData {
  final String label;
  final String value;
  final int count;
  final Color? color;

  const FilterChipData({
    required this.label,
    required this.value,
    required this.count,
    this.color,
  });
}

/// Horizontally scrollable row of filter chips with count badges.
class FilterChipRow extends StatelessWidget {
  final List<FilterChipData> chips;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.chips,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.asMap().entries.map((entry) {
          final i = entry.key;
          final chip = entry.value;
          final isSelected = chip.value == selectedValue;
          final chipColor = chip.color ?? AppTheme.primaryBlue;

          return Padding(
            padding: EdgeInsets.only(right: i < chips.length - 1 ? AppTheme.chipGap : 0),
            child: GestureDetector(
              onTap: () => onSelected(chip.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor : colors.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: isSelected ? chipColor : colors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chip.label,
                      style: AppTheme.labelBold(context).copyWith(
                        color: isSelected ? Colors.white : colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : chipColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '${chip.count}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : chipColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}
