import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'sekretaris_provider.dart';
import 'input_absensi_screen.dart';

class RiwayatAbsensiScreen extends StatefulWidget {
  const RiwayatAbsensiScreen({super.key});

  @override
  State<RiwayatAbsensiScreen> createState() => _RiwayatAbsensiScreenState();
}

class _RiwayatAbsensiScreenState extends State<RiwayatAbsensiScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SekretarisProvider>().fetchRecap();
    });
  }

  List<Map<String, dynamic>> _filterByDateRange(List<Map<String, dynamic>> data) {
    if (_startDate == null && _endDate == null) return data;
    return data.where((item) {
      final tgl = item['tanggal'];
      if (tgl == null) return false;
      try {
        final date = DateTime.parse(tgl.toString());
        final normalizedDate = DateTime(date.year, date.month, date.day);
        bool isAfterStart = true;
        if (_startDate != null) {
          final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          isAfterStart = normalizedDate.isAfter(start) || normalizedDate.isAtSameMomentAs(start);
        }
        bool isBeforeEnd = true;
        if (_endDate != null) {
          final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
          isBeforeEnd = normalizedDate.isBefore(end) || normalizedDate.isAtSameMomentAs(end);
        }
        return isAfterStart && isBeforeEnd;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<SekretarisProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Absensi'),
      ),
      body: Column(
        children: [
          // ── Filter Section ──────────────────────────────
          Container(
            width: double.infinity,
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 0, AppTheme.screenPadding, AppTheme.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: colors.divider),
                const SizedBox(height: AppTheme.itemGap),
                Row(
                  children: [
                    Text('FILTER DATA', style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary, fontSize: 10, letterSpacing: 1)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() { _startDate = null; _endDate = null; }),
                      child: Text('Reset', style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.itemGap),
                Row(
                  children: [
                    Expanded(child: _DateSelector(
                      label: 'Tanggal Mulai',
                      date: _startDate,
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (date != null) setState(() => _startDate = date);
                      },
                    )),
                    const SizedBox(width: AppTheme.itemGap),
                    Expanded(child: _DateSelector(
                      label: 'Tanggal Akhir',
                      date: _endDate,
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (date != null) setState(() => _endDate = date);
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.danger),
                            const SizedBox(height: AppTheme.itemGap),
                            Text(provider.error!, style: AppTheme.bodyMedium(context)),
                            const SizedBox(height: AppTheme.cardPadding),
                            ElevatedButton(onPressed: () => provider.fetchRecap(), child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : _buildRecapList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapList(SekretarisProvider provider) {
    final filtered = _filterByDateRange(provider.recapList);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 56, color: context.colors.textTertiary.withValues(alpha: 0.5)),
            const SizedBox(height: AppTheme.itemGap),
            Text('Belum ada data rekap', style: AppTheme.bodyMedium(context)),
            Text('untuk rentang tanggal ini', style: AppTheme.bodySmall(context)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchRecap(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.cardPadding, AppTheme.screenPadding, AppTheme.sectionGap),
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.cardPadding),
              child: Text('Daftar Rekap Harian', style: AppTheme.titleMedium(context)),
            );
          }
          final item = filtered[index - 1];
          return _RecapDayCard(data: item);
        },
      ),
    );
  }
}

// ── Date Selector ─────────────────────────────────────────────────
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: colors.inputBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date!) : label,
              style: AppTheme.bodySmall(context).copyWith(
                fontSize: 11,
                color: date != null ? colors.textSecondary : colors.textTertiary,
              ),
            ),
            Icon(Icons.calendar_today_rounded, size: 14, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Daily Recap Card ──────────────────────────────────────────────
class _RecapDayCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecapDayCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tanggalStr = data['tanggal']?.toString() ?? '';
    String formattedDate = tanggalStr;
    try {
      final date = DateTime.parse(tanggalStr);
      formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
    } catch (_) {}

    final hadir = data['hadir'] ?? 0;
    final izinSakit = data['izinSakit'] ?? 0;
    final alfa = data['alfa'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: context.isDark ? 0.08 : 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 10),
                Text(formattedDate, style: AppTheme.titleMedium(context).copyWith(fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.itemGap),
            child: Row(
              children: [
                _MiniStat(label: 'HADIR', value: '$hadir', color: AppTheme.success),
                const SizedBox(width: AppTheme.itemGap),
                _MiniStat(label: 'IZIN/SAKIT', value: '$izinSakit', color: AppTheme.warning),
                const SizedBox(width: AppTheme.itemGap),
                _MiniStat(label: 'ALFA', value: '$alfa', color: AppTheme.danger),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InputAbsensiScreen(tanggal: tanggalStr))),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lihat Detail Siswa', style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primaryBlue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Badge ───────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Column(
          children: [
            Text(value, style: AppTheme.displayLarge(context).copyWith(fontSize: 22, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.labelBold(context).copyWith(color: color, fontSize: 9, letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}
