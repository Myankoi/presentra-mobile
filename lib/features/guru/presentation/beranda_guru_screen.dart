import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/presentation/auth_provider.dart';
import 'guru_provider.dart';
import 'jadwal_card.dart';
import 'jadwal_semua_screen.dart';
import 'widgets/history_absen_card.dart';
import '../../piket/presentation/dashboard_piket_screen.dart';
import '../../bk/presentation/bk_provider.dart';
import '../../bk/presentation/laporan_rekap_screen.dart';

class BerandaGuruScreen extends StatefulWidget {
  const BerandaGuruScreen({super.key});

  @override
  State<BerandaGuruScreen> createState() => _BerandaGuruScreenState();
}

class _BerandaGuruScreenState extends State<BerandaGuruScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuruProvider>().loadJadwal();
      context.read<GuruProvider>().loadHistoryAbsen();
      context.read<GuruProvider>().loadPiketStatus();
      context.read<AuthProvider>().loadCurrentUser();
      final role = context.read<AuthProvider>().user?.role;
      if (role == 'bk') {
        context.read<BkProvider>().loadStatistik();
      }
    });
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final guru = context.watch<GuruProvider>();
    final namaGuru = auth.user?.displayName ?? 'Guru';
    final stat = guru.statistik;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────
            AppHeader(
              subtitle: auth.user?.role == 'guru' ? 'DASHBOARD GURU' : 'DASHBOARD',
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: IconButton(
                  icon: Icon(Icons.calendar_today_outlined, size: 18, color: colors.textSecondary),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JadwalSemuaScreen())),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            // ── Scrollable Content ────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<GuruProvider>().loadJadwal();
                  await context.read<GuruProvider>().loadHistoryAbsen();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Welcome ─────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greetingText()}, $namaGuru!',
                            style: AppTheme.displayLarge(context).copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                            style: AppTheme.bodyMedium(context).copyWith(
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Stat Cards ──────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'KEHADIRAN',
                              value: '${stat['persentaseHadir'] ?? 0}%',
                              dotColor: AppTheme.success,
                            ),
                          ),
                          const SizedBox(width: AppTheme.itemGap),
                          Expanded(
                            child: StatCard(
                              label: 'KELAS SELESAI',
                              value: '${stat['kelasSelesai'] ?? 0}',
                              total: '/${stat['totalKelas'] ?? 0}',
                              dotColor: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.sectionGap),

                      // ── Piket Banner ────────────────────
                      if (guru.isPiket) ...[
                        _PiketBanner(onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const DashboardPiketScreen()))),
                        const SizedBox(height: AppTheme.sectionGap),
                      ],

                      // ── BK Addon ────────────────────────
                      if (auth.user?.role == 'bk') ...[
                        _BkAddon(),
                        const SizedBox(height: AppTheme.sectionGap),
                      ],

                      // ── Jadwal Mengajar ─────────────────
                      SectionHeader(
                        title: 'Jadwal Mengajar',
                        trailingText: 'Lihat Semua',
                        onTrailingTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const JadwalSemuaScreen())),
                      ),
                      const SizedBox(height: AppTheme.itemGap),

                      if (guru.isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                      else if (guru.jadwalList.isEmpty)
                        EmptyState(
                          icon: Icons.event_busy_rounded,
                          message: 'Tidak ada jadwal hari ini',
                        )
                      else
                        ...guru.jadwalList.map((j) => JadwalCard(jadwal: j)),
                      const SizedBox(height: 32),

                      // ── History Absensi ─────────────────
                      SectionHeader(title: 'Riwayat Kelas Terakhir'),
                      const SizedBox(height: AppTheme.cardPadding),

                      if (guru.historyAbsen.isEmpty)
                        EmptyState(
                          icon: Icons.history_rounded,
                          message: 'Belum ada riwayat kehadiran',
                        )
                      else
                        ...guru.historyAbsen.take(5).map((h) => HistoryAbsenCard(data: h)),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Piket Banner ─────────────────────────────────────────────────
class _PiketBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PiketBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.isDark
              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
              : AppTheme.primaryBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: IgnorePointer(
                  child: Icon(Icons.security_rounded, size: 110,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.screenPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('PIKET AKTIF',
                              style: AppTheme.labelBold(context).copyWith(
                                fontSize: 10, color: Colors.white, letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.itemGap),
                          Text('Jadwal Piket Hari\nIni',
                            style: AppTheme.titleMedium(context).copyWith(fontSize: 18, height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Text('Pukul 06:30 - 07:30',
                            style: AppTheme.bodySmall(context).copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.elevatedShadow(context),
                      ),
                      child: Text('Buka Menu\nPiket',
                        textAlign: TextAlign.center,
                        style: AppTheme.labelBold(context).copyWith(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BK Addon ─────────────────────────────────────────────────────
class _BkAddon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bk = context.watch<BkProvider>();
    final statistik = bk.statistik;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BK Stat Cards
        Row(
          children: [
            Expanded(child: _BkStatCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.danger,
              label: 'Siswa Alfa',
              value: '${statistik['alfa'] ?? 0}',
              unit: 'Siswa',
            )),
            const SizedBox(width: AppTheme.itemGap),
            Expanded(child: _BkStatCard(
              icon: Icons.warning_rounded,
              iconColor: AppTheme.warning,
              label: 'Izin / Sakit',
              value: '${(statistik['izin'] ?? 0) + (statistik['sakit'] ?? 0)}',
              unit: 'Siswa',
            )),
          ],
        ),
        const SizedBox(height: AppTheme.cardPadding),

        // BK CTA Card
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LaporanRekapScreen())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF137FEC), Color(0xFF0A5DBF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.elevatedShadow(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rekap & Laporan\nAbsensi',
                        style: AppTheme.titleMedium(context).copyWith(color: Colors.white, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text('Pantau perkembangan kehadiran siswa secara berkala.',
                        style: AppTheme.bodySmall(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.8), fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.itemGap),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text('Lihat Laporan',
                    style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BkStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _BkStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodySmall(context).copyWith(fontSize: 10)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: AppTheme.titleLarge(context).copyWith(fontSize: 22)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(unit, style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}