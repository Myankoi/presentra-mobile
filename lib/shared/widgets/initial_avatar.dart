import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Circle or rounded-rect avatar displaying name initials.
class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  final double? fontSize;
  final double? borderRadius;

  const InitialAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.color,
    this.fontSize,
    this.borderRadius,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty
        ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryBlue;
    final radius = borderRadius ?? (AppTheme.radiusSm + 2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.withValues(alpha: 0.15),
            c.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTheme.titleMedium(context).copyWith(
          color: c,
          fontSize: fontSize ?? (size * 0.36),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
