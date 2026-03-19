import '../entities/salon_entity.dart';

abstract class SalonRepository {
  Future<List<SalonEntity>> getAllSalons({int? page, int? limit});

  Future<SalonEntity> getSalonById(String id);

  Future<List<SalonEntity>> searchSalons({
    String? search,
    String? location,
    double? minRating,
    double? maxPrice,
  });

  Future<List<String>> getAvailableSlots(String salonId, String date);
}
