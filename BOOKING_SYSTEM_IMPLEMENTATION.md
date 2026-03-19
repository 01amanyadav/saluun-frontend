# Booking System Implementation Guide

## Overview
A complete booking system has been implemented following MVVM architecture with Riverpod state management. The system allows users to:
- Select a service from a salon's service list
- Pick a date using Material DatePicker
- Select a time slot from predefined options
- Create bookings with proper validation and error handling
- See real-time loading states and feedback

## Architecture Layers

### 1. Data Layer (`lib/data/`)
**BookingService** (`datasources/booking_service.dart`)
- Handles API calls using Dio
- Methods:
  - `createBooking()` - Create new booking via POST
  - `getUserBookings()` - Fetch user's bookings
  - `cancelBooking()` - Cancel existing booking

**BookingRepositoryImpl** (`repositories/booking_repository_impl.dart`)
- Implements `BookingRepository` interface (domain layer)
- Maps API models to domain entities
- Handles service exceptions

### 2. Domain Layer (`lib/domain/`)
**BookingRepository** (Abstract interface)
- Defines contracts for booking operations
- Used by ViewModel for dependency injection

### 3. Presentation Layer (`lib/presentation/`)

#### State Management
**BookingUiState** (`viewmodels/booking/booking_ui_state.dart`)
```dart
class BookingUiState {
  final bool isLoading;        // API call in progress
  final Booking? booking;      // Successful booking data
  final String? errorMessage;  // Error details
  final bool isSuccess;        // Success flag for UI feedback
}
```

States:
- `initial()` - Initial idle state
- `loading()` - API call in progress
- `success(booking)` - Booking created successfully
- `error(message)` - Error occurred

**BookingViewModelNotifier** (`viewmodels/booking/booking_view_model.dart`)
- Extends `StateNotifier<BookingUiState>`
- Manages booking creation logic
- Methods:
  - `createBooking()` - Creates booking and updates state
  - `reset()` - Resets to initial state
  - `clearError()` - Clears error message

#### Providers
**BookingProvider** (`providers/booking_provider.dart`)
```dart
final bookingViewModelProvider = 
  StateNotifierProvider<BookingViewModelNotifier, BookingUiState>((ref) {
    final repository = ref.watch(bookingRepositoryProvider);
    return BookingViewModelNotifier(repository);
  });
```

#### UI Components

**CustomButton** (`widgets/custom_button.dart`)
- Reusable button with loading state
- Features:
  - Animated loading spinner during API calls
  - Disabled state management
  - Material 3 styling with FilledButton
  - Customizable colors, size, and border radius

```dart
CustomButton(
  label: 'Confirm Booking',
  onPressed: _handleBooking,
  isLoading: bookingState.isLoading,
  isEnabled: !bookingState.isLoading,
)
```

**BookingSlotPicker** (`widgets/booking_slot_picker.dart`)
- Horizontal scrollable time slot selector
- Features:
  - Horizontal ListView with predefined time slots
  - Visual feedback for selected slot (color + border)
  - Callback on slot selection
  - Responsive design

```dart
BookingSlotPicker(
  timeSlots: _timeSlots,
  selectedSlot: _selectedTimeSlot,
  onSlotSelected: (slot) {
    setState(() { _selectedTimeSlot = slot; });
  },
)
```

**BookingScreen** (`screens/booking/booking_screen.dart`)
- Complete booking form with validation
- Features:
  - Service selection with pricing and duration
  - Date picker (30 days ahead)
  - Time slot picker (10 predefined slots)
  - Booking summary card
  - Form validation (all fields required)
  - Success/error snackbars
  - Loading state handling
  - Material 3 design

## Usage

### 1. Navigation to Booking Screen

#### From SalonDetailsScreen:
```dart
context.pushNamed(
  'booking',
  pathParameters: {
    'salonId': salon.id,
  },
  queryParameters: {
    'serviceId': service.id, // Optional
  },
)
```

Or using the router directly:
```dart
context.go('/booking/${salonId}?serviceId=${serviceId}');
```

#### Using GoRouter (from app_routes.dart):
```dart
GoRoute(
  path: '/booking/:salonId',
  name: 'booking',
  builder: (context, state) {
    final salonId = state.pathParameters['salonId']!;
    final serviceId = state.uri.queryParameters['serviceId'];
    return BookingScreen(
      salonId: salonId,
      initialServiceId: serviceId,
    );
  },
)
```

### 2. Form Flow
1. User loads BookingScreen with salonId
2. Salon details and services load asynchronously
3. User selects service (visual feedback with card border)
4. User picks date using DatePicker
5. User selects time slot (Card UI changes on selection)
6. Booking summary displays selected details
7. User taps "Confirm Booking"
8. Validation runs (all fields required)
9. API call made with loading state
10. Success: navigate back, snackbar feedback
11. Error: snackbar with error message

### 3. State Management Flow

```
Initial State → User Interaction → Loading State
                                  ↓
                          API Response
                          ↙         ↘
                      Success    Error
                      ↓          ↓
                  Show Booking  Show Error Message
                  Navigate Back Disable Button
```

## Data Models

### Service Model (API)
```dart
class Service {
  final String id;
  final String salonId;
  final String name;
  final String? description;
  final double price;
  final int? durationMinutes;
  final String? category;
  final int? popularity;
}
```

