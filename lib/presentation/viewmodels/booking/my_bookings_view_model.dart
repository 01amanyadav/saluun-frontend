import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/my_bookings_ui_state.dart';
import 'package:saluun_frontend/domain/repositories/booking_repository.dart';

/// StateNotifier for managing my bookings state
class MyBookingsViewModelNotifier extends StateNotifier<MyBookingsUiState> {
  final BookingRepository _bookingRepository;

  MyBookingsViewModelNotifier(this._bookingRepository)
    : super(const MyBookingsUiState.initial());

  /// Fetch user's bookings
  Future<void> fetchMyBookings({int? page, int? limit}) async {
    state = MyBookingsUiState.loading();

    try {
      final bookings = await _bookingRepository.getUserBookings();
      state = MyBookingsUiState.success(bookings);
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      state = MyBookingsUiState.error(errorMessage);
    }
  }

  /// Reset state to initial
  void reset() {
    state = const MyBookingsUiState.initial();
  }

  /// Retry fetching bookings
  Future<void> retry() async {
    await fetchMyBookings();
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
        if (errorString.contains('Failed to fetch bookings')) {
          return 'Failed to load bookings. Please try again.';
        }
        if (errorString.contains('Connection')) {
          return 'Network error. Please check your internet connection.';
        }
      }
    }
    return 'An error occurred. Please try again.';
  }
}
