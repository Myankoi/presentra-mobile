import '../../../core/errors/failures.dart';
import 'auth_remote_datasource.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
      : _datasource = datasource ?? AuthRemoteDatasource();

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      return await _datasource.login(email, password);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Login gagal: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // If Firebase still has a session, fetch fresh profile
    if (_datasource.currentFirebaseUser != null) {
      try {
        return await _datasource.fetchProfile();
      } catch (_) {}
    }
    // Fallback: cached user from local storage
    return await _datasource.getCachedUser();
  }

  @override
  Future<void> logout() => _datasource.logout();

  @override
  bool get isLoggedIn => _datasource.currentFirebaseUser != null;
}