### Booking Model (API)
```dart
class Booking {
  final String id;
  final String userId;
  final String salonId;
  final String serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String status; // pending, confirmed, completed, cancelled
  final double? totalPrice;
}
```

### SalonDetails (Combined)
```dart
class SalonDetails {
  final SalonEntity salon;
  final List<Service> services;
}
```

## API Endpoints

### Create Booking
**Endpoint:** `POST /bookings`

**Request Body:**
```json
{
  "salonId": "string",
  "serviceId": "string",
  "bookingDate": "YYYY-MM-DD",
  "bookingTime": "HH:MM AM/PM"
}
```

**Response:**
```json
{
  "data": {
    "id": "string",
    "userId": "string",
    "salonId": "string",
    "serviceId": "string",
    "bookingDate": "ISO8601",
    "bookingTime": "string",
    "status": "pending",
    "totalPrice": number
  }
}
```

## Customization Guide

### 1. Add More Time Slots
Edit `lib/presentation/screens/booking/booking_screen.dart`:
```dart
final List<String> _timeSlots = [
  '06:00 AM', '07:00 AM', '08:00 AM', // Add more slots
  // ...
];
```

### 2. Fetch Time Slots from API
Replace static `_timeSlots` with:
```dart
final salonTimeSlots = ref.watch(salonTimeSlotsProvider(widget.salonId));
// In build: use salonTimeSlots.when() to handle async loading
```

### 3. Change Date Picker Range
In `_pickDate()` method:
```dart
firstDate: DateTime.now().subtract(Duration(days: 1)), // Allow past dates
lastDate: DateTime.now().add(Duration(days: 60)), // Change range
```

### 4. Customize Button Colors
```dart
CustomButton(
  backgroundColor: Colors.blue[600],
  textColor: Colors.white,
  // ...
)
```

### 5. Add Pre-selection Logic
In `initState()`:
```dart
if (widget.initialServiceId != null) {
  _selectedServiceId = widget.initialServiceId;
}
```

## Error Handling

### Validation Errors
- Required fields: Service, Date, Time
- Validation happens on "Confirm Booking" click
- Clear error messages in snackbars

### API Errors
- Network errors (no internet)
- Server errors (5xx)
- Unauthorized access (401/403)
- All mapped to user-friendly messages

### State Management Errors
- Try-catch in ViewModel
- Error state displays in UI
- Retry logic available (user taps button again)

## Testing Scenarios

### 1. Happy Path
- User selects service → picks date → picks time → books
- Expected: Success snackbar, navigation back

### 2. Missing Fields
- User tries to book without selecting fields
- Expected: Validation snackbar, stay on screen

### 3. Network Error
- Airplane mode during booking
- Expected: Error snackbar, button re-enabled

### 4. Server Error
- API returns 500
- Expected: Error message, button re-enabled

### 5. Concurrent Requests
- User taps button twice
- Expected: Button disabled during first request, only one API call

## Performance Optimizations

1. **Lazy Loading**
   - Services loaded only when salon details requested
   - Using `FutureProvider.family` for caching

2. **Avoided Rebuilds**
   - `StateNotifier` used instead of `StateProvider`
   - Immutable state objects
   - Proper `ref.watch()` scope

3. **Network Efficiency**
   - Single API call per booking
   - No unnecessary refetching
   - Proper error handling without retries

4. **UI Performance**
   - `SingleChildScrollView` for content that may overflow
   - `ListView.builder` for services (potential large lists)
   - Efficient Card rendering with ripple effects

## Future Enhancements

1. **Dynamic Time Slots**
   - Fetch available slots from API
   - Show unavailable slots as disabled
   - Real-time availability updates

2. **Booking History**
   - View past bookings
   - Reschedule option
   - Cancellation with reason

3. **Notifications**
   - Push notification on successful booking
   - Reminder notifications before appointment
   - SMS/Email confirmations

4. **Advanced Filters**
   - Filter services by category
   - Price range selection
   - Duration filter

5. **Payment Integration**
   - Accept payments during booking
   - Multiple payment methods
   - Invoice generation

6. **Rating & Reviews**
   - Post-booking review form
   - Service ratings
   - Customer testimonials

## File Structure

```
lib/
├── data/
│   ├── datasources/
│   │   └── booking_service.dart
│   ├── models/
│   │   └── api_models.dart (includes Booking, Service)
│   └── repositories/
│       └── booking_repository_impl.dart
├── domain/
│   └── repositories/
│       └── booking_repository.dart
└── presentation/
    ├── models/
    │   └── salon_details.dart
    ├── providers/
    │   ├── booking_provider.dart
    │   └── salon_provider.dart
    ├── screens/
    │   └── booking/
    │       └── booking_screen.dart
    ├── viewmodels/
    │   └── booking/
    │       ├── booking_ui_state.dart
    │       └── booking_view_model.dart
    └── widgets/
        ├── booking_slot_picker.dart
        └── custom_button.dart
```

## Summary

The booking system is production-ready with:
- ✅ MVVM architecture with clear separation of concerns
- ✅ Riverpod state management for reactivity
- ✅ Comprehensive validation and error handling
- ✅ Material 3 design principles
- ✅ Loading states with visual feedback
- ✅ Success/error notifications
- ✅ Responsive UI that handles edge cases
- ✅ Reusable custom widgets
- ✅ Well-documented code with clear flow

Ready for integration with your salon booking backend!
