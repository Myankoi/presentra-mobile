import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/kelas_model.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/filter_chip_row.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../notification/presentation/notification_provider.dart';
import '../../notification/presentation/notifikasi_screen.dart';
import 'piket_provider.dart';
import 'detail_kelas_screen.dart';

class DashboardPiketScreen extends StatefulWidget {
  const DashboardPiketScreen({super.key});

  @override
  State<DashboardPiketScreen> createState() => _DashboardPiketScreenState();
}

class _DashboardPiketScreenState extends State<DashboardPiketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PiketProvider>().loadMonitoring();
      context.read<NotificationProvider>().loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Determine status of a Kelas (selesai / belum)
  String _kelasStatus(Kelas k) {
    if (k.totalSiswa > 0 && k.hadir >= k.totalSiswa) return 'selesai';
    return 'belum';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final piket = context.watch<PiketProvider>();
    final notif = context.watch<NotificationProvider>();
    final rawKelasList = piket.kelasList;

    // Search filter
    final searchedList = _searchQuery.isEmpty
        ? rawKelasList
        : rawKelasList.where((k) =>
            k.namaKelas.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (k.guru ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Status counts
    int selesai = 0, belum = 0;
    for (final k in rawKelasList) {
      if (_kelasStatus(k) == 'selesai') selesai++;
      else belum++;
    }

    // Filter by status chip
    final kelasList = _filterStatus == 'semua'
        ? searchedList
        : searchedList.where((k) => _kelasStatus(k) == _filterStatus).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Dashboard Piket'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.itemGap),
            child: NotificationBell(
              unreadCount: notif.unreadCount,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()))
                    .then((_) => context.read<NotificationProvider>().loadUnreadCount());
              },
            ),
          ),
        ],
      ),
      body: piket.isLoading
          ? const Center(child: CircularProgressIndicator())
          : piket.error != null
              ? _buildError(piket)
              : RefreshIndicator(
                  onRefresh: () => piket.loadMonitoring(),
                  child: _buildBody(context, colors, kelasList, piket, selesai, belum),
                ),
    );
  }

  Widget _buildError(PiketProvider piket) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.danger),
          const SizedBox(height: AppTheme.itemGap),
          Text(piket.error!, style: AppTheme.bodyMedium(context)),
          const SizedBox(height: AppTheme.cardPadding),
          ElevatedButton(onPressed: () => piket.loadMonitoring(), child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppColors colors, List<Kelas> kelasList,
      PiketProvider piket, int selesai, int belum) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date + LIVE Badge ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.cardPadding, AppTheme.screenPadding, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Piket', style: AppTheme.titleLarge(context).copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: AppTheme.bodySmall(context),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('LIVE MONITORING', style: AppTheme.labelBold(context).copyWith(color: AppTheme.success, fontSize: 10, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.screenPadding),

          // ── Stat Cards (Selesai / Belum) ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: Row(
              children: [
                _DashStatCard(label: 'SELESAI', value: selesai, color: AppTheme.success),
                const SizedBox(width: AppTheme.itemGap),
                _DashStatCard(label: 'BELUM', value: belum, color: AppTheme.danger),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sectionGap),

          // ── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari kelas atau guru...',
                prefixIcon: Icon(Icons.search_rounded, color: colors.textTertiary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.cardPadding),

          // ── Status Kelas Header + Filter ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: SectionHeader(
              title: 'Status Kelas',
              trailing: Text('${kelasList.length} kelas', style: AppTheme.bodySmall(context)),
            ),
          ),
          const SizedBox(height: AppTheme.chipGap),

          // ── Filter chips ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: FilterChipRow(
              chips: [
                FilterChipData(label: 'Semua', value: 'semua', count: piket.kelasList.length),
                FilterChipData(label: 'Selesai', value: 'selesai', count: selesai, color: AppTheme.success),
                FilterChipData(label: 'Belum', value: 'belum', count: belum, color: AppTheme.danger),
              ],
              selectedValue: _filterStatus,
              onSelected: (val) => setState(() => _filterStatus = val),
            ),
          ),
          const SizedBox(height: AppTheme.cardPadding),

          // ── Kelas Cards ──────────────────────────────────
          if (kelasList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text(_searchQuery.isNotEmpty ? 'Kelas tidak ditemukan' : 'Belum ada data kelas', style: AppTheme.bodyMedium(context))),
            )
          else
            ...kelasList.map((kelas) => Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 0, AppTheme.screenPadding, AppTheme.itemGap),
              child: _PiketKelasCard(
                kelas: kelas,
                status: _kelasStatus(kelas),
                onTap: () async {
                  if (kelas.id > 0) {
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DetailKelasScreen(kelasId: kelas.id, namaKelas: kelas.namaKelas)));
                    context.read<PiketProvider>().loadMonitoring();
                  }
                },
              ),
            )),
          const SizedBox(height: AppTheme.sectionGap),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Dashboard Stat Card
// ══════════════════════════════════════════════════════════════════

class _DashStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _DashStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(context),
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(label, style: AppTheme.labelBold(context).copyWith(color: color, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text('$value', style: AppTheme.displayLarge(context).copyWith(fontSize: 28, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Piket Kelas Card (richer design)
// ══════════════════════════════════════════════════════════════════

class _PiketKelasCard extends StatelessWidget {
  final Kelas kelas;
  final String status;
  final VoidCallback? onTap;
  const _PiketKelasCard({required this.kelas, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color statusColor;
    final String statusText;
    switch (status) {
      case 'selesai':
        statusColor = AppTheme.success;
        statusText = 'SELESAI';
        break;
      default:
        statusColor = AppTheme.danger;
        statusText = 'BELUM';
    }

    final double progress = kelas.totalSiswa > 0 ? kelas.hadir / kelas.totalSiswa : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.cardPadding),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(context),
          border: Border(left: BorderSide(color: statusColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Class name + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kelas.namaKelas, style: AppTheme.titleMedium(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                StatusBadge(label: statusText, color: statusColor),
              ],
            ),
            const SizedBox(height: AppTheme.chipGap),

            // Row 2: Guru info
            Row(
              children: [
                Icon(
                  kelas.statusGuru == 'hadir' ? Icons.person_rounded : Icons.person_off_rounded,
                  size: 14,
                  color: kelas.statusGuruColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kelas.statusGuru == 'hadir'
                        ? 'Guru: ${kelas.guru ?? '-'}'
                        : 'Guru Belum Check-in',
                    style: AppTheme.bodySmall(context).copyWith(
                      color: kelas.statusGuru == 'hadir' ? colors.textSecondary : AppTheme.danger,
                      fontWeight: kelas.statusGuru != 'hadir' ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.chipGap),

            // Row 3: Attendance bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kehadiran Siswa', style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
                Text(
                  '${kelas.hadir}/${kelas.totalSiswa} (${kelas.persentaseHadir.toStringAsFixed(0)}%)',
                  style: AppTheme.labelBold(context).copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}