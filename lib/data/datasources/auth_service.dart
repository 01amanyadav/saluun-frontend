import 'package:dio/dio.dart';
import 'package:saluun_frontend/core/constants/app_constants.dart';
import 'package:saluun_frontend/core/utils/token_service.dart';
import 'package:saluun_frontend/data/models/api_models.dart';

/// Authentication API Service
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Register new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.authRegister,
        data: {'name': name, 'email': email, 'password': password},
      );

      final data = response.data;
      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);

        // Save token if provided
        if (authResponse.token != null) {
          await tokenService.saveAccessToken(authResponse.token!);
        }

        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      print('Registration error: ${e.message}');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.authLogin,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);

        // Save token
        if (authResponse.token != null) {
          await tokenService.saveAccessToken(authResponse.token!);
        }

        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await tokenService.clearTokens();
  }
}
