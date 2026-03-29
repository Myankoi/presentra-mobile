import 'user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  bool get isLoggedIn;
}