import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable section header with title and optional trailing widget (text link, badge).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.titleMedium(context)),
        if (trailing != null)
          trailing!
        else if (trailingText != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailingText!,
              style: AppTheme.labelBold(context).copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }
}

/// A pill-shaped trailing badge for section headers.
class SectionBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionBadge({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall(context).copyWith(
          color: c,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
