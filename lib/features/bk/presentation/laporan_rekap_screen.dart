import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'bk_provider.dart';

enum _FilterMode { bulanIni, pilihBulan, rentangTanggal, semester }

class LaporanRekapScreen extends StatefulWidget {
  const LaporanRekapScreen({super.key});

  @override
  State<LaporanRekapScreen> createState() => _LaporanRekapScreenState();
}

class _LaporanRekapScreenState extends State<LaporanRekapScreen> {
  _FilterMode _mode = _FilterMode.bulanIni;
  String? _selectedKelasName;

  int _selectedBulan = DateTime.now().month;
  int _selectedTahun = DateTime.now().year;
  DateTime? _startDate;
  DateTime? _endDate;
  int _semesterType = 1;
  int _semesterTahun = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Map<String, dynamic> _getFilters() {
    int? bulan;
    int? tahun;
    String? startDate;
    String? endDate;

    switch (_mode) {
      case _FilterMode.bulanIni:
        bulan = DateTime.now().month;
        tahun = DateTime.now().year;
        break;
      case _FilterMode.pilihBulan:
        bulan = _selectedBulan;
        tahun = _selectedTahun;
        break;
      case _FilterMode.rentangTanggal:
        if (_startDate != null && _endDate != null) {
          startDate = DateFormat('yyyy-MM-dd').format(_startDate!);
          endDate = DateFormat('yyyy-MM-dd').format(_endDate!);
        }
        break;
      case _FilterMode.semester:
        if (_semesterType == 1) {
          startDate = '$_semesterTahun-07-01';
          endDate = '$_semesterTahun-12-31';
        } else {
          startDate = '$_semesterTahun-01-01';
          endDate = '$_semesterTahun-06-30';
        }
        break;
    }
    return {'bulan': bulan, 'tahun': tahun, 'startDate': startDate, 'endDate': endDate};
  }

  void _fetchData() {
    final filters = _getFilters();
    context.read<BkProvider>().loadRekap(
      bulan: filters['bulan'] as int?,
      tahun: filters['tahun'] as int?,
      startDate: filters['startDate'] as String?,
      endDate: filters['endDate'] as String?,
    );
  }

