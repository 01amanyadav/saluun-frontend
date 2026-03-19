import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/domain/entities/salon_entity.dart';
import 'package:saluun_frontend/domain/entities/service_entity.dart';
import 'package:saluun_frontend/data/datasources/salon_service.dart';
import 'package:saluun_frontend/data/models/api_models.dart';
import 'package:saluun_frontend/data/repositories/salon_repository_impl.dart';
import 'package:saluun_frontend/domain/repositories/salon_repository.dart';
import 'package:saluun_frontend/domain/usecases/salon/get_salons_usecase.dart';
import 'package:saluun_frontend/domain/usecases/salon/search_salons_usecase.dart';
import 'package:saluun_frontend/presentation/models/salon_details.dart';
import 'core_providers.dart';

// Salon Service Provider
final salonServiceProvider = Provider<SalonService>(
  (ref) => SalonService(ref.watch(dioClientProvider).dio),
);

// Salon Repository Provider
final salonRepositoryProvider = Provider<SalonRepository>((ref) {
  return SalonRepositoryImpl(salonService: ref.watch(salonServiceProvider));
});

// Use Case Providers
final getSalonsUseCaseProvider = Provider<GetSalonsUseCase>((ref) {
  return GetSalonsUseCase(ref.watch(salonRepositoryProvider));
});

final searchSalonsUseCaseProvider = Provider<SearchSalonsUseCase>((ref) {
  return SearchSalonsUseCase(ref.watch(salonRepositoryProvider));
});

// State Management for Salons
final salonsPageProvider = StateProvider<int>((ref) => 1);
final salonsLimitProvider = StateProvider<int>((ref) => 10);

// Salons List Provider
final salonsProvider = FutureProvider<List<SalonEntity>>((ref) async {
  final useCase = ref.watch(getSalonsUseCaseProvider);
  final page = ref.watch(salonsPageProvider);
  final limit = ref.watch(salonsLimitProvider);
  return await useCase.call(page: page, limit: limit);
});

// Search Query Provider
final salonSearchQueryProvider = StateProvider<String>((ref) => '');

// Searched Salons Provider
final searchedSalonsProvider = FutureProvider<List<SalonEntity>>((ref) async {
  final query = ref.watch(salonSearchQueryProvider);
  if (query.isEmpty) return [];

  final useCase = ref.watch(searchSalonsUseCaseProvider);
  return await useCase.call(
    search: query,
    location: null,
    minRating: null,
    maxPrice: null,
  );
});

// Selected Salon Provider
final selectedSalonProvider = StateProvider<SalonEntity?>((ref) => null);

// Filter Providers
/// Rating filter: '3.5', '4.0', '4.5', or null for no filter
final ratingFilterProvider = StateProvider<String?>((ref) => null);

/// Sort option: 'rating', 'reviews', 'name', or null for default
final sortByProvider = StateProvider<String?>((ref) => null);

/// Get filtered salons based on search query, rating, and sort option
final filteredSalonsProvider = FutureProvider<List<SalonEntity>>((ref) async {
  final searchQuery = ref.watch(salonSearchQueryProvider);
  final ratingFilter = ref.watch(ratingFilterProvider);
  final sortBy = ref.watch(sortByProvider);

  // Get base list
  List<SalonEntity> salons;
  if (searchQuery.isNotEmpty) {
    salons = await ref.watch(searchedSalonsProvider.future);
  } else {
    salons = await ref.watch(salonsProvider.future);
  }

  // Apply rating filter
  if (ratingFilter != null) {
    final minRating = double.tryParse(ratingFilter) ?? 0;
    salons = salons.where((s) => (s.rating ?? 0) >= minRating).toList();
  }

  // Apply sorting
  switch (sortBy) {
    case 'rating':
      salons.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      break;
    case 'reviews':
      salons.sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
      break;
    case 'name':
      salons.sort((a, b) => a.name.compareTo(b.name));
      break;
    default:
      // Keep original order
      break;
  }

  return salons;
});

/// Get available rating filter options
final ratingFiltersProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'label': '4.5+ stars', 'value': '4.5'},
    {'label': '4.0+ stars', 'value': '4.0'},
    {'label': '3.5+ stars', 'value': '3.5'},
    {'label': '3.0+ stars', 'value': '3.0'},
  ];
});

/// Get available sort options
final sortOptionsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'label': 'Highest Rated', 'value': 'rating'},
    {'label': 'Most Reviews', 'value': 'reviews'},
    {'label': 'Name (A-Z)', 'value': 'name'},
  ];
});

// Salon Details Providers
/// Selected salon ID for details view
final selectedSalonIdProvider = StateProvider<String?>((ref) => null);

/// Fetch single salon by ID
final salonDetailsProvider = FutureProvider.family<SalonEntity, String>((
  ref,
  salonId,
) async {
  final repository = ref.watch(salonRepositoryProvider);
  try {
    // Call repository to get salon details
    final salon = await repository.getSalonById(salonId);
    return salon;
  } catch (e) {
    rethrow;
  }
});

/// Fetch services for a salon by ID
final salonServicesProvider =
    FutureProvider.family<List<ServiceEntity>, String>((ref, salonId) async {
      final salonService = ref.watch(salonServiceProvider);
      try {
        // Fetch services from API
        final servicesResponse = await salonService.getSalonServices(salonId);
        // Map API models to domain entities
        return servicesResponse
            .map(
              (serviceModel) => ServiceEntity(
                id: serviceModel.id,
                salonId: serviceModel.salonId,
                name: serviceModel.name,
                description: serviceModel.description,
                price: serviceModel.price,
                durationMinutes: serviceModel.durationMinutes,
                category: serviceModel.category,
                popularity: serviceModel.popularity,
              ),
            )
            .toList();
      } catch (e) {
        rethrow;
      }
    });

/// Combined provider that returns SalonDetails with salon and services
/// Used by BookingScreen to get all salon information with services
final salonDetailsWithServicesProvider =
    FutureProvider.family<SalonDetails?, String>((ref, salonId) async {
      try {
        final salonAsync = ref.watch(salonDetailsProvider(salonId));
        final servicesAsync = ref.watch(salonServicesProvider(salonId));

        return salonAsync.when(
          data: (salon) {
            if (salon == null) return null;
            return servicesAsync.when(
              data: (services) {
                // Map ServiceEntity to Service model for compatibility
                final serviceModels = services
                    .map(
                      (entity) => Service(
                        id: entity.id,
                        salonId: entity.salonId,
                        name: entity.name,
                        description: entity.description,
                        price: entity.price,
                        durationMinutes: entity.durationMinutes,
                        category: entity.category,
                        popularity: entity.popularity,
                      ),
                    )
                    .toList();
                return SalonDetails(salon: salon, services: serviceModels);
              },
              loading: () => null,
              error: (err, stack) =>
                  SalonDetails(salon: salon, services: const []),
            );
          },
          loading: () => null,
          error: (err, stack) => null,
        );
      } catch (e) {
        rethrow;
      }
    });
