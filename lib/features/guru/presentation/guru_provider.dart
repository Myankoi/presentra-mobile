import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';
import '../data/guru_repository_impl.dart';
import '../domain/guru_repository.dart';
import '../domain/guru_usecases.dart';
import '../../../shared/models/jadwal_model.dart';

class GuruProvider extends ChangeNotifier {
  final GuruRepository _repo;

  late final GetJadwalUseCase _getJadwal;
  late final ScanAbsenUseCase _scanAbsen;
  late final GetStatistikGuruUseCase _getStatistik;
  late final GetHistoryAbsenUseCase _getHistory;
  late final CekPiketUseCase _cekPiket;

  GuruProvider({GuruRepository? repo}) : _repo = repo ?? GuruRepositoryImpl() {
    _getJadwal = GetJadwalUseCase(_repo);
    _scanAbsen = ScanAbsenUseCase(_repo);
    _getStatistik = GetStatistikGuruUseCase(_repo);
    _getHistory = GetHistoryAbsenUseCase(_repo);
    _cekPiket = CekPiketUseCase(_repo);
  }

  List<Jadwal> _jadwalList = [];
  Map<String, dynamic> _statistik = {};
  List<Map<String, dynamic>> _historyAbsen = [];
  Map<String, dynamic>? _scanResult;
  bool _isLoading = false;
  bool _isScanning = false;
  String? _error;

  // Piket status
  bool _isPiket = false;
  Map<String, dynamic>? _piketDetail;

  List<Jadwal> get jadwalList => _jadwalList;
  Map<String, dynamic> get statistik => _statistik;
  List<Map<String, dynamic>> get historyAbsen => _historyAbsen;
  Map<String, dynamic>? get scanResult => _scanResult;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String? get error => _error;
  bool get isPiket => _isPiket;
  Map<String, dynamic>? get piketDetail => _piketDetail;

  Future<void> loadJadwal() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _jadwalList = await _getJadwal();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistik() async {
    try {
      _statistik = await _getStatistik();
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> scanAbsen(String tokenQr) async {
    _isScanning = true;
    _scanResult = null;
    notifyListeners();
    try {
      _scanResult = await _scanAbsen(tokenQr);
      return {'success': true, 'data': _scanResult};
    } on AuthFailure catch (e) {
      return {'success': false, 'message': e.message};
    } on ServerFailure catch (e) {
      return {'success': false, 'message': e.message};
    } on Failure catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> loadHistoryAbsen() async {
    try {
      _historyAbsen = await _getHistory();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadPiketStatus() async {
    try {
      final result = await _cekPiket();
      _isPiket = result['isPiket'] == true;
      _piketDetail = result['data'] as Map<String, dynamic>?;
    } catch (_) {
      _isPiket = false;
      _piketDetail = null;
    }
    notifyListeners();
  }
}