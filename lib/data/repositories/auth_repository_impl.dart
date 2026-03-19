import 'package:saluun_frontend/data/datasources/auth_service.dart';
import 'package:saluun_frontend/domain/entities/user_entity.dart';
import 'package:saluun_frontend/domain/repositories/auth_repository.dart';
import '../../core/utils/token_service.dart';
import '../../core/utils/user_service.dart';
import '../models/api_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenService tokenService;
  final UserService userService;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenService,
    required this.userService,
  });

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await authService.register(
      email: email,
      password: password,
      name: displayName,
    );

    if (response.token != null) {
      await tokenService.saveAccessToken(response.token!);
    }

    return _mapUserToEntity(response.user!);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await authService.login(email: email, password: password);

    if (response.token != null) {
      await tokenService.saveAccessToken(response.token!);
    }

    await userService.saveUser(response.user!);
    return _mapUserToEntity(response.user!);
  }

  @override
  Future<void> logout() async {
    await tokenService.clearTokens();
    await userService.clearUser();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = await userService.getCurrentUser();
    if (user == null) {
      throw Exception('No user found');
    }
    return _mapUserToEntity(user);
  }

  @override
  Future<bool> isLoggedIn() async {
    return tokenService.isLoggedIn();
  }

  @override
  Future<void> saveToken(String token) async {
    await tokenService.saveAccessToken(token);
  }

  @override
  Future<String?> getToken() async {
    return tokenService.getAccessToken();
  }

  @override
  Future<void> clearToken() async {
    await tokenService.clearTokens();
  }

  UserEntity _mapUserToEntity(User user) {
    return UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.name,
      profilePictureUrl: user.profileImage,
      phoneNumber: user.phone,
      isEmailVerified: true,
      createdAt: user.createdAt,
    );
  }
}
