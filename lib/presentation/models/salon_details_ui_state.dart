import 'package:saluun_frontend/domain/entities/salon_entity.dart';
import 'package:saluun_frontend/domain/entities/service_entity.dart';

/// UI state for salon details screen
/// Manages salon information and service listings with proper state transitions
class SalonDetailsUiState {
  final bool isLoading;
  final SalonEntity? salon;
  final List<ServiceEntity> services;
  final String? errorMessage;
  final bool isLoadingServices;

  const SalonDetailsUiState({
    this.isLoading = false,
    this.salon,
    this.services = const [],
    this.errorMessage,
    this.isLoadingServices = false,
  });

  /// Factory constructor for loading state
  factory SalonDetailsUiState.loading() {
    return const SalonDetailsUiState(isLoading: true);
  }

  /// Factory constructor for success state with salon and services
  factory SalonDetailsUiState.success({
    required SalonEntity salon,
    List<ServiceEntity> services = const [],
  }) {
    return SalonDetailsUiState(
      isLoading: false,
      salon: salon,
      services: services,
      errorMessage: null,
    );
  }

  /// Factory constructor for error state
  factory SalonDetailsUiState.error(String message) {
    return SalonDetailsUiState(isLoading: false, errorMessage: message);
  }

  /// Factory constructor for initial state
  factory SalonDetailsUiState.initial() {
    return const SalonDetailsUiState();
  }

  /// Copy with method for immutability
  SalonDetailsUiState copyWith({
    bool? isLoading,
    SalonEntity? salon,
    List<ServiceEntity>? services,
    String? errorMessage,
    bool? isLoadingServices,
  }) {
    return SalonDetailsUiState(
      isLoading: isLoading ?? this.isLoading,
      salon: salon ?? this.salon,
      services: services ?? this.services,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
    );
  }

  /// Check if salon data is available
  bool get hasSalonData => salon != null && errorMessage == null;

  /// Check if services are available
  bool get hasServices => services.isNotEmpty;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Get displayed services (can be extended to support filtering)
  List<ServiceEntity> get displayedServices => services;

  /// Get average price of all services
  double? get averagePrice {
    if (services.isEmpty) return null;
    final total = services.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
    return total / services.length;
  }

  /// Get cheapest service
  ServiceEntity? get cheapestService {
    if (services.isEmpty) return null;
    return services.reduce((a, b) => a.price < b.price ? a : b);
  }

  /// Get most expensive service
  ServiceEntity? get mostExpensiveService {
    if (services.isEmpty) return null;
    return services.reduce((a, b) => a.price > b.price ? a : b);
  }
}
