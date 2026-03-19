import 'package:dio/dio.dart';
import 'package:saluun_frontend/core/constants/app_constants.dart';
import 'package:saluun_frontend/data/models/api_models.dart';

/// Booking API Service
class BookingService {
  final Dio _dio;

  BookingService(this._dio);

  /// Get user's bookings
  Future<List<Booking>> getUserBookings({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        AppConstants.bookingMyBookings,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> bookingsList = data['data'] ?? data ?? [];
        return bookingsList.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch bookings',
        );
      }
    } on DioException catch (e) {
      print('Error fetching bookings: ${e.message}');
      rethrow;
    }
  }

  /// Create new booking
  Future<Booking> createBooking({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.bookings,
        data: {
          'salonId': int.parse(salonId),
          'serviceId': int.parse(serviceId),
          'date': bookingDate,
          'time': bookingTime,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        return Booking.fromJson(data['data'] ?? data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create booking',
        );
      }
    } on DioException catch (e) {
      print('Error creating booking: ${e.message}');
      rethrow;
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      final endpoint = AppConstants.bookingCancel.replaceFirst(
        ':bookingId',
        bookingId,
      );
      final response = await _dio.put(endpoint);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to cancel booking',
        );
      }
    } on DioException catch (e) {
      print('Error canceling booking: ${e.message}');
      rethrow;
    }
  }
}
