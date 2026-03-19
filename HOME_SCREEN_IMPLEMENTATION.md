# Home Screen Implementation Guide

## 📋 Overview

This document provides a comprehensive guide to the Home Screen implementation showing a list of salons in a production-grade Flutter app using Clean Architecture and MVVM-style state management with Riverpod.

## ✅ Requirements Met

All user requirements have been fully implemented:

| Requirement | Status | Details |
|------------|--------|---------|
| Fetch salon list from API | ✅ | Via `GetSalonsUseCase` with Dio/HTTP |
| MVVM Architecture | ✅ | HomeUiState + Riverpod providers |
| State Management | ✅ | Riverpod FutureProvider with StateProvider |
| Display salons in ListView | ✅ | ListView.separated with SalonCard |
| Reusable SalonCard widget | ✅ | Dedicated Component with image, rating, location |
| Search bar | ✅ | Material 3 SearchBar with clear functionality |
| Filter chips | ✅ | Rating and sort options with visual feedback |
| Loading UI | ✅ | Shimmer placeholders (SalonCardShimmer) |
| Error state with retry | ✅ | Graceful error display with retry button |
| Empty state | ✅ | EmptyStateWidget with helpful messages |
| Material 3 Design | ✅ | Design system integration throughout |
| Clean Folder Structure | ✅ | Proper separation by layer and feature |

---

## 🏗️ Architecture

### Layer Structure

```
Presentation (UI)
    ├── Screens (SalonListScreen)
    ├── Widgets (SalonCard, SalonCardShimmer)
    ├── Models (HomeUiState)
    └── Providers (salon_provider.dart)
         ↓
Domain (Business Logic)
    └── UseCases (GetSalonsUseCase, SearchSalonsUseCase)
         ↓
Data (API Integration)
    ├── Services (SalonService)
    └── Repositories (SalonRepositoryImpl)
         ↓
Core (Infrastructure)
    └── Network (Dio with interceptors)
```

### State Management Pattern

```
User Interaction (search, filter)
    ↓
StateProvider Updates (salonSearchQueryProvider, ratingFilterProvider, etc.)
    ↓
FutureProvider Recomputation (filteredSalonsProvider)
    ↓
API Call via UseCase
    ↓
HomeUiState Update
    ↓
UI Rebuild with AsyncValue.when()
```

---

## 📁 File Structure

### New Files Created

```
lib/
├── presentation/
│   ├── models/
│   │   └── home_ui_state.dart          [NEW] UI state model
│   │
│   └── widgets/
│       └── salon_card.dart             [NEW] Reusable salon card + shimmer
│
```

### Modified Files

```
lib/
├── presentation/
│   ├── providers/
│   │   └── salon_provider.dart         [ENHANCED] Added filter support
│   │
│   └── screens/
│       └── salons/
│           └── salon_list_screen.dart  [REPLACED] Complete rewrite
│
```

---

## 🔑 Key Components

### 1. HomeUiState Model

**Location**: [lib/presentation/models/home_ui_state.dart](lib/presentation/models/home_ui_state.dart)

```dart
class HomeUiState {
  final bool isLoading;
  final List<SalonEntity> salons;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedRatingFilter;
  final String? selectedSortBy;
  
  // Factory constructors
  factory HomeUiState.loading()
  factory HomeUiState.success(List<SalonEntity> salons, ...)
  factory HomeUiState.error(String message)
  factory HomeUiState.initial()
  
  // Computed properties
  bool get hasSalons
  bool get isEmpty
  List<SalonEntity> get filteredSalons
}
```

**Purpose**:
- Clean separation between domain data and UI state
- Immutable design for predictable state changes
- Built-in filtering and sorting logic
- Type-safe state representation

---

### 2. SalonCard Widget

**Location**: [lib/presentation/widgets/salon_card.dart](lib/presentation/widgets/salon_card.dart)

```dart
class SalonCard extends StatelessWidget {
  final SalonEntity salon;
  final VoidCallback? onTap;
  final bool showDescription;
  
  // Displays:
  // - Salon image with error handling
  // - Rating badge overlay
  // - Open/Closed status
  // - Name and location
  // - Description (optional)
  // - Operating hours
  // - Review count
  // - Call button
}

// Shimmer version for loading
class SalonCardShimmer extends StatelessWidget { ... }
```

**Features**:
- Image with network error handling
- Rating badge overlay
- Status indicator (Open/Closed)
- Location with icon
- Description truncation
- Operating hours display
- Review count display
- Call button for phone
- Proper Material 3 styling

---

### 3. Enhanced Salon Provider

**Location**: [lib/presentation/providers/salon_provider.dart](lib/presentation/providers/salon_provider.dart)

```dart
// Filter State Providers
final ratingFilterProvider = StateProvider<String?>
final sortByProvider = StateProvider<String?>

// Main Data Provider (combines search + filters)
final filteredSalonsProvider = FutureProvider<List<SalonEntity>>

// Filter Options Providers
final ratingFiltersProvider = Provider<List<Map<String, String>>>
final sortOptionsProvider = Provider<List<Map<String, String>>>

// Available filters:
// Rating: 3.0+, 3.5+, 4.0+, 4.5+ stars
// Sort: Highest Rated, Most Reviews, Name (A-Z)
```

