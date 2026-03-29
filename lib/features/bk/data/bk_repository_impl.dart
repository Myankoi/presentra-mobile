import '../../../core/errors/failures.dart';
import 'bk_remote_datasource.dart';
import '../domain/bk_repository.dart';

class BkRepositoryImpl implements BkRepository {
  final BkRemoteDatasource _datasource;

  BkRepositoryImpl({BkRemoteDatasource? datasource})
      : _datasource = datasource ?? BkRemoteDatasource();

  @override
  Future<Map<String, dynamic>> getStatistikHariIni() async {
    try {
      return await _datasource.getStatistikHariIni();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAlfa({
    String periode = 'bulan',
  }) async {
    try {
      return await _datasource.getTopAlfa(periode: periode);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRekapLaporan({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _datasource.getRekapLaporan(
        kelasId: kelasId,
        bulan: bulan,
        tahun: tahun,
        startDate: startDate,
        endDate: endDate,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<String> downloadExcel({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    return _datasource.downloadExcel(
      kelasId: kelasId,
      bulan: bulan,
      tahun: tahun,
      startDate: startDate,
      endDate: endDate,
    );
  }
}