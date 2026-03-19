import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/domain/entities/booking_entity.dart';
import 'package:saluun_frontend/data/datasources/booking_service.dart';
import 'package:saluun_frontend/data/repositories/booking_repository_impl.dart';
import 'package:saluun_frontend/domain/repositories/booking_repository.dart';
import 'package:saluun_frontend/domain/usecases/booking/get_bookings_usecase.dart';
import 'package:saluun_frontend/domain/usecases/booking/create_booking_usecase.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/booking_ui_state.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/booking_view_model.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/my_bookings_ui_state.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/my_bookings_view_model.dart';
import 'core_providers.dart';

// Booking Service Provider
final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(ref.watch(dioClientProvider).dio),
);

// Booking Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    bookingService: ref.watch(bookingServiceProvider),
  );
});

// Use Case Providers
final getBookingsUseCaseProvider = Provider<GetBookingsUseCase>((ref) {
  return GetBookingsUseCase(ref.watch(bookingRepositoryProvider));
});

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  return CreateBookingUseCase(ref.watch(bookingRepositoryProvider));
});

// Bookings List Provider
final bookingsProvider = FutureProvider<List<BookingEntity>>((ref) async {
  final useCase = ref.watch(getBookingsUseCaseProvider);
  return await useCase.call();
});

// Create Booking Notifier
class CreateBookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final CreateBookingUseCase createBookingUseCase;

  CreateBookingNotifier({required this.createBookingUseCase})
    : super(const AsyncValue.data(null));

  Future<void> createBooking({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await createBookingUseCase.call(
        salonId: salonId,
        serviceId: serviceId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Create Booking Provider
final createBookingProvider =
    StateNotifierProvider<CreateBookingNotifier, AsyncValue<BookingEntity?>>((
      ref,
    ) {
      return CreateBookingNotifier(
        createBookingUseCase: ref.watch(createBookingUseCaseProvider),
      );
    });

// Booking ViewModel Provider (StateNotifierProvider) - For BookingScreen
final bookingViewModelProvider =
    StateNotifierProvider<BookingViewModelNotifier, BookingUiState>((ref) {
      final bookingRepository = ref.watch(bookingRepositoryProvider);
      return BookingViewModelNotifier(bookingRepository);
    });

// My Bookings ViewModel Provider - For MyBookingsScreen
final myBookingsViewModelProvider =
    StateNotifierProvider<MyBookingsViewModelNotifier, MyBookingsUiState>((
      ref,
    ) {
      final bookingRepository = ref.watch(bookingRepositoryProvider);
      return MyBookingsViewModelNotifier(bookingRepository);
    });
