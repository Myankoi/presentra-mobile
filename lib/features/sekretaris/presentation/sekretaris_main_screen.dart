import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'beranda_sekretaris_screen.dart';
import 'riwayat_absensi_screen.dart';
import '../../profil/presentation/profil_screen.dart';

class SekretarisMainScreen extends StatefulWidget {
  const SekretarisMainScreen({super.key});

  @override
  State<SekretarisMainScreen> createState() => _SekretarisMainScreenState();
}

class _SekretarisMainScreenState extends State<SekretarisMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BerandaSekretarisScreen(),
    const RiwayatAbsensiScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.divider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_filled),
              ),
              label: 'BERANDA',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.history_rounded),
              ),
              label: 'RIWAYAT',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline_rounded),
              ),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }
}
