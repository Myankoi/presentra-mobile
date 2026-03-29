import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await authProvider.loadCurrentUser();
    if (!mounted) return;

    final user = authProvider.user;
    if (user != null) {
      Navigator.pushReplacementNamed(context, user.homeRoute);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.elevatedShadow(context),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Image.asset(
                    'assets/images/logo_presentra_p_only.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.sectionGap),
              Text(
                'Presentra',
                style: AppTheme.displayLarge(context).copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Sistem Absensi Sekolah Terintegrasi',
                style: AppTheme.bodyMedium(context),
              ),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm / 2),
                    child: LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: colors.divider,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.itemGap),
              Text(
                'DIGITALIZING EDUCATION',
                style: AppTheme.labelBold(context).copyWith(
                  color: colors.textTertiary,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}