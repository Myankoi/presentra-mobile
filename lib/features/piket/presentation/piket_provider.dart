import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';
import '../data/piket_repository_impl.dart';
import '../domain/piket_repository.dart';
import '../domain/piket_usecases.dart';
import '../../../shared/models/kelas_model.dart';

class PiketProvider extends ChangeNotifier {
  final PiketRepository _repo;

  late final GetMonitoringPiketUseCase _getMonitoring;
  late final GetDetailKelasUseCase _getDetailKelas;

  PiketProvider({PiketRepository? repo})
      : _repo = repo ?? PiketRepositoryImpl() {
    _getMonitoring = GetMonitoringPiketUseCase(_repo);
    _getDetailKelas = GetDetailKelasUseCase(_repo);
  }

  List<Kelas> _kelasList = [];
  Map<String, dynamic>? _detailKelas;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  List<Kelas> get kelasList => _kelasList;
  Map<String, dynamic>? get detailKelas => _detailKelas;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  Future<void> loadMonitoring() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _kelasList = await _getMonitoring();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetailKelas(int kelasId) async {
    _isLoadingDetail = true;
    _detailKelas = null;
    notifyListeners();
    try {
      _detailKelas = await _getDetailKelas(kelasId);
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}