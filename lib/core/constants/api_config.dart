class ApiConfig {
  static const String baseUrl = 'https://lactary-branda-chainlike.ngrok-free.dev';
  static const String apiPrefix = '/api';

  // Auth & Profile
  static String get syncDevice => '$baseUrl$apiPrefix/auth/sync-device';
  static String get usersMe => '$baseUrl$apiPrefix/users/me';

  // Dashboard
  static String get dashboardSummary => '$baseUrl$apiPrefix/dashboard/summary';
  static String dashboardChart(String periode) =>
      '$baseUrl$apiPrefix/dashboard/chart?periode=$periode';

  // Jadwal Guru
  static String get jadwalHariIni => '$baseUrl$apiPrefix/jadwal/hari-ini';
  static String get cekPiketHariIni => '$baseUrl$apiPrefix/jadwal/piket-hari-ini';
  static String jadwalByHari(String hari) => '$baseUrl$apiPrefix/jadwal/hari-ini?hari=$hari';

  // Absensi
  static String get scanGuruAbsen => '$baseUrl$apiPrefix/absen/guru/scan-guru';
  static String get historyAbsenGuru => '$baseUrl$apiPrefix/absen/guru/history';
  static String get siswaAbsen => '$baseUrl$apiPrefix/absen/siswa/absen';
  static String get siswaRecap => '$baseUrl$apiPrefix/absen/siswa/recap';
  static String siswaDetail(String tanggal) => '$baseUrl$apiPrefix/absen/siswa/detail?tanggal=$tanggal';

  // Piket Monitoring
  static String get piketMonitoring => '$baseUrl$apiPrefix/piket/monitoring';
  static String piketDetailKelas(int kelasId) =>
      '$baseUrl$apiPrefix/piket/kelas/$kelasId/detail';

  // BK
  static String get bkStatistikHariIni => '$baseUrl$apiPrefix/bk/statistik-hari-ini';
  static String bkTopAlfa(String periode) =>
      '$baseUrl$apiPrefix/bk/top-alfa?periode=$periode';

  // Laporan
  static String laporanRekap({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[];
    if (kelasId != null) params.add('kelasId=$kelasId');
    if (bulan != null) params.add('bulan=$bulan');
    if (tahun != null) params.add('tahun=$tahun');
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl$apiPrefix/laporan/rekap$query';
  }

  static String laporanExport({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[];
    if (kelasId != null) params.add('kelasId=$kelasId');
    if (bulan != null) params.add('bulan=$bulan');
    if (tahun != null) params.add('tahun=$tahun');
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl$apiPrefix/laporan/export$query';
  }

  // Notifikasi
  static String get notifications => '$baseUrl$apiPrefix/notifications';
  static String get notificationsUnreadCount => '$baseUrl$apiPrefix/notifications/unread-count';
  static String get notificationsMarkAllRead => '$baseUrl$apiPrefix/notifications/mark-all-read';
  static String notificationRead(int id) =>
      '$baseUrl$apiPrefix/notifications/$id/read';
}