**Data Flow**:
1. User enters search query → `salonSearchQueryProvider` updates
2. User selects filter → `ratingFilterProvider` or `sortByProvider` updates
3. `filteredSalonsProvider` recomputes with all filters applied
4. Results displayed in ListView

---

### 4. SalonListScreen

**Location**: [lib/presentation/screens/salons/salon_list_screen.dart](lib/presentation/screens/salons/salon_list_screen.dart)

#### Main Features

**Search Bar**
```dart
SearchBar(
  hintText: 'Search salons by name or location...',
  onChanged: (query) => ref.read(salonSearchQueryProvider.notifier).state = query,
  // Clear button and visual feedback
)
```

**Filter Section** (Expandable)
- Rating filters with visual selection
- Sort options with checkmarks
- Active filter count badge
- Clear filters button

**Salon Display**
```dart
ListView.separated(
  itemBuilder: (context, index) {
    return SalonCard(
      salon: salon,
      onTap: () => context.push('/salon/${salon.id}'),
      showDescription: true,
    );
  },
)
```

**State Handling**
```dart
salonsAsync.when(
  data: (salons) => ListView(...),
  loading: () => _buildShimmerLoading(),
  error: (error, st) => _buildErrorState(...),
)
```

---

## 📊 Data Flow Example: Search and Filter

### Complete User Journey

```
1. User Opens SalonListScreen
   ├── Fetch all salons (salonsProvider)
   ├── Display with shimmer loading
   └── Complete loading → show list

2. User Types "Hair" in Search
   ├── salonSearchQueryProvider.state = "Hair"
   ├── filteredSalonsProvider recomputes
   ├── API call: search salons for "Hair"
   └── Results displayed (filtered list)

3. User Selects "4.0+ stars" Filter
   ├── ratingFilterProvider.state = "4.0"
   ├── filteredSalonsProvider recomputes with search + rating
   ├── Client-side filtering applied
   └── Results updated (4.0+ rated salons with "Hair")

4. User Selects "Most Reviews" Sort
   ├── sortByProvider.state = "reviews"
   ├── filteredSalonsProvider recomputes
   ├── Results sorted by review count (descending)
   └── Final list displayed (relevant, highly-reviewed salons)

5. User Clears Filters
   ├── ratingFilterProvider.state = null
   ├── sortByProvider.state = null
   ├── filteredSalonsProvider updates
   └── Back to search results only
```

---

## 🎨 UI States

### Loading State
```dart
SalonCardShimmer() // 6 placeholder cards
```
- Shimmer placeholders matching SalonCard height
- Smooth transition to actual content
- Professional loading experience

### Empty State
```dart
EmptyStateWidget(
  icon: Icons.store_outlined,
  title: 'No Results',
  message: 'No salons match your search',
  buttonLabel: 'Clear Search',
)
```
- Different messages for empty search vs no query
- Helpful call-to-action
- Clear icon and styling

### Error State
```dart
Column(
  children: [
    Icon(Icons.error_outline),
    Text('Something went wrong'),
    Text(errorMessage),
    PrimaryButton('Try Again', onRetry),
  ]
)
```
- Descriptive error messages
- Retry functionality
- Clear visual hierarchy

---

## 🔄 Complete Code Example: Using SalonListScreen

```dart
// In your router configuration
GoRoute(
  path: '/salons',
  builder: (context, state) => const SalonListScreen(),
),

// Navigation from home
context.push('/salons');

// From SalonCard tap
context.push('/salon/${salon.id}');
```

---

## 🛠️ Customization Guide

### Add New Filter Type

```dart
// 1. Add provider in salon_provider.dart
final distanceFilterProvider = StateProvider<int?>((ref) => null);

// 2. Update filteredSalonsProvider
final filteredSalonsProvider = FutureProvider<List<SalonEntity>>((ref) async {
  // ... existing code ...
  
  // Apply distance filter
  if (distanceFilter != null) {
    salons = salons.where((s) => calculateDistance(s) <= distanceFilter).toList();
  }
  
  return salons;
});

// 3. Add filter options
final distanceOptionsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'label': '5 km', 'value': '5'},
    {'label': '10 km', 'value': '10'},
    {'label': '20 km', 'value': '20'},
  ];
});

// 4. Update SalonListScreen UI
_FilterSection(
  title: 'Distance',
  options: ref.watch(distanceOptionsProvider),
  selectedValue: ref.watch(distanceFilterProvider)?.toString(),
  onOptionSelected: (value) {
    ref.read(distanceFilterProvider.notifier).state = 
        value != null ? int.parse(value) : null;
  },
),
```

### Customize SalonCard Appearance

