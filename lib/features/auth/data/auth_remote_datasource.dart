import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import 'local_storage.dart';
import '../domain/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _client;
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDatasource({
    ApiClient? client,
    FirebaseAuth? firebaseAuth,
  })  : _client = client ?? ApiClient(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ── Sign in via Firebase, then sync device ──────────────────────
  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Firebase Auth
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Sync FCM Token (mengambil token asli dari perangkat)
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken(); 
        await _client.post(
          ApiConfig.syncDevice, 
          body: {'fcmToken': fcmToken ?? ''},
        );
      } catch (e) {
        debugPrint('⚠️ Gagal sync device token: $e');
      }
      
      // 3. Ambil data profil (WAJIB berhasil)
      return await fetchProfile();
      
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'Email tidak terdaftar',
        'wrong-password' => 'Password salah',
        'invalid-credential' => 'Email atau password salah',
        'user-disabled' => 'Akun dinonaktifkan',
        _ => e.message ?? 'Login gagal',
      };
      throw AuthFailure(msg);
    }
  }

  // Fetch Profile
  Future<UserModel> fetchProfile() async {
    final json = await _client.get(ApiConfig.usersMe);
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = UserModel.fromJson(data);
    await LocalStorage.saveUser(user.toJson());
    return user;
  }

  // ── Sign out ──────────────────────────────────────────────────────
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await LocalStorage.clearAll();
  }

  // ── Current Firebase user ────────────────────────────────────────
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // ── Get cached user from local storage ───────────────────────────
  Future<UserModel?> getCachedUser() async {
    final data = await LocalStorage.getUser();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}