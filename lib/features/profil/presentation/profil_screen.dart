import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/initial_avatar.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  String _roleLabel(String? role) {
    return switch (role) {
      'guru' => 'Guru',
      'bk' => 'Guru BK',
      'sekretaris' => 'Sekretaris Kelas',
      'piket' => 'Petugas Piket',
      _ => 'Pengguna',
    };
  }

  Color _roleColor(String? role) {
    return switch (role) {
      'guru' => AppTheme.primaryBlue,
      'bk' => AppTheme.accentPurple,
      'sekretaris' => AppTheme.accentOrange,
      _ => AppTheme.primaryGreen,
    };
  }

  Future<void> _logout(BuildContext context) async {
    final colors = context.colors;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Logout', style: AppTheme.titleMedium(ctx)),
        content: Text('Apakah Anda yakin ingin keluar?', style: AppTheme.bodyMedium(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTheme.bodyMedium(ctx).copyWith(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roleColor = _roleColor(user.role);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Avatar + Name + Role Badge ──────────────────
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              child: Column(
                children: [
                  InitialAvatar(
                    name: user.displayName,
                    size: 72,
                    color: roleColor,
                    borderRadius: AppTheme.radiusFull,
                  ),
                  const SizedBox(height: AppTheme.cardPadding),
                  Text(
                    user.displayName,
                    style: AppTheme.titleLarge(context).copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      _roleLabel(user.role),
                      style: AppTheme.labelBold(context).copyWith(
                        color: roleColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Rows ────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.cardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.chipGap),
                    child: Text('INFORMASI AKUN', style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary, letterSpacing: 1, fontSize: 10)),
                  ),
                  Divider(height: 1, color: colors.divider),
                  _InfoRow(icon: Icons.person_outline_rounded, label: 'Nama Lengkap', value: user.nama),
                  Divider(height: 1, indent: 52, color: colors.divider),
                  _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
                  Divider(height: 1, indent: 52, color: colors.divider),
                  _InfoRow(icon: Icons.work_outline_rounded, label: 'Jabatan', value: _roleLabel(user.role)),
                  if (user.kelas != null && user.kelas!.isNotEmpty) ...[
                    Divider(height: 1, indent: 52, color: colors.divider),
                    _InfoRow(icon: Icons.class_outlined, label: 'Kelas', value: user.kelas!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.cardPadding),

            // ── System Section ────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.cardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.cardPadding, AppTheme.chipGap),
                    child: Text('SISTEM', style: AppTheme.labelBold(context).copyWith(color: colors.textTertiary, letterSpacing: 1, fontSize: 10)),
                  ),
                  Divider(height: 1, color: colors.divider),
                  _InfoRow(icon: Icons.info_outline_rounded, label: 'Versi Aplikasi', value: 'v1.0.0'),
                  Divider(height: 1, indent: 52, color: colors.divider),
                  _InfoRow(icon: Icons.security_rounded, label: 'Terakhir Login', value: 'Hari ini'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.cardPadding),

            // ── Logout Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 0, AppTheme.screenPadding, 32),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                  label: Text(
                    'Keluar dari Akun',
                    style: AppTheme.bodyMedium(context).copyWith(color: AppTheme.danger, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.danger, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.cardPadding, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: AppTheme.cardPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}