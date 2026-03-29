import 'bk_repository.dart';

class GetStatistikBkUseCase {
  final BkRepository _repo;
  GetStatistikBkUseCase(this._repo);
  Future<Map<String, dynamic>> call() => _repo.getStatistikHariIni();
}

class GetTopAlfaUseCase {
  final BkRepository _repo;
  GetTopAlfaUseCase(this._repo);
  Future<List<Map<String, dynamic>>> call({String periode = 'bulan'}) =>
      _repo.getTopAlfa(periode: periode);
}

class GetRekapLaporanUseCase {
  final BkRepository _repo;
  GetRekapLaporanUseCase(this._repo);
  Future<List<Map<String, dynamic>>> call({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) => _repo.getRekapLaporan(
        kelasId: kelasId,
        bulan: bulan,
        tahun: tahun,
        startDate: startDate,
        endDate: endDate,
      );
}

class DownloadExcelUseCase {
  final BkRepository _repo;
  DownloadExcelUseCase(this._repo);
  Future<String> call({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) => _repo.downloadExcel(
        kelasId: kelasId,
        bulan: bulan,
        tahun: tahun,
        startDate: startDate,
        endDate: endDate,
      );
}