  Future<void> _exportToExcel() async {
    final provider = context.read<BkProvider>();
    final filters = _getFilters();
    final path = await provider.downloadLaporan(
      bulan: filters['bulan'] as int?,
      tahun: filters['tahun'] as int?,
      startDate: filters['startDate'] as String?,
      endDate: filters['endDate'] as String?,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(path != null ? 'Laporan diunduh: $path' : 'Gagal mengekspor laporan'),
          backgroundColor: path != null ? AppTheme.success : AppTheme.danger,
          duration: const Duration(seconds: 4),
          action: path != null ? SnackBarAction(label: 'Buka', textColor: Colors.white, onPressed: () => OpenFilex.open(path)) : null,
        ),
      );
    }
  }

  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  List<Map<String, dynamic>> _getAggregatedKelas(List<Map<String, dynamic>> rows) {
    final Map<String, Map<String, dynamic>> classMap = {};
    for (var siswa in rows) {
      final String kelas = siswa['namaKelas']?.toString() ?? 'Tidak Diketahui';
      if (!classMap.containsKey(kelas)) {
        classMap[kelas] = {'namaKelas': kelas, 'hadir': 0, 'izin': 0, 'sakit': 0, 'alfa': 0, 'totalSiswa': 0};
      }
      classMap[kelas]!['hadir'] = (classMap[kelas]!['hadir'] as int) + _toInt(siswa['hadir']);
      classMap[kelas]!['izin'] = (classMap[kelas]!['izin'] as int) + _toInt(siswa['izin']);
      classMap[kelas]!['sakit'] = (classMap[kelas]!['sakit'] as int) + _toInt(siswa['sakit']);
      classMap[kelas]!['alfa'] = (classMap[kelas]!['alfa'] as int) + _toInt(siswa['alfa']);
      classMap[kelas]!['totalSiswa'] = (classMap[kelas]!['totalSiswa'] as int) + 1;
    }
    final list = classMap.values.toList();
    list.sort((a, b) => (a['namaKelas'] as String).compareTo(b['namaKelas'] as String));
    return list;
  }

  List<String> _getUniqueKelasNames(List<Map<String, dynamic>> rows) {
    final names = rows.map((r) => r['namaKelas']?.toString() ?? '').where((n) => n.isNotEmpty).toSet().toList();
    names.sort();
    return names;
  }

  String get _periodeText {
    switch (_mode) {
      case _FilterMode.bulanIni:
        return DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
      case _FilterMode.pilihBulan:
        return DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_selectedTahun, _selectedBulan));
      case _FilterMode.rentangTanggal:
        if (_startDate != null && _endDate != null) {
          return '${DateFormat('d MMM', 'id_ID').format(_startDate!)} — ${DateFormat('d MMM yyyy', 'id_ID').format(_endDate!)}';
        }
        return 'Pilih rentang tanggal';
      case _FilterMode.semester:
        return _semesterType == 1
            ? 'Semester Ganjil $_semesterTahun (Jul-Des)'
            : 'Semester Genap $_semesterTahun (Jan-Jun)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<BkProvider>();
    final allRows = provider.rekapLaporan;

    final filteredRows = _selectedKelasName == null
        ? allRows
        : allRows.where((r) => r['namaKelas'] == _selectedKelasName).toList();

    final aggregatedClasses = _getAggregatedKelas(filteredRows);
    final kelasNames = _getUniqueKelasNames(allRows);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Rekap Laporan Absensi')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filter Section ─────────────────────────────────
            Container(
              color: colors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.cardPadding, AppTheme.screenPadding, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _ModeChip(label: 'Bulan Ini', icon: Icons.today_rounded, selected: _mode == _FilterMode.bulanIni, onTap: () { setState(() => _mode = _FilterMode.bulanIni); _fetchData(); }),
                          const SizedBox(width: AppTheme.chipGap),
                          _ModeChip(label: 'Pilih Bulan', icon: Icons.calendar_month_rounded, selected: _mode == _FilterMode.pilihBulan, onTap: () { setState(() => _mode = _FilterMode.pilihBulan); _showBulanPicker(); }),
                          const SizedBox(width: AppTheme.chipGap),
                          _ModeChip(label: 'Rentang Tanggal', icon: Icons.date_range_rounded, selected: _mode == _FilterMode.rentangTanggal, onTap: () { setState(() => _mode = _FilterMode.rentangTanggal); _showDateRangePicker(); }),
                          const SizedBox(width: AppTheme.chipGap),
                          _ModeChip(label: 'Semester', icon: Icons.school_rounded, selected: _mode == _FilterMode.semester, onTap: () { setState(() => _mode = _FilterMode.semester); _showSemesterPicker(); }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 14, AppTheme.screenPadding, AppTheme.cardPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Periode', style: AppTheme.bodySmall(context).copyWith(fontSize: 10, color: colors.textTertiary)),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () {
                                  if (_mode == _FilterMode.pilihBulan) _showBulanPicker();
                                  if (_mode == _FilterMode.rentangTanggal) _showDateRangePicker();
                                  if (_mode == _FilterMode.semester) _showSemesterPicker();
                                },
                                child: Row(
                                  children: [
                                    Flexible(child: Text(_periodeText, style: AppTheme.titleMedium(context).copyWith(fontSize: 14), overflow: TextOverflow.ellipsis)),
                                    if (_mode != _FilterMode.bulanIni) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit_rounded, size: 14, color: AppTheme.primaryBlue),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showKelasFilter(kelasNames),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedKelasName != null ? AppTheme.primaryBlue.withValues(alpha: 0.1) : colors.card,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(color: _selectedKelasName != null ? AppTheme.primaryBlue : colors.inputBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.class_rounded, size: 14, color: _selectedKelasName != null ? AppTheme.primaryBlue : colors.textTertiary),
                                const SizedBox(width: 6),
                                Text(_selectedKelasName ?? 'Semua Kelas', style: AppTheme.labelBold(context).copyWith(color: _selectedKelasName != null ? AppTheme.primaryBlue : colors.textSecondary, fontSize: 12)),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _selectedKelasName != null ? AppTheme.primaryBlue : colors.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Content List ────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : aggregatedClasses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assessment_outlined, size: 48, color: colors.textTertiary.withValues(alpha: 0.5)),
                              const SizedBox(height: AppTheme.itemGap),
                              Text('Tidak ada data rekap absen', style: AppTheme.bodyMedium(context)),
                              const SizedBox(height: 4),
                              Text(_periodeText, style: AppTheme.bodySmall(context)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _fetchData(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.screenPadding),
                            itemCount: aggregatedClasses.length,
                            itemBuilder: (context, index) => _KelasRekapCard(kelas: aggregatedClasses[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppTheme.screenPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: provider.isDownloading || provider.isLoading ? null : _exportToExcel,
          child: provider.isDownloading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.file_download_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('Ekspor ke Excel', style: AppTheme.titleMedium(context).copyWith(color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Bottom Sheet Pickers
  // ══════════════════════════════════════════════════════════════

  void _showBulanPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _BulanPickerSheet(
        selectedBulan: _selectedBulan,
        selectedTahun: _selectedTahun,
        onConfirm: (bulan, tahun) {
          setState(() { _selectedBulan = bulan; _selectedTahun = tahun; });
          _fetchData();
        },
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() { _startDate = picked.start; _endDate = picked.end; });
      _fetchData();
    }
  }

  void _showSemesterPicker() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              child: Text('Pilih Semester', style: AppTheme.titleMedium(context).copyWith(fontSize: 18)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () { setState(() => _semesterTahun--); Navigator.pop(ctx); _showSemesterPicker(); }),
                Text('$_semesterTahun', style: AppTheme.titleMedium(context).copyWith(fontSize: 18)),
                IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () { setState(() => _semesterTahun++); Navigator.pop(ctx); _showSemesterPicker(); }),
              ],
            ),
            const SizedBox(height: 8),
            _SemesterOption(title: 'Semester Ganjil', subtitle: 'Juli — Desember $_semesterTahun', selected: _semesterType == 1, onTap: () { setState(() => _semesterType = 1); Navigator.pop(ctx); _fetchData(); }),
            _SemesterOption(title: 'Semester Genap', subtitle: 'Januari — Juni $_semesterTahun', selected: _semesterType == 2, onTap: () { setState(() => _semesterType = 2); Navigator.pop(ctx); _fetchData(); }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showKelasFilter(List<String> kelasNames) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              child: Text('Pilih Kelas', style: AppTheme.titleMedium(context).copyWith(fontSize: 18)),
            ),
            ListTile(
              leading: Icon(Icons.select_all_rounded, color: _selectedKelasName == null ? AppTheme.primaryBlue : colors.textTertiary),
              title: const Text('Semua Kelas'),
              selected: _selectedKelasName == null,
              onTap: () { setState(() => _selectedKelasName = null); Navigator.pop(ctx); },
            ),
            ...kelasNames.map((name) => ListTile(
              leading: Icon(Icons.class_rounded, color: _selectedKelasName == name ? AppTheme.primaryBlue : colors.textTertiary),
              title: Text(name),
              selected: _selectedKelasName == name,
              onTap: () { setState(() => _selectedKelasName = name); Navigator.pop(ctx); },
            )),
            const SizedBox(height: AppTheme.cardPadding),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Sub-Widgets
// ══════════════════════════════════════════════════════════════

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue : colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: selected ? AppTheme.primaryBlue : colors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : colors.textTertiary),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.labelBold(context).copyWith(color: selected ? Colors.white : colors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SemesterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _SemesterOption({required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
      leading: Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppTheme.primaryBlue : colors.textTertiary),
      title: Text(title, style: AppTheme.titleMedium(context).copyWith(fontSize: 15)),
      subtitle: Text(subtitle, style: AppTheme.bodySmall(context)),
      onTap: onTap,
    );
  }
}

