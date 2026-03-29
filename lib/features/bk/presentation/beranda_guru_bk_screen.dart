import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/initial_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/presentation/auth_provider.dart';
import 'bk_provider.dart';
import '../../profil/presentation/profil_screen.dart';
import 'laporan_rekap_screen.dart';

class BerandaGuruBKScreen extends StatefulWidget {
  const BerandaGuruBKScreen({super.key});

  @override
  State<BerandaGuruBKScreen> createState() => _BerandaGuruBKScreenState();
}

class _BerandaGuruBKScreenState extends State<BerandaGuruBKScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BkProvider>().loadStatistik();
      context.read<BkProvider>().loadTopAlfa();
      context.read<AuthProvider>().loadCurrentUser();
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
    final authProvider = context.watch<AuthProvider>();
    final bkProvider = context.watch<BkProvider>();

    final String namaGuru = authProvider.user?.displayName ?? 'Guru BK';
    final statistik = bkProvider.statistik;
    final topAlfa = bkProvider.topAlfa;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<BkProvider>().loadStatistik();
            await context.read<BkProvider>().loadTopAlfa();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Purple Header ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.screenPadding, AppTheme.screenPadding, AppTheme.sectionGap),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greetingText()},',
                                style: AppTheme.bodyMedium(context).copyWith(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              const SizedBox(height: 2),
                              Text(namaGuru, style: AppTheme.titleLarge(context).copyWith(color: Colors.white, fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                                style: AppTheme.bodySmall(context).copyWith(color: Colors.white.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilScreen())),
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.screenPadding),
                      Row(
                        children: [
                          _buildStatChip(context, label: 'Siswa Alfa', value: '${statistik['totalAlfa'] ?? 0}', icon: Icons.warning_amber_rounded, color: const Color(0xFFF87171)),
                          const SizedBox(width: AppTheme.chipGap),
                          _buildStatChip(context, label: 'Kelas Bermasalah', value: '${statistik['kelasAlfa'] ?? 0}', icon: Icons.class_outlined, color: const Color(0xFFFBBF24)),
                          const SizedBox(width: AppTheme.chipGap),
                          _buildStatChip(context, label: 'Total Hadir', value: '${statistik['totalHadir'] ?? 0}', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF34D399)),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Dashboard BK'),
                      const SizedBox(height: AppTheme.itemGap),
                      Row(
                        children: [
                          Expanded(child: _ActionCard(
                            icon: Icons.bar_chart_rounded,
                            title: 'Rekap & Laporan',
                            subtitle: 'Pantau kehadiran siswa',
                            color: AppTheme.accentPurple,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanRekapScreen())),
                          )),
                          const SizedBox(width: AppTheme.itemGap),
                          Expanded(child: _ActionCard(
                            icon: Icons.people_alt_rounded,
                            title: 'Top Alfa',
                            subtitle: '${topAlfa.length} siswa teratas',
                            color: AppTheme.danger,
                            onTap: () => context.read<BkProvider>().loadTopAlfa(),
                          )),
                        ],
                      ),
                      const SizedBox(height: AppTheme.sectionGap),

                      SectionHeader(
                        title: 'Siswa Alfa Terbanyak',
                        trailing: StatusBadge(label: 'Bulan Ini', color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: AppTheme.itemGap),

                      if (bkProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (topAlfa.isEmpty)
                        EmptyState(icon: Icons.check_circle_outline_rounded, message: 'Tidak ada siswa alfa hari ini')
                      else
                        ...topAlfa.take(5).map((s) => _AlfaStudentCard(siswa: s)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (i) {
          if (i == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanRekapScreen()));
          } else if (i == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilScreen()));
          } else {
            setState(() => _currentNavIndex = i);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, {required String label, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTheme.labelBold(context).copyWith(color: Colors.white, fontSize: 14)),
                Text(label, style: AppTheme.bodySmall(context).copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Card ──────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: context.isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(title, style: AppTheme.titleMedium(context).copyWith(fontSize: 13, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Alfa Student Card ────────────────────────────────────────
class _AlfaStudentCard extends StatelessWidget {
  final Map<String, dynamic> siswa;
  const _AlfaStudentCard({required this.siswa});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int jumlah = siswa['jumlahAlfa'] ?? 0;
    Color badgeColor = jumlah >= 5 ? AppTheme.danger : jumlah >= 3 ? AppTheme.warning : AppTheme.mediumGray;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.chipGap),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          InitialAvatar(
            name: siswa['nama'] ?? 'S',
            size: 36,
            color: badgeColor,
            borderRadius: AppTheme.radiusFull,
          ),
          const SizedBox(width: AppTheme.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(siswa['nama'] ?? '-', style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                Text(siswa['kelas'] ?? '-', style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
              ],
            ),
          ),
          StatusBadge(label: '$jumlah Alpha', color: badgeColor, fontSize: 11),
        ],
      ),
    );
  }
}