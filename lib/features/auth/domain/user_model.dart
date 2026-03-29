import 'package:flutter/foundation.dart';

class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role; // 'guru', 'bk', 'sekretaris', 'admin'
  final String? kelas;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.kelas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final usr = UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'guru',
      kelas: _parseKelas(json['kelas']),
    );
    debugPrint('🔥 [UserModel] Parsed from JSON: ${usr.toJson()}');
    return usr;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'kelas': kelas,
    };
  }

  static String? _parseKelas(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['namaKelas']?.toString() ?? value['nama_kelas']?.toString();
    return value.toString();
  }

  String get displayName => nama.split(' ').first;

  String get homeRoute {
    debugPrint('🔥 [UserModel] Getting homeRoute for  role: "$role"');
    switch (role.toLowerCase().trim()) {
      case 'guru':
        return '/guru';
      case 'bk':
        return '/guru_bk';
      case 'sekretaris':
        return '/sekretaris';
      case 'piket':
        return '/dashboard_piket';
      case 'admin':
        return '/guru'; // Sementara admin diarahkan ke guru jika belum ada
      default:
        debugPrint('🔥 [UserModel] WARNING: Role "$role" is not recognized! Fallback ke /guru');
        return '/guru'; // JANGAN KE /login lagi, biar tetap masuk
    }
  }
}