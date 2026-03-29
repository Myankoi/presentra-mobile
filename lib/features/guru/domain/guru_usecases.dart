import '../../../shared/models/jadwal_model.dart';
import 'guru_repository.dart';

class GetJadwalUseCase {
  final GuruRepository _repo;
  GetJadwalUseCase(this._repo);
  Future<List<Jadwal>> call() => _repo.getJadwalHariIni();
}

class ScanAbsenUseCase {
  final GuruRepository _repo;
  ScanAbsenUseCase(this._repo);
  Future<Map<String, dynamic>> call(String tokenQr) =>
      _repo.scanAbsen(tokenQr);
}

class GetStatistikGuruUseCase {
  final GuruRepository _repo;
  GetStatistikGuruUseCase(this._repo);
  Future<Map<String, dynamic>> call() => _repo.getStatistik();
}

class GetHistoryAbsenUseCase {
  final GuruRepository _repo;
  GetHistoryAbsenUseCase(this._repo);
  Future<List<Map<String, dynamic>>> call() => _repo.getHistoryAbsen();
}

class CekPiketUseCase {
  final GuruRepository _repo;
  CekPiketUseCase(this._repo);
  Future<Map<String, dynamic>> call() => _repo.cekPiketHariIni();
}