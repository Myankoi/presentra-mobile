import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/initial_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_chip_row.dart';
import '../../../shared/widgets/section_header.dart';
import '../../notification/presentation/notification_provider.dart';
import '../../notification/presentation/notifikasi_screen.dart';
import 'piket_provider.dart';

class DetailKelasScreen extends StatefulWidget {
  final dynamic kelasId;
  final String? namaKelas;
  const DetailKelasScreen({super.key, required this.kelasId, this.namaKelas});

  @override
  State<DetailKelasScreen> createState() => _DetailKelasScreenState();
}

class _DetailKelasScreenState extends State<DetailKelasScreen> {
  String _filterStatus = 'semua';
  bool _showAll = false;
  static const int _previewCount = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PiketProvider>().loadDetailKelas(widget.kelasId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final piketProvider = context.watch<PiketProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final detail = piketProvider.detailKelas;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.namaKelas ?? 'Detail Kelas'),
            Text(
              DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now()),
              style: AppTheme.bodySmall(context).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.cardPadding),
            child: NotificationBell(
              unreadCount: notifProvider.unreadCount,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()))
                    .then((_) => context.read<NotificationProvider>().loadUnreadCount());
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: piketProvider.isLoadingDetail
            ? const Center(child: CircularProgressIndicator())
            : detail == null
                ? _buildError(piketProvider.error)
                : RefreshIndicator(
                    onRefresh: () => context.read<PiketProvider>().loadDetailKelas(widget.kelasId),
                    child: _buildContent(detail),
                  ),
      ),
    );
  }

  Widget _buildError(String? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.danger),
          const SizedBox(height: AppTheme.itemGap),
          Text(error ?? 'Gagal memuat data kelas', style: AppTheme.bodyMedium(context)),
          const SizedBox(height: AppTheme.cardPadding),
          ElevatedButton(
            onPressed: () => context.read<PiketProvider>().loadDetailKelas(widget.kelasId),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> detail) {
    final colors = context.colors;
    final jadwal = detail['jadwal'] as List<dynamic>? ?? [];
    final siswaAll = detail['listSiswa'] as List<dynamic>? ?? [];
    final rekap = detail['rekapAbsen'] as Map<String, dynamic>? ?? {};

    List<dynamic> filteredSiswa;
    if (_filterStatus == 'semua') {
      filteredSiswa = siswaAll;
    } else if (_filterStatus == 'belum') {
      filteredSiswa = siswaAll.where((s) => s['statusAbsen'] == null).toList();
    } else {
      filteredSiswa = siswaAll.where((s) => (s['statusAbsen'] as String?) == _filterStatus).toList();
    }

    final displaySiswa = _showAll ? filteredSiswa : filteredSiswa.take(_previewCount).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.screenPadding),

          // ── Jadwal Section ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: SectionHeader(
              title: 'Mata Pelajaran Hari Ini',
              trailing: StatusBadge(label: '${jadwal.length} Sesi', color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: AppTheme.cardPadding),

          if (jadwal.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              padding: const EdgeInsets.fromLTRB(0, AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.cardShadow(context),
              ),
              child: Column(
                children: List.generate(jadwal.length, (i) => _TimelineItem(
                  jadwal: jadwal[i] as Map<String, dynamic>,
                  isLast: i == jadwal.length - 1,
                )),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: EmptyState(icon: Icons.event_busy_rounded, message: 'Tidak ada jadwal hari ini'),
            ),
          const SizedBox(height: AppTheme.sectionGap),

          // ── Stat Bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: Row(
              children: [
                _StatBox(label: 'HADIR', value: '${rekap['hadir'] ?? 0}', color: AppTheme.success),
                const SizedBox(width: AppTheme.itemGap),
                _StatBox(label: 'IZIN', value: '${rekap['izin'] ?? 0}', color: AppTheme.warning),
                const SizedBox(width: AppTheme.itemGap),
                _StatBox(label: 'SAKIT', value: '${rekap['sakit'] ?? 0}', color: AppTheme.accentOrange),
                const SizedBox(width: AppTheme.itemGap),
                _StatBox(label: 'ALFA', value: '${rekap['alfa'] ?? 0}', color: AppTheme.danger),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sectionGap),

          // ── Siswa Header ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: Text('Kehadiran Siswa', style: AppTheme.titleMedium(context)),
          ),
          const SizedBox(height: AppTheme.itemGap),

          // ── Filter Chips ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: FilterChipRow(
              chips: [
                FilterChipData(label: 'Semua', value: 'semua', count: siswaAll.length),
                FilterChipData(label: 'Hadir', value: 'hadir', count: rekap['hadir'] ?? 0, color: AppTheme.success),
                FilterChipData(label: 'Izin', value: 'izin', count: rekap['izin'] ?? 0, color: AppTheme.warning),
                FilterChipData(label: 'Sakit', value: 'sakit', count: rekap['sakit'] ?? 0, color: AppTheme.accentOrange),
                FilterChipData(label: 'Alfa', value: 'alfa', count: rekap['alfa'] ?? 0, color: AppTheme.danger),
                FilterChipData(label: 'Belum', value: 'belum', count: rekap['belum'] ?? 0, color: AppTheme.mediumGray),
              ],
              selectedValue: _filterStatus,
              onSelected: (val) => setState(() { _filterStatus = val; _showAll = false; }),
            ),
          ),
          const SizedBox(height: AppTheme.cardPadding),

          // ── Siswa List ──────────────────────────────────
          if (filteredSiswa.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding, vertical: AppTheme.sectionGap),
              child: EmptyState(icon: Icons.people_outline_rounded, message: 'Tidak ada siswa dengan status ini'),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Column(
                children: displaySiswa.map((s) => _SiswaCard(siswa: s as Map<String, dynamic>)).toList(),
              ),
            ),

          // ── Show All / Hide ─────────────────────────────
          if (filteredSiswa.length > _previewCount)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showAll ? 'Sembunyikan' : 'Lihat Semua Siswa (${filteredSiswa.length})',
                        style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _showAll ? Icons.keyboard_arrow_up_rounded : Icons.arrow_forward_rounded,
                        color: AppTheme.primaryBlue, size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Stat Box ─────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          children: [
            Text(label, style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary, fontSize: 9, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(value, style: AppTheme.titleLarge(context).copyWith(color: color, fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

// ── Timeline Item (matching reference design) ───────────────────────
class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> jadwal;
  final bool isLast;
  const _TimelineItem({required this.jadwal, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final jamMulai = jadwal['jamMulai'] as String? ?? '';
    final jamSelesai = jadwal['jamSelesai'] as String? ?? '';
    final namaMapel = jadwal['namaMapel'] as String? ?? 'Pelajaran';
    final namaGuru = jadwal['namaGuru'] as String? ?? '-';

    String timeDisplay = jamMulai.length >= 5 ? jamMulai.substring(0, 5) : jamMulai;

    final now = TimeOfDay.now();
    bool isLive = false;
    bool isSelesai = false;
    int sisaMenit = 0;
    try {
      final startParts = jamMulai.split(':');
      final endParts = jamSelesai.split(':');
      if (startParts.length >= 2 && endParts.length >= 2) {
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        final nowMinutes = now.hour * 60 + now.minute;
        isLive = nowMinutes >= startMinutes && nowMinutes < endMinutes;
        isSelesai = nowMinutes >= endMinutes;
        if (isLive) sisaMenit = endMinutes - nowMinutes;
      }
    } catch (_) {}

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: AppTheme.cardPadding, top: 2),
              child: Text(timeDisplay,
                style: AppTheme.labelBold(context).copyWith(
                  color: isLive ? AppTheme.primaryBlue : colors.textTertiary,
                  fontSize: 12,
                  fontWeight: isLive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),

          // Timeline dots & line
          Column(
            children: [
              const SizedBox(height: 4),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: isLive ? AppTheme.primaryBlue : (isSelesai ? AppTheme.success : colors.divider),
                  shape: BoxShape.circle,
                  border: isLive ? Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 3) : null,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: isSelesai ? AppTheme.success.withValues(alpha: 0.3) : colors.divider)),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: isLive ? const EdgeInsets.all(12) : EdgeInsets.zero,
              decoration: isLive
                  ? BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: context.isDark ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(namaMapel,
                              style: AppTheme.titleMedium(context).copyWith(
                                color: isLive ? AppTheme.primaryBlue : colors.textPrimary,
                                fontSize: 14,
                                fontWeight: isLive ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(namaGuru, style: AppTheme.bodySmall(context).copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('LIVE', style: AppTheme.labelBold(context).copyWith(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        )
                      else if (isSelesai)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18)
                      else
                        Icon(Icons.access_time_rounded, color: colors.divider, size: 18),
                    ],
                  ),
                  // "Berakhir dalam X menit" for live session
                  if (isLive && sisaMenit > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 13, color: AppTheme.primaryBlue.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Berakhir dalam $sisaMenit menit',
                          style: AppTheme.bodySmall(context).copyWith(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Siswa Card ──────────────────────────────────────────────────────
class _SiswaCard extends StatelessWidget {
  final Map<String, dynamic> siswa;
  const _SiswaCard({required this.siswa});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nama = siswa['namaSiswa'] as String? ?? siswa['nama'] as String? ?? '-';
    final nis = siswa['nis'] as String? ?? '-';
    final status = (siswa['statusAbsen'] as String? ?? siswa['status'] as String?)?.toLowerCase();
    final keterangan = siswa['keterangan'] as String?;

    final Color color;
    final String label;
    final String subtitle;
    switch (status) {
      case 'hadir':
        color = AppTheme.success; label = 'HADIR'; subtitle = '✓ Tercatat'; break;
      case 'izin':
        color = AppTheme.warning; label = 'IZIN'; subtitle = keterangan ?? 'Izin'; break;
      case 'sakit':
        color = AppTheme.accentOrange; label = 'SAKIT'; subtitle = keterangan ?? 'Sakit'; break;
      case 'alfa':
        color = AppTheme.danger; label = 'ALFA'; subtitle = 'Tanpa keterangan'; break;
      case 'terlambat':
        color = AppTheme.warning; label = 'TERLAMBAT'; subtitle = keterangan ?? 'Terlambat'; break;
      default:
        color = AppTheme.mediumGray; label = 'BELUM'; subtitle = 'Belum diabsen';
    }

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
          InitialAvatar(name: nama, size: 44, fontSize: 16),
          const SizedBox(width: AppTheme.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: AppTheme.titleMedium(context).copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('NIS: $nis', style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: label, color: color),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTheme.bodySmall(context).copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}