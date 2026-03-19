import 'package:saluun_frontend/domain/entities/booking_entity.dart';

class MyBookingsUiState {
  final bool isLoading;
  final List<BookingEntity> bookings;
  final String? errorMessage;
  final bool isEmpty;

  const MyBookingsUiState({
    required this.isLoading,
    this.bookings = const [],
    this.errorMessage,
    this.isEmpty = false,
  });

  const MyBookingsUiState.initial()
    : this(
        isLoading: false,
        bookings: const [],
        errorMessage: null,
        isEmpty: false,
      );

  MyBookingsUiState.loading()
    : this(
        isLoading: true,
        bookings: const [],
        errorMessage: null,
        isEmpty: false,
      );

  MyBookingsUiState.success(List<BookingEntity> bookings)
    : this(
        isLoading: false,
        bookings: bookings,
        errorMessage: null,
        isEmpty: bookings.isEmpty,
      );

  MyBookingsUiState.error(String errorMessage)
    : this(
        isLoading: false,
        bookings: const [],
        errorMessage: errorMessage,
        isEmpty: false,
      );

  static const _unset = Object();

  MyBookingsUiState copyWith({
    bool? isLoading,
    Object? bookings = _unset,
    String? errorMessage,
    bool? isEmpty,
  }) {
    return MyBookingsUiState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings == _unset
          ? this.bookings
          : bookings as List<BookingEntity>,
      errorMessage: errorMessage,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  @override
  String toString() {
    return 'MyBookingsUiState(isLoading: $isLoading, bookingCount: ${bookings.length}, errorMessage: $errorMessage, isEmpty: $isEmpty)';
  }
}
