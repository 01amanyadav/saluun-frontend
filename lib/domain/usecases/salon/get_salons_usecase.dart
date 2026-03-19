import '../../entities/salon_entity.dart';
import '../../repositories/salon_repository.dart';

class GetSalonsUseCase {
  final SalonRepository repository;

  GetSalonsUseCase(this.repository);

  Future<List<SalonEntity>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getAllSalons(page: page, limit: limit);
  }
}
