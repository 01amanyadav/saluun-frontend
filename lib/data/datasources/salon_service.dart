import 'package:dio/dio.dart';
import 'package:saluun_frontend/core/constants/app_constants.dart';
import 'package:saluun_frontend/data/models/api_models.dart';

/// Salon API Service
class SalonService {
  final Dio _dio;

  SalonService(this._dio);

  /// Get all salons
  Future<List<Salon>> getAllSalons({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        AppConstants.salons,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> salonsList = data['data'] ?? data ?? [];
        return salonsList.map((json) => Salon.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch salons',
        );
      }
    } on DioException catch (e) {
      print('Error fetching salons: ${e.message}');
      rethrow;
    }
  }

  /// Get single salon by ID
  Future<Salon> getSalonById(String id) async {
    try {
      final endpoint = AppConstants.salonDetails.replaceFirst(':id', id);
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        return Salon.fromJson(data['data'] ?? data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch salon',
        );
      }
    } on DioException catch (e) {
      print('Error fetching salon: ${e.message}');
      rethrow;
    }
  }

  /// Search salons
  Future<List<Salon>> searchSalons({
    String? search,
    String? location,
    double? minRating,
    double? maxPrice,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.salonSearch,
        queryParameters: {
          if (search != null) 'search': search,
          if (location != null) 'location': location,
          if (minRating != null) 'minRating': minRating,
          if (maxPrice != null) 'maxPrice': maxPrice,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> salonsList = data['data'] ?? data ?? [];
        return salonsList.map((json) => Salon.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Search failed',
        );
      }
    } on DioException catch (e) {
      print('Error searching salons: ${e.message}');
      rethrow;
    }
  }

  /// Get available time slots for a salon on a date
  Future<List<String>> getAvailableSlots(String salonId, String date) async {
    try {
      final endpoint = AppConstants.salonSlots.replaceFirst(':id', salonId);
      final response = await _dio.get(
        endpoint,
        queryParameters: {'date': date},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> slots = data['data'] ?? data ?? [];
        return slots.map((slot) => slot.toString()).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch slots',
        );
      }
    } on DioException catch (e) {
      print('Error fetching slots: ${e.message}');
      rethrow;
    }
  }

  /// Get services for a salon
  Future<List<Service>> getSalonServices(String salonId) async {
    try {
      final endpoint = AppConstants.salonServices.replaceFirst(
        ':salonId',
        salonId,
      );
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> servicesList = data['data'] ?? data ?? [];
        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch services',
        );
      }
    } on DioException catch (e) {
      print('Error fetching services: ${e.message}');
      rethrow;
    }
  }
}
