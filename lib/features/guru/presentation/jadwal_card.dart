import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/jadwal_model.dart';

/// Shared jadwal card used by both BerandaGuruScreen and JadwalSemuaScreen.
class JadwalCard extends StatelessWidget {
  final Jadwal jadwal;
  final int? jpNumber;
  final VoidCallback? onDetailTap;

  const JadwalCard({
    super.key,
    required this.jadwal,
    this.jpNumber,
    this.onDetailTap,
  });

  String _formatTime(String time) {
    if (time.length >= 5) return time.substring(0, 5);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLive = jadwal.isSedangBerlangsung;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.itemGap),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            border: isLive
                ? const Border(left: BorderSide(color: AppTheme.primaryBlue, width: 6))
                : const Border(left: BorderSide(color: Colors.transparent, width: 6)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDetailTap,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Badge & Time ──────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusBadge(isLive: isLive),
                        Text(
                          '${_formatTime(jadwal.jamMulai)} - ${_formatTime(jadwal.jamSelesai)}',
                          style: AppTheme.labelBold(context).copyWith(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.cardPadding),

                    // ── Bottom Row: JP Block & Subject ─────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Center(
                            child: Text(
                              jpNumber != null ? 'JP\n$jpNumber' : 'JP',
                              textAlign: TextAlign.center,
                              style: AppTheme.labelBold(context).copyWith(
                                fontSize: jpNumber != null ? 14 : 16,
                                color: AppTheme.primaryBlue,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jadwal.mataPelajaran,
                                style: AppTheme.titleMedium(context).copyWith(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelas ${jadwal.kelas}',
                                style: AppTheme.bodyMedium(context).copyWith(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isLive;
  const _StatusBadge({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final bgColor = isLive
        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
        : colors.divider;
    final texColor = isLive
        ? AppTheme.primaryBlue
        : colors.textTertiary;
    final label = isLive ? 'SEDANG BERLANGSUNG' : 'MENDATANG';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTheme.labelBold(context).copyWith(
          fontSize: 9,
          color: texColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}