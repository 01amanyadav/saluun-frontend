import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/booking_ui_state.dart';
import 'package:saluun_frontend/domain/repositories/booking_repository.dart';

/// StateNotifier for managing booking state
class BookingViewModelNotifier extends StateNotifier<BookingUiState> {
  final BookingRepository _bookingRepository;

  BookingViewModelNotifier(this._bookingRepository)
    : super(const BookingUiState.initial());

  /// Create a new booking
  Future<void> createBooking({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    state = BookingUiState.loading();

    try {
      final booking = await _bookingRepository.createBooking(
        salonId: salonId,
        serviceId: serviceId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );

      state = BookingUiState.success(booking);
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      state = BookingUiState.error(errorMessage);
    }
  }

  /// Reset state to initial
  void reset() {
    state = const BookingUiState.initial();
  }

  /// Clear error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('DioException')) {
        if (errorString.contains('Failed to create booking')) {
          return 'Failed to create booking. Please try again.';
        }
        if (errorString.contains('Connection')) {
          return 'Network error. Please check your internet connection.';
        }
      }
    }
    return 'An error occurred. Please try again.';
  }
}
