import '../../../shared/models/kelas_model.dart';

abstract class PiketRepository {
  Future<List<Kelas>> getMonitoringPiket();
  Future<Map<String, dynamic>> getDetailKelas(int kelasId);
}