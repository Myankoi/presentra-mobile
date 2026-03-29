import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/models/jadwal_model.dart';
import 'jadwal_card.dart';

class JadwalSemuaScreen extends StatefulWidget {
  const JadwalSemuaScreen({super.key});

  @override
  State<JadwalSemuaScreen> createState() => _JadwalSemuaScreenState();
}

class _JadwalSemuaScreenState extends State<JadwalSemuaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _client = ApiClient();

  final List<String> _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  final Map<String, List<Jadwal>> _jadwalMap = {};
  final Map<String, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    final todayIndex = _getTodayIndex();
    _tabController = TabController(length: 5, vsync: this, initialIndex: todayIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadJadwal(_hari[_tabController.index]);
      }
    });
    _loadJadwal(_hari[todayIndex]);
  }

  int _getTodayIndex() {
    final weekday = DateTime.now().weekday;
    return (weekday >= 1 && weekday <= 5) ? weekday - 1 : 0;
  }

  Future<void> _loadJadwal(String hari) async {
    if (_jadwalMap.containsKey(hari)) return;
    setState(() => _loadingMap[hari] = true);
    try {
      final json = await _client.get(ApiConfig.jadwalByHari(hari.toLowerCase()));
      final data = json['data'] as List<dynamic>? ?? [];
      _jadwalMap[hari] = data.map((e) => Jadwal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _jadwalMap[hari] = [];
    }
    if (mounted) setState(() => _loadingMap[hari] = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Jadwal Mengajar'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelStyle: AppTheme.labelBold(context).copyWith(fontSize: 13),
          unselectedLabelStyle: AppTheme.bodySmall(context).copyWith(fontSize: 13),
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: context.colors.textTertiary,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          tabs: _hari.map((h) => Tab(text: h)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _hari.map((hari) => _buildDayTab(hari)).toList(),
      ),
    );
  }

  Widget _buildDayTab(String hari) {
    final isLoading = _loadingMap[hari] == true;
    final jadwalList = _jadwalMap[hari];

    if (isLoading || jadwalList == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    if (jadwalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48,
                color: context.colors.textTertiary.withValues(alpha: 0.5)),
            const SizedBox(height: AppTheme.itemGap),
            Text('Tidak ada jadwal hari $hari', style: AppTheme.bodyMedium(context)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _jadwalMap.remove(hari);
        await _loadJadwal(hari);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.screenPadding, AppTheme.cardPadding,
          AppTheme.screenPadding, AppTheme.sectionGap,
        ),
        itemCount: jadwalList.length,
        itemBuilder: (context, i) => JadwalCard(
          jadwal: jadwalList[i],
          jpNumber: i + 1,
        ),
      ),
    );
  }
}
