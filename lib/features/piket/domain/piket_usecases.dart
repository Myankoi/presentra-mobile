import '../../../shared/models/kelas_model.dart';
import 'piket_repository.dart';

class GetMonitoringPiketUseCase {
  final PiketRepository _repo;
  GetMonitoringPiketUseCase(this._repo);
  Future<List<Kelas>> call() => _repo.getMonitoringPiket();
}

class GetDetailKelasUseCase {
  final PiketRepository _repo;
  GetDetailKelasUseCase(this._repo);
  Future<Map<String, dynamic>> call(int kelasId) =>
      _repo.getDetailKelas(kelasId);
}