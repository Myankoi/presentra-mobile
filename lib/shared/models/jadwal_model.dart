class Jadwal {
  final int id;
  final String mataPelajaran;
  final String kelas;
  final String ruang;
  final String jamMulai;
  final String jamSelesai;
  final String hari;
  final String? guru;
  final String? status; // 'sedang_berlangsung', 'selesai', 'akan_datang'

  Jadwal({
    required this.id,
    required this.mataPelajaran,
    required this.kelas,
    required this.ruang,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    this.guru,
    this.status,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] ?? 0,
      mataPelajaran: json['namaMapel'] ?? 
                     json['mapel']?['namaMapel'] ?? 
                     json['mataPelajaran'] ?? 
                     '-',
      kelas: json['namaKelas'] ?? 
             json['kelas']?['namaKelas'] ?? 
             (json['kelas'] is String ? json['kelas'] : '-'),
      ruang: json['ruang'] ?? '-',
      jamMulai: json['jamMulai'] ?? '-',
      jamSelesai: json['jamSelesai'] ?? '-',
      hari: json['hari'] ?? '',
      guru: json['namaGuru'] ?? json['guru']?['nama'] ?? (json['guru'] is String ? json['guru'] : null),
      status: json['status'],
    );
  }

  String get waktu => '$jamMulai - $jamSelesai';
  
  bool get isSedangBerlangsung {
    final now = DateTime.now();
    
    // Check day first
    final List<String> namaHari = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];
    final currentHari = namaHari[now.weekday - 1];
    
    if (hari.toLowerCase() != currentHari) {
      return false;
    }

    // Then check time
    try {
      final start = _parseTime(jamMulai);
      final end = _parseTime(jamSelesai);
      final current = _parseTime('${now.hour}:${now.minute}');
      return current >= start && current <= end;
    } catch (_) {
      return false;
    }
  }
  
  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}