import '../../../core/errors/failures.dart';
import 'guru_remote_datasource.dart';
import '../domain/guru_repository.dart';
import '../../../shared/models/jadwal_model.dart';

class GuruRepositoryImpl implements GuruRepository {
  final GuruRemoteDatasource _datasource;

  GuruRepositoryImpl({GuruRemoteDatasource? datasource})
      : _datasource = datasource ?? GuruRemoteDatasource();

  @override
  Future<List<Jadwal>> getJadwalHariIni() async {
    try {
      return await _datasource.getJadwalHariIni();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<Map<String, dynamic>> scanAbsen(String tokenQr) async {
    try {
      return await _datasource.scanAbsen(tokenQr);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoryAbsen() async {
    try {
      return await _datasource.getHistoryAbsen();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistik() async {
    try {
      return await _datasource.getStatistik();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<Map<String, dynamic>> cekPiketHariIni() async {
    try {
      return await _datasource.cekPiketHariIni();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }
}