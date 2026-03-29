import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/initial_avatar.dart';
import '../../auth/presentation/auth_provider.dart';
import 'sekretaris_provider.dart';

class InputAbsensiScreen extends StatefulWidget {
  final String? tanggal;
  const InputAbsensiScreen({super.key, this.tanggal});

  @override
  State<InputAbsensiScreen> createState() => _InputAbsensiScreenState();
}

class _InputAbsensiScreenState extends State<InputAbsensiScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SekretarisProvider>().fetchSiswaList(tanggal: widget.tanggal);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authProvider = context.watch<AuthProvider>();
    final provider = context.watch<SekretarisProvider>();
    final kelas = authProvider.user?.kelas ?? 'Kelas';

    String formattedDate;
    bool isReadOnly = false;

    if (widget.tanggal != null) {
      try {
        final date = DateTime.parse(widget.tanggal!);
        formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
        final checkDateStr = DateFormat('yyyy-MM-dd').format(date);
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        isReadOnly = checkDateStr != todayStr;
      } catch (_) {
        formattedDate = widget.tanggal!;
      }
    } else {
      formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    }

    final siswaList = provider.filteredSiswaList;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Input Absensi'),
        actions: [
          if (!isReadOnly)
            TextButton(
              onPressed: () => provider.markAllHadir(),
              child: Text(
                'Hadir Semua',
                style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Subheader ──────────────────────────────────
          Container(
            width: double.infinity,
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, 0, AppTheme.screenPadding, AppTheme.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: colors.divider),
                const SizedBox(height: AppTheme.itemGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kelas, style: AppTheme.titleMedium(context).copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(formattedDate, style: AppTheme.bodySmall(context)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '${provider.terisi}/${provider.totalSiswa} Terisi',
                        style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.cardPadding),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NISN...',
                    prefixIcon: Icon(Icons.search_rounded, color: colors.textTertiary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),

          // ── Student List ───────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.danger),
                            const SizedBox(height: AppTheme.itemGap),
                            Text(provider.error!, style: AppTheme.bodyMedium(context)),
                            const SizedBox(height: AppTheme.cardPadding),
                            ElevatedButton(onPressed: () => provider.fetchSiswaList(), child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : siswaList.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isNotEmpty ? 'Tidak ada siswa yang ditemukan' : 'Belum ada data siswa',
                              style: AppTheme.bodyMedium(context),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.cardPadding, AppTheme.screenPadding, 120),
                            itemCount: siswaList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.itemGap),
                            itemBuilder: (context, index) {
                              final siswa = siswaList[index];
                              final realIndex = provider.siswaList.indexOf(siswa);
                              return _SiswaCard(
                                nama: siswa['nama'] ?? '',
                                nis: siswa['nis'] ?? '',
                                status: siswa['status'],
                                isReadOnly: isReadOnly,
                                onStatusChanged: (newStatus) {
                                  if (!isReadOnly) provider.updateSiswaStatus(realIndex, newStatus);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),

      // ── Bottom Button ──────────────────────────────
      bottomSheet: isReadOnly ? null : Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(AppTheme.screenPadding, AppTheme.cardPadding, AppTheme.screenPadding, AppTheme.sectionGap),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.submitBulkAbsen();
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Absensi berhasil disimpan!'), backgroundColor: AppTheme.success),
                          );
                          Navigator.pop(context);
                        } else if (provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!), backgroundColor: AppTheme.danger),
                          );
                        }
                      },
                icon: provider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(provider.isLoading ? 'Menyimpan...' : 'Simpan Absensi'),
              ),
            ),
            const SizedBox(height: AppTheme.chipGap),
            Text(
              'SEKRETARIS: ${authProvider.user?.nama.toUpperCase() ?? '-'}',
              style: AppTheme.bodySmall(context).copyWith(fontSize: 10, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student Card ──────────────────────────────────────────────────
class _SiswaCard extends StatelessWidget {
  final String nama;
  final String nis;
  final String? status;
  final bool isReadOnly;
  final ValueChanged<String> onStatusChanged;

  const _SiswaCard({
    required this.nama,
    required this.nis,
    required this.status,
    required this.isReadOnly,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InitialAvatar(name: nama, size: 40, fontSize: 14),
              const SizedBox(width: AppTheme.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: AppTheme.titleMedium(context).copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('NISN: $nis', style: AppTheme.bodySmall(context).copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.itemGap),
          Row(
            children: [
              _StatusChip(label: 'HADIR', value: 'hadir', selected: status == 'hadir', isReadOnly: isReadOnly, onTap: () => onStatusChanged('hadir')),
              const SizedBox(width: AppTheme.chipGap),
              _StatusChip(label: 'IZIN', value: 'izin', selected: status == 'izin', isReadOnly: isReadOnly, onTap: () => onStatusChanged('izin')),
              const SizedBox(width: AppTheme.chipGap),
              _StatusChip(label: 'SAKIT', value: 'sakit', selected: status == 'sakit', isReadOnly: isReadOnly, onTap: () => onStatusChanged('sakit')),
              const SizedBox(width: AppTheme.chipGap),
              _StatusChip(label: 'ALFA', value: 'alfa', selected: status == 'alfa', isReadOnly: isReadOnly, onTap: () => onStatusChanged('alfa')),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ──────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final bool isReadOnly;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.value, required this.selected, required this.isReadOnly, required this.onTap});

  Color get _color => switch (value) {
    'hadir' => AppTheme.primaryBlue,
    'izin' => AppTheme.warning,
    'sakit' => AppTheme.accentOrange,
    'alfa' => AppTheme.danger,
    _ => AppTheme.mediumGray,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: GestureDetector(
        onTap: isReadOnly ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? (isReadOnly ? _color.withValues(alpha: 0.6) : _color) : colors.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? (isReadOnly ? _color.withValues(alpha: 0.6) : _color) : colors.inputBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.labelBold(context).copyWith(
              color: selected ? Colors.white : colors.textTertiary,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