class _BulanPickerSheet extends StatefulWidget {
  final int selectedBulan;
  final int selectedTahun;
  final void Function(int bulan, int tahun) onConfirm;
  const _BulanPickerSheet({required this.selectedBulan, required this.selectedTahun, required this.onConfirm});

  @override
  State<_BulanPickerSheet> createState() => _BulanPickerSheetState();
}

class _BulanPickerSheetState extends State<_BulanPickerSheet> {
  late int _bulan;
  late int _tahun;

  @override
  void initState() {
    super.initState();
    _bulan = widget.selectedBulan;
    _tahun = widget.selectedTahun;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            child: Text('Pilih Bulan', style: AppTheme.titleMedium(context).copyWith(fontSize: 18)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => setState(() => _tahun--)),
              Text('$_tahun', style: AppTheme.titleMedium(context).copyWith(fontSize: 18)),
              IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => setState(() => _tahun++)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _bulan;
                return GestureDetector(
                  onTap: () { Navigator.pop(context); widget.onConfirm(month, _tahun); },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : colors.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: isSelected ? AppTheme.primaryBlue : colors.inputBorder),
                    ),
                    child: Text(
                      DateFormat.MMM('id_ID').format(DateTime(_tahun, month)),
                      style: AppTheme.labelBold(context).copyWith(color: isSelected ? Colors.white : colors.textSecondary, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.sectionGap),
        ],
      ),
    );
  }
}

