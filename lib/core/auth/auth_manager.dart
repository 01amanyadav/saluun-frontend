import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/core/utils/token_service.dart';
import 'package:saluun_frontend/core/utils/user_service.dart';
import 'package:saluun_frontend/domain/repositories/auth_repository.dart';

/// AuthManager - Centralized authentication state and operations
///
/// Responsibilities:
/// - Manage authentication state globally
/// - Handle token persistence and retrieval
/// - Coordinate login/logout/register flows
/// - Provide session restoration on app start
/// - Handle authentication errors (401, expiry, etc.)
class AuthManager {
  final AuthRepository _authRepository;
  final TokenService _tokenService;
  final UserService _userService;

  // Internal state
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  String? _currentToken;
  String? _authError;

  // Callbacks for global navigation and state updates
  Function(String)? onLogout;
  Function()? onSessionExpired;

  AuthManager({
    required AuthRepository authRepository,
    required TokenService tokenService,
    required UserService userService,
  }) : _authRepository = authRepository,
       _tokenService = tokenService,
       _userService = userService;

  // Getters for state
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  String? get currentToken => _currentToken;
  String? get authError => _authError;

  /// Initialize authentication state on app launch
  /// Checks for existing token and validates session
  Future<void> initialize() async {
    try {
      _isInitializing = true;
      _authError = null;

      // Check if token exists
      final token = await _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentToken = null;
      }
    } catch (e) {
      _authError = 'Failed to restore session: $e';
      _isAuthenticated = false;
      _currentToken = null;
    } finally {
      _isInitializing = false;
    }
  }

  /// Handle login
  Future<void> login(String email, String password) async {
    try {
      _authError = null;

      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      // Token was saved by repository
      _currentToken = await _tokenService.getAccessToken();
      _isAuthenticated = true;
      _authError = null;
    } catch (e) {
      _authError = 'Login failed: $e';
      _isAuthenticated = false;
      _currentToken = null;
      rethrow;
    }
  }

  /// Handle registration
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _authError = null;

      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Token was saved by repository
      _currentToken = await _tokenService.getAccessToken();
      _isAuthenticated = true;
      _authError = null;
    } catch (e) {
      _authError = 'Registration failed: $e';
      _isAuthenticated = false;
      _currentToken = null;
      rethrow;
    }
  }

  /// Handle logout
  /// Clears all local auth state and calls callback for navigation
  Future<void> logout({bool clearError = true}) async {
    try {
      // Clear auth state
      _isAuthenticated = false;
      _currentToken = null;

      if (clearError) {
        _authError = null;
      }

      // Clear from storage and user service
      await _authRepository.logout();

      // Notify listeners (typically triggers navigation to login)
      onLogout?.call('User logged out');
    } catch (e) {
      _authError = 'Logout failed: $e';
      rethrow;
    }
  }

  /// Handle session expiration (401 Unauthorized)
  /// Called by interceptor when API returns 401
  Future<void> handleSessionExpired() async {
    _authError = 'Your session has expired. Please login again.';
    _isAuthenticated = false;
    _currentToken = null;

    // Clear from storage
    await _tokenService.clearTokens();
    await _userService.clearUser();

    // Notify listeners
    onSessionExpired?.call();
  }

  /// Clear any stored error message
  void clearError() {
    _authError = null;
  }

  /// Get the current JWT token
  Future<String?> getToken() async {
    return await _tokenService.getAccessToken();
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    return _isAuthenticated && _currentToken != null;
  }

  /// Refresh authentication state (useful for manual sync)
  Future<void> refreshAuthState() async {
    final token = await _tokenService.getAccessToken();
    _isAuthenticated = token != null && token.isNotEmpty;
    _currentToken = token;
  }
}
