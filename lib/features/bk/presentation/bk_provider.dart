import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';
import '../data/bk_repository_impl.dart';
import '../domain/bk_repository.dart';
import '../domain/bk_usecases.dart';

class BkProvider extends ChangeNotifier {
  final BkRepository _repo;

  late final GetStatistikBkUseCase _getStatistik;
  late final GetTopAlfaUseCase _getTopAlfa;
  late final GetRekapLaporanUseCase _getRekap;
  late final DownloadExcelUseCase _downloadExcel;

  BkProvider({BkRepository? repo}) : _repo = repo ?? BkRepositoryImpl() {
    _getStatistik = GetStatistikBkUseCase(_repo);
    _getTopAlfa = GetTopAlfaUseCase(_repo);
    _getRekap = GetRekapLaporanUseCase(_repo);
    _downloadExcel = DownloadExcelUseCase(_repo);
  }

  Map<String, dynamic> _statistik = {};
  List<Map<String, dynamic>> _topAlfa = [];
  List<Map<String, dynamic>> _rekapLaporan = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String? _error;

  Map<String, dynamic> get statistik => _statistik;
  List<Map<String, dynamic>> get topAlfa => _topAlfa;
  List<Map<String, dynamic>> get rekapLaporan => _rekapLaporan;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String? get error => _error;

  Future<void> loadStatistik() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _statistik = await _getStatistik();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopAlfa({String periode = 'bulan'}) async {
    try {
      _topAlfa = await _getTopAlfa(periode: periode);
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> loadRekap({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _rekapLaporan = await _getRekap(
        kelasId: kelasId,
        bulan: bulan,
        tahun: tahun,
        startDate: startDate,
        endDate: endDate,
      );
    } on Failure catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> downloadLaporan({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) async {
    _isDownloading = true;
    _error = null;
    notifyListeners();
    try {
      final path = await _downloadExcel(
        kelasId: kelasId,
        bulan: bulan,
        tahun: tahun,
        startDate: startDate,
        endDate: endDate,
      );
      return path;
    } on Failure catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}