import '../../../shared/models/jadwal_model.dart';

abstract class GuruRepository {
  Future<List<Jadwal>> getJadwalHariIni();
  Future<Map<String, dynamic>> scanAbsen(String tokenQr);
  Future<List<Map<String, dynamic>>> getHistoryAbsen();
  Future<Map<String, dynamic>> getStatistik();
  Future<Map<String, dynamic>> cekPiketHariIni();
}