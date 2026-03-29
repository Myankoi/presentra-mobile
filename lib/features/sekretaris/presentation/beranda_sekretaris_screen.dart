import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../notification/presentation/notification_provider.dart';
import '../../notification/presentation/notifikasi_screen.dart';
import 'sekretaris_provider.dart';
import 'input_absensi_screen.dart';

class BerandaSekretarisScreen extends StatefulWidget {
  const BerandaSekretarisScreen({super.key});

  @override
  State<BerandaSekretarisScreen> createState() => _BerandaSekretarisScreenState();
}

class _BerandaSekretarisScreenState extends State<BerandaSekretarisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadCurrentUser();
      context.read<SekretarisProvider>().fetchDetailHariIni();
      context.read<NotificationProvider>().loadUnreadCount();
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
    final sekretarisProvider = context.watch<SekretarisProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final String namaSekretaris = authProvider.user?.displayName ?? 'Sekretaris';
    final String kelas = authProvider.user?.kelas ?? 'Kelas';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            AppHeader(
              subtitle: 'SEKRETARIS KELAS',
              trailing: NotificationBell(
                unreadCount: notifProvider.unreadCount,
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                  ).then((_) {
                    context.read<NotificationProvider>().loadUnreadCount();
                  });
                },
              ),
            ),

            // ── Scrollable Content ────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<SekretarisProvider>().fetchDetailHariIni(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Blue Banner ─────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.sectionGap),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.elevatedShadow(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greetingText()},',
                              style: AppTheme.bodyMedium(context).copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              namaSekretaris,
                              style: AppTheme.displayLarge(context).copyWith(color: Colors.white, fontSize: 24),
                            ),
                            const SizedBox(height: AppTheme.sectionGap),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: AppTheme.itemGap),
                                Text(
                                  kelas,
                                  style: AppTheme.labelBold(context).copyWith(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Title & Date ────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Ringkasan Hari Ini', style: AppTheme.titleMedium(context)),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                            style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.cardPadding),

                      // ── 2x2 Stats ───────────────────────
                      if (sekretarisProvider.isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                      else ...[
                        Row(
                          children: [
                            Expanded(child: StatCard(label: 'HADIR', value: '${sekretarisProvider.hadir}', total: ' / ${sekretarisProvider.totalSiswa}', dotColor: AppTheme.success)),
                            const SizedBox(width: AppTheme.cardPadding),
                            Expanded(child: StatCard(label: 'IZIN / SAKIT', value: '${sekretarisProvider.izinSakit}', dotColor: AppTheme.warning)),
                          ],
                        ),
                        const SizedBox(height: AppTheme.cardPadding),
                        Row(
                          children: [
                            Expanded(child: StatCard(label: 'ALFA', value: '${sekretarisProvider.alfa}', dotColor: AppTheme.danger)),
                            const SizedBox(width: AppTheme.cardPadding),
                            Expanded(child: StatCard(label: 'TOTAL SISWA', value: '${sekretarisProvider.totalSiswa}', dotColor: AppTheme.primaryBlue)),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppTheme.sectionGap),

                      // ── Warning Box ─────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppTheme.cardPadding),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? AppTheme.warning.withValues(alpha: 0.08)
                              : const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: AppTheme.itemGap),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Peringatan: ',
                                  style: AppTheme.labelBold(context).copyWith(color: const Color(0xFFB45309), fontSize: 11),
                                  children: [
                                    TextSpan(
                                      text: 'Batas pengisian absensi hanya\nsampai pukul 07.30 WIB.',
                                      style: AppTheme.bodyMedium(context).copyWith(
                                        color: context.isDark ? AppTheme.warning : const Color(0xFF92400E),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.sectionGap),

                      // ── Main Action Button ──────────────
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const InputAbsensiScreen()),
                          ).then((_) => context.read<SekretarisProvider>().fetchDetailHariIni());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.cardPadding),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: AppTheme.elevatedShadow(context),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: AppTheme.cardPadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Isi Absensi', style: AppTheme.titleMedium(context).copyWith(color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text('PRESENSI KEHADIRAN SISWA',
                                      style: AppTheme.labelBold(context).copyWith(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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