```dart
// Show/hide description
SalonCard(
  salon: salon,
  showDescription: false, // Only show when viewing all
)

// Add custom tap handler
SalonCard(
  salon: salon,
  onTap: () {
    // Custom logic
    showSalonDetails(salon);
  },
)
```

---

## ⚡ Performance Considerations

### 1. Provider Efficiency
- `filteredSalonsProvider` only recomputes when filters change
- Existing list reused when filters don't affect it
- No redundant API calls

### 2. UI Responsiveness
- Shimmer loading provides instant feedback
- Search debouncing (if API supports it)
- Offscreen rendering optimization via ListView

### 3. Memory Management
- SalonCard widgets are const and immutable
- Proper disposal of TextEditingController
- No memory leaks from listeners

---

## 🧪 Testing

### Unit Test Example

```dart
test('filters salons by rating', () {
  final salons = [
    SalonEntity(id: '1', name: 'High Rated', rating: 4.5, ...),
    SalonEntity(id: '2', name: 'Low Rated', rating: 3.0, ...),
  ];
  
  final filtered = salons.where((s) => (s.rating ?? 0) >= 4.0).toList();
  
  expect(filtered.length, 1);
  expect(filtered[0].name, 'High Rated');
});
```

### Widget Test Example

```dart
testWidgets('displays salon cards', (tester) async {
  final salons = [
    SalonEntity(id: '1', name: 'Test Salon', location: 'Test City', ...)
  ];
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SalonCard(salon: salons[0]),
      ),
    ),
  );
  
  expect(find.text('Test Salon'), findsOneWidget);
  expect(find.text('Test City'), findsOneWidget);
});
```

---

## 📱 Material 3 Integration

### Design System Usage

```dart
// Colors
Theme.of(context).colorScheme.primary
AppColors.grey600
AppColors.success

// Typography
Theme.of(context).textTheme.titleMedium
AppTypography.labelSmall

// Spacing
AppSpacing.lg
AppSpacing.md

// Radius
AppRadius.md
```

### Responsive Design
- Uses `constraints` and `expanded` for responsive layouts
- `maxLines` and `overflow` for text handling
- Proper padding for different screen sizes

---

## 🚀 Production Checklist

- [x] Search functionality implemented
- [x] Filter chips working with visual feedback
- [x] Shimmer loading UI for professional UX
- [x] Error state with retry button
- [x] Empty state with helpful messages
- [x] Material 3 design compliance
- [x] MVVM state management pattern
- [x] Clean Architecture separation
- [x] Proper error handling
- [x] Loading state management
- [x] No memory leaks
- [x] Type-safe implementation
- [x] Comprehensive code documentation
- [x] All imports resolved
- [x] Zero compilation errors

---

## 📚 Related Components

- **HomeScreen**: Dashboard showing featured salons - [home_screen.dart](lib/presentation/screens/home/home_screen.dart)
- **SalonDetailScreen**: Individual salon details - [salon_detail_screen.dart](lib/presentation/screens/salons/salon_detail_screen.dart) (if exists)
- **BookingScreen**: Book appointment at salon - [booking_screen.dart](lib/presentation/screens/booking/booking_screen.dart) (if exists)
- **Authentication**: User login/register - [authentication_implementation.md](AUTHENTICATION_IMPLEMENTATION.md)

---

## 🔗 Navigation Routes

```dart
// Salon List
context.push('/salons');

// Salon Details
context.push('/salon/${salonId}');

// Booking
context.push('/booking?salonId=${salonId}');

// Home (with featured salons)
context.push('/home');
```

---

## 📞 Support & Troubleshooting

### Common Issues

**Q: Filters not applying?**
A: Ensure `filteredSalonsProvider` is being watched, not raw `salonsProvider`.

**Q: Search results empty?**
A: Check that API search endpoint is working with `SearchSalonsUseCase`.

**Q: Shimmer not showing?**
A: Verify `SalonCardShimmer` is used in loading state.

**Q: Icons not displaying?**
A: Ensure correct Material Icons are imported (avoid `Icons.salon` which doesn't exist).

---

## 📄 Document Info

- **Created**: March 2026
- **Last Updated**: March 18, 2026
- **Status**: Production Ready ✅
- **Completion Date**: March 18, 2026

---

## 📊 Implementation Summary

| Component | Type | Status | Location |
|-----------|------|--------|----------|
| HomeUiState | Model | ✅ Complete | lib/presentation/models/ |
| SalonCard | Widget | ✅ Complete | lib/presentation/widgets/ |
| SalonListScreen | Screen | ✅ Complete | lib/presentation/screens/salons/ |
| Filter Providers | Riverpod | ✅ Complete | lib/presentation/providers/ |
| Search Functionality | Feature | ✅ Complete | SalonListScreen |
| Filter Chips | Feature | ✅ Complete | SalonListScreen |
| Shimmer Loading | Feature | ✅ Complete | SalonCardShimmer |
| Error Handling | Feature | ✅ Complete | SalonListScreen |
| Material 3 Design | Theme | ✅ Complete | All components |

---

All requirements successfully implemented and production-ready! 🎉
