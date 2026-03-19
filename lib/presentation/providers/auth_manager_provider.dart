import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/core/auth/auth_manager.dart';
import 'package:saluun_frontend/core/network/dio_client.dart';
import 'package:saluun_frontend/core/utils/token_service.dart';
import 'package:saluun_frontend/core/utils/user_service.dart';
import 'package:saluun_frontend/presentation/providers/core_providers.dart';

/// Provider for the AuthManager singleton
///
/// AuthManager centralizes all authentication operations:
/// - Token management
/// - Session persistence
/// - Login/logout/register flows
/// - Global auth state
final authManagerProvider = Provider<AuthManager>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authManager = AuthManager(
    authRepository: authRepository,
    tokenService: tokenService,
    userService: userService,
  );

  // Setup callback for 401 errors from DioClient
  DioClient.setSessionExpiredCallback(() {
    authManager.handleSessionExpired().then((_) {
      // Reset auth state in Riverpod
      ref.invalidate(authViewModelProvider);
    });
  });

  return authManager;
});

/// Provider to watch AuthManager's authentication state
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return authManager.isUserAuthenticated();
});

/// Provider to watch if AuthManager is initializing
final isInitializingAuthProvider = Provider<bool>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return authManager.isInitializing;
});

/// Provider to get current auth token
final currentAuthTokenProvider = FutureProvider<String?>((ref) async {
  final authManager = ref.watch(authManagerProvider);
  return await authManager.getToken();
});

/// Provider to watch auth errors
final authErrorProvider = Provider<String?>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return authManager.authError;
});
