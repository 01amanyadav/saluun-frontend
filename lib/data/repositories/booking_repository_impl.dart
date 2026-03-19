import 'package:saluun_frontend/data/datasources/booking_service.dart';
import 'package:saluun_frontend/domain/entities/booking_entity.dart';
import 'package:saluun_frontend/domain/repositories/booking_repository.dart';
import '../models/api_models.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService bookingService;

  BookingRepositoryImpl({required this.bookingService});

  @override
  Future<List<BookingEntity>> getUserBookings() async {
    final bookings = await bookingService.getUserBookings();
    return bookings.map(_mapBookingToEntity).toList();
  }

  @override
  Future<BookingEntity> createBooking({
    required String salonId,
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    final booking = await bookingService.createBooking(
      salonId: salonId,
      serviceId: serviceId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
    );
    return _mapBookingToEntity(booking);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await bookingService.cancelBooking(bookingId);
  }

  @override
  Future<BookingEntity> getBookingById(String bookingId) async {
    // This would typically require an additional endpoint
    throw UnimplementedError('getBookingById not implemented');
  }

  BookingEntity _mapBookingToEntity(Booking booking) {
    return BookingEntity(
      id: booking.id,
      userId: booking.userId,
      salonId: booking.salonId,
      serviceId: booking.serviceId,
      bookingDate: booking.bookingDate,
      bookingTime: booking.bookingTime,
      status: booking.status,
      totalPrice: booking.totalPrice,
    );
  }
}
