import 'package:saluun_frontend/domain/entities/salon_entity.dart';

/// UI state for home/salon listing screens
/// Provides clean separation between domain data and presentation layer
class HomeUiState {
  final bool isLoading;
  final List<SalonEntity> salons;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedRatingFilter;
  final String? selectedSortBy;

  const HomeUiState({
    this.isLoading = false,
    this.salons = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedRatingFilter,
    this.selectedSortBy,
  });

  /// Factory constructor for loading state
  factory HomeUiState.loading() {
    return const HomeUiState(isLoading: true);
  }

  /// Factory constructor for success state
  factory HomeUiState.success({
    required List<SalonEntity> salons,
    String searchQuery = '',
    String? selectedRatingFilter,
    String? selectedSortBy,
  }) {
    return HomeUiState(
      isLoading: false,
      salons: salons,
      searchQuery: searchQuery,
      selectedRatingFilter: selectedRatingFilter,
      selectedSortBy: selectedSortBy,
    );
  }

  /// Factory constructor for error state
  factory HomeUiState.error(String message) {
    return HomeUiState(isLoading: false, errorMessage: message);
  }

  /// Factory constructor for initial state
  factory HomeUiState.initial() {
    return const HomeUiState();
  }

  /// Copy with method for immutability
  HomeUiState copyWith({
    bool? isLoading,
    List<SalonEntity>? salons,
    String? errorMessage,
    String? searchQuery,
    String? selectedRatingFilter,
    String? selectedSortBy,
  }) {
    return HomeUiState(
      isLoading: isLoading ?? this.isLoading,
      salons: salons ?? this.salons,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRatingFilter: selectedRatingFilter ?? this.selectedRatingFilter,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
    );
  }

  /// Check if there are any salons to display
  bool get hasSalons => salons.isNotEmpty;

  /// Check if state is empty (no salons and no error)
  bool get isEmpty => salons.isEmpty && errorMessage == null;

  /// Get filtered salons based on rating
  List<SalonEntity> get filteredSalons {
    var filtered = salons;

    if (selectedRatingFilter != null) {
      final minRating = double.tryParse(selectedRatingFilter!) ?? 0;
      filtered = filtered.where((s) => (s.rating ?? 0) >= minRating).toList();
    }

    if (selectedSortBy == 'rating' && selectedSortBy != null) {
      filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (selectedSortBy == 'reviews' && selectedSortBy != null) {
      filtered.sort(
        (a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0),
      );
    } else if (selectedSortBy == 'name' && selectedSortBy != null) {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }
}
