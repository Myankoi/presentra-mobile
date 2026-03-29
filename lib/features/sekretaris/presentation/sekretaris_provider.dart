import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../data/sekretaris_remote_datasource.dart';
import '../../../core/errors/failures.dart';

class SekretarisProvider extends ChangeNotifier {
  final SekretarisRemoteDatasource _datasource;

  SekretarisProvider({SekretarisRemoteDatasource? datasource})
      : _datasource = datasource ?? SekretarisRemoteDatasource();

  bool _isLoading = false;
  String? _error;

  // Beranda stats
  int totalSiswa = 0;
  int hadir = 0;
  int izinSakit = 0;
  int alfa = 0;

  // Input Absensi
  List<Map<String, dynamic>> _siswaList = [];
  String _searchQuery = '';
  String? _currentTanggal;
  int terisi = 0;

  // Riwayat recap
  List<Map<String, dynamic>> _recapList = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get siswaList => _siswaList;
  List<Map<String, dynamic>> get recapList => _recapList;

  List<Map<String, dynamic>> get filteredSiswaList {
    if (_searchQuery.isEmpty) return _siswaList;
    final q = _searchQuery.toLowerCase();
    return _siswaList.where((s) {
      final nama = (s['nama'] ?? '').toString().toLowerCase();
      final nis = (s['nis'] ?? '').toString().toLowerCase();
      return nama.contains(q) || nis.contains(q);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Beranda: fetch summary ────────────────────────────────── 
  Future<void> fetchDetailHariIni() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tgl = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final detailResponse = await _datasource.fetchDetailTanggal(tgl);
      final List<dynamic> studentList = detailResponse['data'] ?? [];
      final Map<String, dynamic> stats = detailResponse['stats'] ?? {};

      totalSiswa = stats['totalSiswa'] ?? studentList.length;
      terisi = stats['terisi'] ?? 0;

      int h = 0, is_ = 0, a = 0;
      for (final s in studentList) {
        switch (s['status']) {
          case 'hadir':
          case 'terlambat':
            h++;
            break;
          case 'izin':
          case 'sakit':
            is_++;
            break;
          case 'alfa':
            a++;
            break;
        }
      }
      hadir = h;
      izinSakit = is_;
      alfa = a;
    } on NetworkFailure catch (e) {
      _error = e.message;
    } on AuthFailure catch (e) {
      _error = e.message;
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat data absensi.';
      debugPrint('SekretarisError: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Input Absensi: fetch student list ─────────────────────── 
  Future<void> fetchSiswaList({String? tanggal}) async {
    String tglToFetch = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (tanggal != null) {
      if (tanggal.length > 10) {
        // e.g. "2024-03-24T00:00:00.000Z". Parse and reformat strictly
        try {
          final p = DateTime.parse(tanggal);
          tglToFetch = DateFormat('yyyy-MM-dd').format(p);
        } catch (_) {
          tglToFetch = tanggal; // fallback
        }
      } else {
        tglToFetch = tanggal;
      }
    }

    _currentTanggal = tglToFetch;
    _isLoading = true;
    _error = null;
    _searchQuery = '';
    notifyListeners();

    try {
      final detailResponse = await _datasource.fetchDetailTanggal(tglToFetch);
      final List<dynamic> rawList = detailResponse['data'] ?? [];
      final Map<String, dynamic> stats = detailResponse['stats'] ?? {};

      totalSiswa = stats['totalSiswa'] ?? rawList.length;

      _siswaList = rawList.map<Map<String, dynamic>>((item) {
        return {
          'siswaId': item['siswaId'] ?? item['id'],
          'nama': item['nama'] ?? '',
          'nis': item['nis'] ?? '',
          'status': item['status'], // bisa null kalau belum diisi
          'keterangan': item['keterangan'],
        };
      }).toList();

      _recountTerisi();
    } on NetworkFailure catch (e) {
      _error = e.message;
    } on AuthFailure catch (e) {
      _error = e.message;
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat daftar siswa.';
      debugPrint('SekretarisError fetchSiswaList: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update status siswa lokal ─────────────────────────────── 
  void updateSiswaStatus(int index, String newStatus) {
    if (index < 0 || index >= _siswaList.length) return;
    _siswaList[index] = {..._siswaList[index], 'status': newStatus};
    _recountTerisi();
    notifyListeners();
  }

  void markAllHadir() {
    for (int i = 0; i < _siswaList.length; i++) {
      _siswaList[i] = {..._siswaList[i], 'status': 'hadir'};
    }
    _recountTerisi();
    notifyListeners();
  }

  void _recountTerisi() {
    terisi = _siswaList.where((s) => s['status'] != null).length;

    int h = 0, is_ = 0, a = 0;
    for (final s in _siswaList) {
      switch (s['status']) {
        case 'hadir':
        case 'terlambat':
          h++;
          break;
        case 'izin':
        case 'sakit':
          is_++;
          break;
        case 'alfa':
          a++;
          break;
      }
    }
    hadir = h;
    izinSakit = is_;
    alfa = a;
  }

  // ── Submit absensi ────────────────────────────────────────── 
  Future<bool> submitBulkAbsen() async {
    // Validasi: semua siswa harus punya status
    final belumTerisi = _siswaList.where((s) => s['status'] == null).toList();
    if (belumTerisi.isNotEmpty) {
      _error = '${belumTerisi.length} siswa belum diisi statusnya.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dataAbsensi = _siswaList.map((s) {
        final entry = <String, dynamic>{
          'siswaId': s['siswaId'],
          'status': s['status'],
        };
        if (s['keterangan'] != null && (s['keterangan'] as String).isNotEmpty) {
          entry['keterangan'] = s['keterangan'];
        }
        return entry;
      }).toList();

      await _datasource.submitAbsen(dataAbsensi, tanggal: _currentTanggal);
      await fetchDetailHariIni();
      return true;
    } on ServerFailure catch (e) {
      _error = e.message;
      return false;
    } on Failure catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Gagal menyimpan absensi.';
      debugPrint('SekretarisError submitBulk: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Riwayat: fetch recap history ───────────────────────── 
  Future<void> fetchRecap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _datasource.fetchRecap();
      _recapList = data.map<Map<String, dynamic>>((item) {
        return {
          'tanggal': item['tanggal']?.toString(),
          'hadir': item['hadir'] ?? 0,
          'izinSakit': item['izinSakit'] ?? 0,
          'alfa': item['alfa'] ?? 0,
        };
      }).toList();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat riwayat absensi.';
      debugPrint('SekretarisError fetchRecap: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
