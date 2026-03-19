class BookingEntity {
  final String id;
  final String userId;
  final String salonId;
  final String serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String status; // pending, confirmed, completed, cancelled
  final double? totalPrice;

  BookingEntity({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.totalPrice,
  });
}
