import 'package:dio/dio.dart';
import 'package:saluun_frontend/core/constants/app_constants.dart';
import 'package:saluun_frontend/data/models/api_models.dart';

/// User API Service
class UserAPIService {
  final Dio _dio;

  UserAPIService(this._dio);

  /// Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _dio.get(AppConstants.userProfile);

      if (response.statusCode == 200) {
        final data = response.data;
        return User.fromJson(data['data'] ?? data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch profile',
        );
      }
    } on DioException catch (e) {
      print('Error fetching profile: ${e.message}');
      rethrow;
    }
  }
}
