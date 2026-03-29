import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/kelas_model.dart';
import '../../../shared/widgets/status_badge.dart';

class KelasStatusCard extends StatelessWidget {
  final Kelas data;
  final VoidCallback? onTap;

  const KelasStatusCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sudahSelesai = data.hadir >= data.totalSiswa && data.totalSiswa > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.cardPadding),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              alignment: Alignment.center,
              child: Text(
                data.namaKelas.length > 3 ? data.namaKelas.substring(0, 3).toUpperCase() : data.namaKelas.toUpperCase(),
                style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12),
              ),
            ),
            const SizedBox(width: AppTheme.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.namaKelas, style: AppTheme.titleMedium(context).copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${data.hadir} / ${data.totalSiswa} siswa hadir', style: AppTheme.bodySmall(context)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: sudahSelesai ? 'SELESAI' : 'BELUM',
              color: sudahSelesai ? AppTheme.success : AppTheme.danger,
            ),
            const SizedBox(width: AppTheme.chipGap),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}