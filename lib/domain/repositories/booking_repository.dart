import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getUserBookings();

  Future<BookingEntity> createBooking({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  });

  Future<void> cancelBooking(String bookingId);

  Future<BookingEntity> getBookingById(String bookingId);
}
