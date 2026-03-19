# Backend Integration Guide

## Overview

Your Flutter frontend is now fully connected to your Node.js backend. The integration includes:

- ✅ JWT token authentication
- ✅ API models and services
- ✅ Token management
- ✅ User persistence
- ✅ Error handling
- ✅ HTTP interceptors for automatic token injection

---

## Architecture

### Core Layers

#### 1. **Constants** (`lib/core/constants/app_constants.dart`)
- API base URL: `http://10.21.87.95:5000/api`
- All endpoint paths
- Token keys for SharedPreferences
- Configuration constants

#### 2. **Network** (`lib/core/network/dio_client.dart`)
- Dio HTTP client with automatic token injection
- Request/response logging
- Error handling interceptors

#### 3. **Utilities** (`lib/core/utils/`)
- `token_service.dart` - Token storage and retrieval
- `user_service.dart` - User data management
- `app_initialization.dart` - App startup initialization

#### 4. **Data Models** (`lib/data/models/api_models.dart`)
- `User` - User profile
- `AuthResponse` - Login/register response with token
- `Salon` - Salon information
- `Booking` - Booking details
- `ApiResponse` - Generic API response wrapper

#### 5. **API Services** (`lib/data/datasources/`)
- `auth_service.dart` - Registration and login
- `user_service.dart` - User profile operations
- `salon_service.dart` - Browse and search salons
- `booking_service.dart` - Create and manage bookings

---

## Usage Examples

### 1. Authentication (Login)

```dart
import 'package:saluun_frontend/data/datasources/auth_service.dart';
import 'package:saluun_frontend/core/network/dio_client.dart';
import 'package:saluun_frontend/core/utils/user_service.dart';

// Create auth service with Dio client
final authService = AuthService(DioClient().dio);

// Login
try {
  final response = await authService.login(
    email: 'user@example.com',
    password: 'password123',
  );
  
  if (response.user != null) {
    // Save user locally
    await userService.saveUser(response.user!);
    // Token is automatically saved by authService
    print('Login successful: ${response.user!.name}');
  }
} catch (e) {
  print('Login failed: $e');
}
```

### 2. Get List of Salons

```dart
import 'package:saluun_frontend/data/datasources/salon_service.dart';
import 'package:saluun_frontend/core/network/dio_client.dart';

final salonService = SalonService(DioClient().dio);

try {
  final salons = await salonService.getAllSalons();
  for (var salon in salons) {
    print('${salon.name} - ${salon.location}');
  }
} catch (e) {
  print('Error fetching salons: $e');
}
```

### 3. Search Salons

```dart
final salons = await salonService.searchSalons(
  search: 'hair',
  location: 'Downtown',
  minRating: 4.0,
  maxPrice: 100.0,
);
```

### 4. Create Booking

```dart
import 'package:saluun_frontend/data/datasources/booking_service.dart';

final bookingService = BookingService(DioClient().dio);

try {
  final booking = await bookingService.createBooking(
    salonId: '123',
    serviceId: '456',
    bookingDate: '2026-03-20',
    bookingTime: '14:00',
  );
  print('Booking created: ${booking.id}');
} catch (e) {
  print('Booking failed: $e');
}
```

### 5. Get User Profile

```dart
import 'package:saluun_frontend/data/datasources/user_service.dart';

final userService = UserAPIService(DioClient().dio);

try {
  final user = await userService.getProfile();
  print('User: ${user.name} (${user.email})');
} catch (e) {
  print('Error: $e');
}
```

---

## Token Management

### Automatic Token Injection

Tokens are automatically added to every request via the `_TokenInterceptor`:

```dart
// No need to manually add Authorization header!
// The interceptor handles it automatically
final response = await dio.get('/user/profile');
```

### Manual Token Access

```dart
import 'package:saluun_frontend/core/utils/token_service.dart';

// Get current token
final token = tokenService.getAccessToken();

// Check if user is logged in
if (tokenService.isLoggedIn()) {
  print('User is logged in');
}

// Logout
await tokenService.clearTokens();
```

### User Persistence

```dart
import 'package:saluun_frontend/core/utils/user_service.dart';

// Get current user
final user = userService.getCurrentUser();

// Check if user is logged in
if (userService.isLoggedIn()) {
  print('Welcome back ${user?.name}');
}
```

---

## API Response Format

All API endpoints follow this response structure:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

The models automatically parse this structure:

```dart
final response = await authService.login(...);
// response.token - JWT token
// response.user - User object
// response.message - Response message
```

---

