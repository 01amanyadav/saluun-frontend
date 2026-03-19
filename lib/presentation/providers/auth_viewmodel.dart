import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/domain/entities/user_entity.dart';
import 'package:saluun_frontend/domain/usecases/auth/login_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/register_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/logout_usecase.dart';
import 'package:saluun_frontend/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:saluun_frontend/presentation/models/auth_ui_state.dart';
import 'core_providers.dart';

/// Production-grade AuthViewModel using Riverpod StateNotifier
///
/// Handles all authentication state management including login, register,
/// logout, and session checking. Provides clean separation between UI state
/// (AuthUiState) and domain logic.
class AuthViewModel extends StateNotifier<AuthUiState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthUiState.initial());

  /// Login with email and password
  ///
  /// Handles the entire login flow:
  /// 1. Set loading state
  /// 2. Call login use case
  /// 3. On success: save user and set success state
  /// 4. On error: set error state with user-friendly message
  Future<void> login({required String email, required String password}) async {
    state = AuthUiState.loading();
    try {
      final user = await loginUseCase.call(email: email, password: password);
      state = AuthUiState.success(user);
    } catch (e) {
      state = AuthUiState.error(_parseErrorMessage(e));
    }
  }

  /// Register a new account
  ///
  /// Handles the entire registration flow:
  /// 1. Set loading state
  /// 2. Call register use case
  /// 3. On success: save user and set success state
  /// 4. On error: set error state with validation-friendly message
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = AuthUiState.loading();
    try {
      final user = await registerUseCase.call(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthUiState.success(user);
    } catch (e) {
      state = AuthUiState.error(_parseErrorMessage(e));
    }
  }

  /// Logout the current user
  ///
  /// Clears all authentication data and resets state to initial
  Future<void> logout() async {
    state = AuthUiState.loading();
    try {
      await logoutUseCase.call();
      state = AuthUiState.initial();
    } catch (e) {
      // Even on error, clear the auth state for security
      state = AuthUiState.initial();
    }
  }

  /// Check current user session
  ///
  /// Restores user session from persistent storage on app launch
  /// If user is logged in, loads their data; otherwise resets to initial state
  Future<void> restoreSession() async {
    try {
      final user = await getCurrentUserUseCase.call();
      state = AuthUiState.success(user);
    } catch (e) {
      // Session restore failure is not critical - continue as unauthenticated
      state = AuthUiState.initial();
    }
  }

  /// Parse error messages into user-friendly format
  ///
  /// Converts various error types into actionable messages for the UI
  String _parseErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();

      if (errorString.contains('invalid email')) {
        return 'Invalid email address';
      }
      if (errorString.contains('password')) {
        return 'Password must be at least 8 characters';
      }
      if (errorString.contains('already exists')) {
        return 'Email already registered';
      }
      if (errorString.contains('Unauthorized')) {
        return 'Invalid email or password';
      }
      if (errorString.contains('timeout')) {
        return 'Connection timeout. Please check your internet.';
      }
      if (errorString.contains('Network')) {
        return 'Network error. Please try again.';
      }
    }

    return error.toString().contains('Exception:')
        ? error.toString().replaceAll('Exception: ', '')
        : 'An error occurred. Please try again.';
  }
}

/// Riverpod provider for AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthUiState>(
  (ref) {
    return AuthViewModel(
      loginUseCase: ref.watch(loginUseCaseProvider),
      registerUseCase: ref.watch(registerUseCaseProvider),
      logoutUseCase: ref.watch(logoutUseCaseProvider),
      getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    );
  },
);

/// Convenience provider for getting just the current user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authViewModelProvider).user;
});

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider).isAuthenticated;
});
