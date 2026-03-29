import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/kelas_model.dart';

class PiketRemoteDatasource {
  final ApiClient _client;

  PiketRemoteDatasource({ApiClient? client}) : _client = client ?? ApiClient();

  // ── GET /api/piket/monitoring ─────────────────────────────────────
  Future<List<Kelas>> getMonitoringPiket() async {
    final json = await _client.get(ApiConfig.piketMonitoring);
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((e) => Kelas.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── GET /api/piket/kelas/:id/detail ──────────────────────────────
  Future<Map<String, dynamic>> getDetailKelas(int kelasId) async {
    final json = await _client.get(ApiConfig.piketDetailKelas(kelasId));
    return json['data'] as Map<String, dynamic>? ?? json;
  }
}