import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/core/utils/token_service.dart';
import 'package:saluun_frontend/core/utils/user_service.dart';
import 'package:saluun_frontend/core/network/dio_client.dart';
import 'package:saluun_frontend/data/datasources/auth_service.dart';
import 'package:saluun_frontend/data/repositories/auth_repository_impl.dart';
import 'package:saluun_frontend/domain/repositories/auth_repository.dart';
import 'package:saluun_frontend/domain/usecases/auth/login_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/register_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/logout_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/get_current_user_usecase.dart';

// Service Providers
final dioClientProvider = Provider<DioClient>((_) => DioClient());

final tokenServiceProvider = Provider<TokenService>((_) => tokenService);

final userServiceProvider = Provider<UserService>((_) => userService);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(dioClientProvider).dio),
);

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(authServiceProvider),
    tokenService: ref.watch(tokenServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

// UseCase Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});
