import 'package:saluun_frontend/data/datasources/salon_service.dart';
import 'package:saluun_frontend/domain/entities/salon_entity.dart';
import 'package:saluun_frontend/domain/repositories/salon_repository.dart';
import '../models/api_models.dart';

class SalonRepositoryImpl implements SalonRepository {
  final SalonService salonService;

  SalonRepositoryImpl({required this.salonService});

  @override
  Future<List<SalonEntity>> getAllSalons({int? page, int? limit}) async {
    final salons = await salonService.getAllSalons(page: page, limit: limit);
    return salons.map(_mapSalonToEntity).toList();
  }

  @override
  Future<SalonEntity> getSalonById(String id) async {
    final salon = await salonService.getSalonById(id);
    return _mapSalonToEntity(salon);
  }

  @override
  Future<List<SalonEntity>> searchSalons({
    String? search,
    String? location,
    double? minRating,
    double? maxPrice,
  }) async {
    final salons = await salonService.searchSalons(
      search: search,
      location: location,
      minRating: minRating,
      maxPrice: maxPrice,
    );
    return salons.map(_mapSalonToEntity).toList();
  }

  @override
  Future<List<String>> getAvailableSlots(String salonId, String date) async {
    return await salonService.getAvailableSlots(salonId, date);
  }

  SalonEntity _mapSalonToEntity(Salon salon) {
    return SalonEntity(
      id: salon.id,
      name: salon.name,
      location: salon.location,
      description: salon.description,
      phone: salon.phone,
      email: salon.email,
      image: salon.image,
      rating: salon.rating,
      reviewCount: salon.reviewCount,
      openingTime: salon.openingTime,
      closingTime: salon.closingTime,
    );
  }
}
