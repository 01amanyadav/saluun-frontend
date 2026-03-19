import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/domain/entities/user_entity.dart';
import 'package:saluun_frontend/domain/usecases/auth/login_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/register_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/logout_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/get_current_user_usecase.dart';
import 'core_providers.dart';

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await loginUseCase.call(email: email, password: password);
    });
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await registerUseCase.call(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await logoutUseCase.call();
      return null;
    });
  }

  Future<void> getCurrentUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await getCurrentUserUseCase.call();
    });
  }

  bool get isLoggedIn => state.whenData((user) => user != null).value ?? false;
}

// Auth Provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
      return AuthNotifier(
        loginUseCase: ref.watch(loginUseCaseProvider),
        registerUseCase: ref.watch(registerUseCaseProvider),
        logoutUseCase: ref.watch(logoutUseCaseProvider),
        getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
      );
    });

// Current User Provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).whenData((user) => user).value;
});

// Stream-based check for logged in status
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.isLoggedIn();
});
