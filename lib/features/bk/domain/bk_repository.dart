abstract class BkRepository {
  Future<Map<String, dynamic>> getStatistikHariIni();
  Future<List<Map<String, dynamic>>> getTopAlfa({String periode});
  Future<List<Map<String, dynamic>>> getRekapLaporan({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  });
  Future<String> downloadExcel({
    int? kelasId,
    int? bulan,
    int? tahun,
    String? startDate,
    String? endDate,
  });
}