// ── Per-Class Rekap Card ───────────────────────────────────────
class _KelasRekapCard extends StatelessWidget {
  final Map<String, dynamic> kelas;
  const _KelasRekapCard({required this.kelas});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    int totalSiswa = kelas['totalSiswa'] as int;
    int hadir = kelas['hadir'] as int;
    int izin = kelas['izin'] as int;
    int sakit = kelas['sakit'] as int;
    int alfa = kelas['alfa'] as int;
    int totalEncounters = hadir + izin + sakit + alfa;
    double pHadir = totalEncounters > 0 ? (hadir / totalEncounters * 100) : 0;
    double pIzinSakit = totalEncounters > 0 ? ((izin + sakit) / totalEncounters * 100) : 0;
    double pAlfa = totalEncounters > 0 ? (alfa / totalEncounters * 100) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardPadding),
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(kelas['namaKelas'] as String, style: AppTheme.titleMedium(context).copyWith(fontSize: 16)),
              Row(
                children: [
                  Icon(Icons.people_alt_outlined, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text('$totalSiswa Siswa', style: AppTheme.bodySmall(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.cardPadding),
          Wrap(
            spacing: AppTheme.chipGap,
            runSpacing: AppTheme.chipGap,
            children: [
              _StatBadge(label: 'Hadir', value: '${pHadir.toStringAsFixed(1)}%', color: AppTheme.success, icon: Icons.check_circle_outline_rounded),
              _StatBadge(label: 'Sakit/Izin', value: '${pIzinSakit.toStringAsFixed(1)}%', color: AppTheme.warning, icon: Icons.warning_rounded),
              _StatBadge(label: 'Alfa', value: '${pAlfa.toStringAsFixed(1)}%', color: AppTheme.danger, icon: Icons.error_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBadge({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.labelBold(context).copyWith(color: color, fontSize: 10)),
          const SizedBox(width: 6),
          Text(value, style: AppTheme.titleMedium(context).copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}