## Environment Configuration

### Development

API Base URL: `http://10.21.87.95:5000/api`

Update in `lib/core/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = 'http://10.21.87.95:5000/api';
```

### Production

Change to your production backend URL:
```dart
static const String apiBaseUrl = 'https://api.saluun.com';
```

---

## Error Handling

All API services throw `DioException` on failure:

```dart
try {
  final salons = await salonService.getAllSalons();
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    // Handle timeout
  } else if (e.response?.statusCode == 401) {
    // Handle unauthorized
  } else {
    // Handle other errors
  }
}
```

---

## Backend Endpoints Reference

### Authentication
- **POST** `/auth/register` - Register new user
- **POST** `/auth/login` - Login user

### User
- **GET** `/user/profile` - Get user profile (requires auth)

### Salons
- **GET** `/salons` - Get all salons
- **GET** `/salons/:id` - Get single salon
- **GET** `/salons/search` - Search salons
- **GET** `/salons/:id/slots` - Get available time slots
- **POST** `/salons` - Create salon (requires auth)
- **PUT** `/salons/:id` - Update salon (requires auth)

### Bookings
- **GET** `/bookings` - Get user bookings (requires auth)
- **POST** `/bookings` - Create booking (requires auth)
- **DELETE** `/bookings/:id` - Cancel booking (requires auth)

### Services
- **GET** `/services` - Get all services
- **GET** `/services/:salonId` - Get salon services

### Ratings
- **GET** `/ratings/:salonId` - Get salon ratings
- **POST** `/ratings` - Create rating (requires auth)

---

## Files Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # API configuration
│   ├── network/
│   │   └── dio_client.dart         # HTTP client with interceptors
│   └── utils/
│       ├── token_service.dart       # Token management
│       ├── user_service.dart        # User data management
│       └── app_initialization.dart  # App startup
│
├── data/
│   ├── models/
│   │   └── api_models.dart         # Data models
│   └── datasources/
│       ├── auth_service.dart       # Authentication API
│       ├── user_service.dart       # User API
│       ├── salon_service.dart      # Salon API
│       └── booking_service.dart    # Booking API
│
└── presentation/
    └── screens/
        ├── auth/
        │   └── login_screen.dart   # Example login screen
        └── salons/
            └── salon_list_screen.dart  # Example salon list
```

---

## Testing Integration

### 1. Start Backend Server
```bash
cd D:\Development\saluun\saluun_backend
npm install
npm start
# Server runs at http://10.21.87.95:5000
```

### 2. Update App Constants if Needed
```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl = 'http://10.21.87.95:5000/api';
// or for localhost:
// static const String apiBaseUrl = 'http://localhost:5000/api';
```

### 3. Run Flutter App
```bash
cd D:\Development\saluun\saluun_frontend
flutter pub get
flutter run
```

### 4. Test with Example Screens

#### Test Login
1. Navigate to LoginScreen
2. Enter test credentials:
   - Email: `test@example.com`
   - Password: `password123`
3. Check console logs for API calls

#### Test Salon List
1. Navigate to SalonListScreen
2. View list of all salons from backend
3. Check API logs in console

---

## Next Steps

1. **Add navigation** between screens using Go Router
2. **Implement state management** (Riverpod providers for API calls)
3. **Add more screens** (Register, Salon Details, Booking Details, etc.)
4. **Implement caching** for salon and service lists
5. **Add pagination** for large lists
6. **Error recovery** (retry mechanisms, offline support)
7. **Add logging** (Firebase Analytics, Crashlytics)

---

## Troubleshooting

### Connection Refused
- Ensure backend server is running: `npm start`
- Check API base URL in constants matches backend
- For localhost, update: `http://localhost:5000/api`

### 401 Unauthorized
- Token may have expired
- Clear SharedPreferences: `userService.clearUser()` and `tokenService.clearTokens()`
- Re-login to get new token

### CORS Issues
- Ensure backend has CORS middleware enabled
- Check backend `server.js` for CORS configuration

### Print Statements in Production
- Remove `print()` statements for production builds
- Use proper logging library (Firebase Crashlytics, Sentry)

---

## Security Notes

- ✅ JWT tokens stored in SharedPreferences (suitable for mobile)
- ✅ Tokens auto-injected in all API requests
- ✅ Error logging doesn't expose sensitive data
- 🔄 Consider token refresh mechanism for long sessions
- 🔄 Consider using Secure Storage for tokens in production

---

Complete! Your Flutter frontend is now connected to your backend and ready for feature development. 🚀
