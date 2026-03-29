import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_usecases.dart';
import '../domain/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  late final LoginUseCase _login;
  late final LogoutUseCase _logout;
  late final GetCurrentUserUseCase _getCurrentUser;

  AuthProvider({AuthRepository? repo})
      : _repo = repo ?? AuthRepositoryImpl() {
    _login = LoginUseCase(_repo);
    _logout = LogoutUseCase(_repo);
    _getCurrentUser = GetCurrentUserUseCase(_repo);
  }

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _repo.isLoggedIn;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _login(email, password);
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } on ServerFailure catch (e) {
      _error = 'Gagal mengambil profil: ${e.message}';
      return false;
    } on NetworkFailure catch (e) {
      _error = e.message;
      return false;
    } on Failure catch (e) {
      _error = e.message;
      return false;
    } catch (e, st) {
      debugPrint('❌ Login error: $e\n$st');
      _error = 'Login gagal. Coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _user = await _getCurrentUser();
    notifyListeners();
  }
}