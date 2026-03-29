import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart'; // IMPORT INI PENTING!

class Kelas {
  final int id;
  final String namaKelas;
  final String? guru;
  final String? statusGuru; // 'hadir', 'belum_checkin'
  final int totalSiswa;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final String? waktuCheckin;

  Kelas({
    required this.id,
    required this.namaKelas,
    this.guru,
    this.statusGuru,
    required this.totalSiswa,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    this.waktuCheckin,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'] ?? json['kelasId'] ?? 0,
      namaKelas: json['namaKelas'] ?? 'Kelas',
      guru: json['guru']?['nama'] ?? json['guru'],
      statusGuru: json['statusGuru'] ?? 'belum_checkin',
      totalSiswa: json['totalSiswa'] ?? 0,
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alfa: json['alfa'] ?? 0,
      waktuCheckin: json['waktuCheckin'],
    );
  }

  int get totalHadir => hadir;
  int get totalTidakHadir => izin + sakit + alfa;
  double get persentaseHadir => totalSiswa > 0 ? (hadir / totalSiswa * 100) : 0;
  
  String get statusGuruDisplay {
    if (statusGuru == 'hadir') return 'Guru Sudah Check-in';
    if (statusGuru == 'belum_checkin') return 'Guru Belum Check-in';
    return 'Tidak Ada Guru';
  }
  
  Color get statusGuruColor {
    if (statusGuru == 'hadir') return AppTheme.success;
    return AppTheme.warning;
  }
}