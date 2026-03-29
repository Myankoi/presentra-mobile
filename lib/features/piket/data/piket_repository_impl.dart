import '../../../core/errors/failures.dart';
import 'piket_remote_datasource.dart';
import '../domain/piket_repository.dart';
import '../../../shared/models/kelas_model.dart';

class PiketRepositoryImpl implements PiketRepository {
  final PiketRemoteDatasource _datasource;

  PiketRepositoryImpl({PiketRemoteDatasource? datasource})
      : _datasource = datasource ?? PiketRemoteDatasource();

  @override
  Future<List<Kelas>> getMonitoringPiket() async {
    try {
      return await _datasource.getMonitoringPiket();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDetailKelas(int kelasId) async {
    try {
      return await _datasource.getDetailKelas(kelasId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('$e');
    }
  }
}