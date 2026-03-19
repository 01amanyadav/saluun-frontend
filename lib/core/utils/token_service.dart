import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Service to manage JWT token storage and retrieval
class TokenService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    return _prefs.setString(AppConstants.accessTokenKey, token);
  }

  /// Get access token
  String? getAccessToken() {
    return _prefs.getString(AppConstants.accessTokenKey);
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    return _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  /// Clear all tokens
  Future<bool> clearTokens() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
    return _prefs.remove(AppConstants.isLoggedInKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getAccessToken() != null;
  }

  /// Add token to request headers
  void addTokenToHeaders(RequestOptions options) {
    final token = getAccessToken();
    if (token != null) {
      options.headers[AppConstants.jwtAuthHeader] =
          '${AppConstants.jwtBearerPrefix}$token';
    }
  }
}

/// Singleton instance
final tokenService = TokenService();
