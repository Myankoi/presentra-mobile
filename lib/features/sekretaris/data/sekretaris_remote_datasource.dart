import '../../../core/network/api_client.dart';
import '../../../core/constants/api_config.dart';

class SekretarisRemoteDatasource {
  final ApiClient _client;

  SekretarisRemoteDatasource({ApiClient? client}) : _client = client ?? ApiClient();

  // Ambil rekap harian (grouped by tanggal)
  Future<List<dynamic>> fetchRecap() async {
    final json = await _client.get(ApiConfig.siswaRecap);
    return json['data'] as List<dynamic>? ?? [];
  }

  // Ambil detail absen siswa per tanggal — return full response
  Future<Map<String, dynamic>> fetchDetailTanggal(String tanggal) async {
    return await _client.get(ApiConfig.siswaDetail(tanggal));
  }

  // Kirim bulk absen
  Future<void> submitAbsen(List<Map<String, dynamic>> dataAbsensi, {String? tanggal}) async {
    final body = <String, dynamic>{
      'dataAbsensi': dataAbsensi,
    };
    if (tanggal != null) {
      body['tanggal'] = tanggal;
    }
    await _client.post(ApiConfig.siswaAbsen, body: body);
  }
}
