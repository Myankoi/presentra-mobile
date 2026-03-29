import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryAbsenCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const HistoryAbsenCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tanggal = data['tanggal']?.toString() ?? '';
    final waktu = data['waktu']?.toString() ?? data['createdAt']?.toString() ?? '';
    final kelas = data['kelas']?.toString() ?? data['namaKelas']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'hadir';

    String formattedDate = tanggal;
    try {
      final date = DateTime.parse(tanggal);
      formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (_) {}

    final isHadir = status == 'hadir';
    final statusColor = isHadir ? AppTheme.success : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              isHadir ? Icons.check_circle_outline_rounded : Icons.access_time_rounded,
              size: 18, color: statusColor,
            ),
          ),
          const SizedBox(width: AppTheme.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: AppTheme.titleMedium(context).copyWith(fontSize: 13)),
                if (kelas.isNotEmpty)
                  Text(kelas, style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
              ],
            ),
          ),
          if (waktu.isNotEmpty)
            Text(waktu, style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
          const SizedBox(width: AppTheme.chipGap),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isHadir ? 'Hadir' : status[0].toUpperCase() + status.substring(1),
              style: AppTheme.labelBold(context).copyWith(fontSize: 10, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
