import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Pill-shaped status badge with semantic color and label.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: AppTheme.labelBold(context).copyWith(
          color: color,
          fontSize: fontSize ?? 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
