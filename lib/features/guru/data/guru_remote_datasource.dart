import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/jadwal_model.dart';

class GuruRemoteDatasource {
  final ApiClient _client;

  GuruRemoteDatasource({ApiClient? client}) : _client = client ?? ApiClient();

  // ── GET /api/jadwal/hari-ini ─────────────────────────────────────
  Future<List<Jadwal>> getJadwalHariIni() async {
    final json = await _client.get(ApiConfig.jadwalHariIni);
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => Jadwal.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── GET /api/jadwal/hari-ini?hari=senin ─────────────────────────
  Future<List<Jadwal>> getJadwalByHari(String hari) async {
    final json = await _client.get(ApiConfig.jadwalByHari(hari));
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => Jadwal.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── POST /api/absen/guru/scan-guru ───────────────────────────────
  Future<Map<String, dynamic>> scanAbsen(String tokenQr) async {
    return await _client.post(
      ApiConfig.scanGuruAbsen,
      body: {'tokenQr': tokenQr},
    );
  }

  // ── GET /api/absen/guru/history ──────────────────────────────────
  Future<List<Map<String, dynamic>>> getHistoryAbsen() async {
    final json = await _client.get(ApiConfig.historyAbsenGuru);
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // ── GET /api/dashboard/summary ───────────────────────────────────
  Future<Map<String, dynamic>> getStatistik() async {
    final json = await _client.get(ApiConfig.dashboardSummary);
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  // ── GET /api/jadwal/piket-hari-ini ──────────────────────────────
  Future<Map<String, dynamic>> cekPiketHariIni() async {
    final json = await _client.get(ApiConfig.cekPiketHariIni);
    return json;
  }
}