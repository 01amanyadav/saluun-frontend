import 'package:saluun_frontend/domain/entities/booking_entity.dart';

class BookingUiState {
  final bool isLoading;
  final BookingEntity? booking;
  final String? errorMessage;
  final bool isSuccess;

  const BookingUiState({
    required this.isLoading,
    this.booking,
    this.errorMessage,
    this.isSuccess = false,
  });

  const BookingUiState.initial()
    : this(
        isLoading: false,
        booking: null,
        errorMessage: null,
        isSuccess: false,
      );

  BookingUiState.loading()
    : this(
        isLoading: true,
        booking: null,
        errorMessage: null,
        isSuccess: false,
      );

  BookingUiState.success(BookingEntity booking)
    : this(
        isLoading: false,
        booking: booking,
        errorMessage: null,
        isSuccess: true,
      );

  BookingUiState.error(String errorMessage)
    : this(
        isLoading: false,
        booking: null,
        errorMessage: errorMessage,
        isSuccess: false,
      );

  static const _unset = Object();

  BookingUiState copyWith({
    bool? isLoading,
    Object? booking = _unset,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return BookingUiState(
      isLoading: isLoading ?? this.isLoading,
      booking: booking == _unset ? this.booking : booking as BookingEntity?,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() {
    return 'BookingUiState(isLoading: $isLoading, booking: $booking, errorMessage: $errorMessage, isSuccess: $isSuccess)';
  }
}
