import '../../entities/booking_entity.dart';
import '../../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> call({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    return await repository.createBooking(
      salonId: salonId,
      serviceId: serviceId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
    );
  }
}
