import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable top header bar with logo, title, subtitle, and trailing action.
/// Used by Beranda Guru and Beranda Sekretaris.
class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const AppHeader({
    super.key,
    this.title = 'Presentra',
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.screenPadding, AppTheme.screenPadding,
        AppTheme.screenPadding, AppTheme.screenPadding,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_presentra_p_only.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.itemGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleMedium(context).copyWith(fontSize: 18),
              ),
              Text(
                subtitle,
                style: AppTheme.labelBold(context).copyWith(
                  fontSize: 10,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
