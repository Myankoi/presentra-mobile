import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../scan_qr_screen.dart';

/// Floating Bottom Navigation specifically built for Guru dashboard.
/// Features a unique optical notch illusion with a center docked Scan QR button.
class GuruBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GuruBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Container(
        height: 86,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Dark Pill Background
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: colors.navBar,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home_filled, 'Beranda', 0),
                  const SizedBox(width: 72),
                  _buildNavItem(Icons.person_outline_rounded, 'Profil', 2),
                ],
              ),
            ),

            // FAB Center
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQRScreen())),
                child: Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : AppTheme.mediumGray.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 2) {
            onTap(1);
          } else {
            onTap(index);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            if (isSelected)
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
