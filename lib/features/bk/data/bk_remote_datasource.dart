import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';

class BkRemoteDatasource {
  final ApiClient _client;

  BkRemoteDatasource({ApiClient? client}) : _client = client ?? ApiClient();

  // ── GET /api/bk/statistik-hari-ini ──────────────────────────────
  Future<Map<String, dynamic>> getStatistikHariIni() async {
    final json = await _client.get(ApiConfig.bkStatistikHariIni);
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  // ── GET /api/bk/top-alfa?periode=... ────────────────────────────
  Future<List<Map<String, dynamic>>> getTopAlfa({
    String periode = 'bulan',
  }) async {
    final json = await _client.get(ApiConfig.bkTopAlfa(periode));
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // ── GET /api/laporan/rekap ───────────────────────────────────────
  // API returns { success: true, data: [ { nis, nama, namaKelas, hadir, izin, sakit, alfa, terlambat }, ... ] }
  Future<List<Map<String, dynamic>>> getRekapLaporan({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    final url = ApiConfig.laporanRekap(
      kelasId: kelasId,
      bulan: bulan,
      tahun: tahun,
      startDate: startDate,
      endDate: endDate,
    );
    final json = await _client.get(url);
    // data is a flat array of per-student rows
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // ── GET /api/laporan/export → Download Excel file ────────────────
  Future<String> downloadExcel({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    final url = ApiConfig.laporanExport(
      kelasId: kelasId,
      bulan: bulan,
      tahun: tahun,
      startDate: startDate,
      endDate: endDate,
    );

    final bytes = await _client.downloadFile(url);

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/Laporan_Absensi_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }
}