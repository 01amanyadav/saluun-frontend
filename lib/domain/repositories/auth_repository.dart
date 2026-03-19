import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserEntity> login({required String email, required String password});

  Future<void> logout();

  Future<UserEntity> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> clearToken();
}
