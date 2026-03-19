import '../../entities/salon_entity.dart';
import '../../repositories/salon_repository.dart';

class SearchSalonsUseCase {
  final SalonRepository repository;

  SearchSalonsUseCase(this.repository);

  Future<List<SalonEntity>> call({
    String? search,
    String? location,
    double? minRating,
    double? maxPrice,
  }) async {
    return await repository.searchSalons(
      search: search,
      location: location,
      minRating: minRating,
      maxPrice: maxPrice,
    );
  }
}
