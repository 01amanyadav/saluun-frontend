# Production-Grade Authentication Implementation Guide

## 📋 Overview

This document provides a comprehensive guide to the authentication feature implemented in the Saluun Flutter frontend app. The implementation follows **Clean Architecture** with **MVVM-style state management** using **Riverpod**.

## ✅ Implementation Complete

All 10 requirement categories have been fully implemented and integrated.

---

## 🏗️ Architecture Overview

### Layer Structure

```
Presentation (UI)
    ↓
State Management (ViewModel via Riverpod)
    ↓
Domain (Business Logic)
    ↓
Data (API Integration)
    ↓
Core (Infrastructure: Networking, Storage, Theme, Utils)
```

### Key Components

1. **UI Layer**: Login & Register screens with Material 3 design
2. **State Management**: AuthViewModel using Riverpod StateNotifier
3. **State Model**: AuthUiState for clean UI state representation
4. **Domain Layer**: Entities, UseCases, Repositories (abstract)
5. **Data Layer**: Repository implementations with API calls
6. **Networking**: Dio with interceptors for authentication
7. **Storage**: flutter_secure_storage for JWT management
8. **Navigation**: go_router integration with auth guards

---

## 📁 File Structure

```
lib/
├── core/
│   ├── network/
│   │   └── dio_client.dart              # Dio configuration with interceptors
│   │
│   ├── utils/
│   │   ├── token_service.dart           # Secure JWT storage (flutter_secure_storage)
│   │   ├── user_service.dart            # User data persistence
│   │   └── app_initialization.dart      # App startup initialization
│   │
│   ├── theme/
│   │   ├── app_design_system.dart       # Material 3 design tokens
│   │   └── app_theme.dart               # Light/dark themes
│   │
│   ├── constants/
│   │   └── app_constants.dart           # API endpoints, storage keys
│   │
│   └── exceptions/
│       └── app_exceptions.dart          # Custom exception hierarchy
│
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart             # User domain model
│   │   ├── salon_entity.dart            # Salon domain model
│   │   └── booking_entity.dart          # Booking domain model
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart         # Abstract auth interface
│   │   ├── salon_repository.dart        # Abstract salon interface
│   │   └── booking_repository.dart      # Abstract booking interface
│   │
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── get_current_user_usecase.dart
│       │
│       ├── salon/
│       │   ├── get_salons_usecase.dart
│       │   └── search_salons_usecase.dart
│       │
│       └── booking/
│           ├── get_bookings_usecase.dart
│           └── create_booking_usecase.dart
│
├── data/
│   ├── models/
│   │   └── api_models.dart              # DTO/API response models
│   │
│   ├── datasources/
│   │   ├── auth_service.dart            # Auth API service
│   │   ├── salon_service.dart           # Salon API service
│   │   ├── booking_service.dart         # Booking API service
│   │   └── user_service.dart            # User API service
│   │
│   └── repositories/
│       ├── auth_repository_impl.dart    # Auth repository implementation
│       ├── salon_repository_impl.dart   # Salon repository implementation
│       └── booking_repository_impl.dart # Booking repository implementation
│
└── presentation/
    ├── providers/
    │   ├── core_providers.dart          # Service DI providers
    │   ├── auth_viewmodel.dart          # AuthViewModel (NEW - replaced auth_provider)
    │   ├── salon_provider.dart          # Salon providers
    │   └── booking_provider.dart        # Booking providers
    │
    ├── models/
    │   └── auth_ui_state.dart           # UI state model (NEW)
    │
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart        # Login UI (UPGRADED)
    │   │   └── register_screen.dart     # Register UI (UPGRADED)
    │   │
    │   ├── home/
    │   │   └── home_screen.dart         # Dashboard screen
    │   │
    │   └── salons/
    │       └── salon_list_screen.dart   # Salon listing
    │
    ├── widgets/
    │   └── common_widgets.dart          # Reusable UI components
    │
    └── utils/
        └── form_validators.dart        # Form validation logic
```

---

## 🔐 Authentication Flow

### Login Flow

```
1. User enters email & password → Validation
2. Click "Sign In" button
3. AuthViewModel.login() called
4. LoginUseCase executes business logic
5. AuthRepository.login() makes API call via Dio
6. Token saved to secure storage (flutter_secure_storage)
7. User data cached locally
8. AuthUiState updates with user data
9. Navigation listener detects authentication
10. Redirect to /home screen
```

### Registration Flow

```
1. User enters name, email, password (+ confirmation)
2. Validation checks email format, password strength
3. Click "Create Account"
4. AuthViewModel.register() called
5. RegisterUseCase executes validation
6. AuthRepository.register() makes API call
7. Token saved securely
8. User data persisted
9. AuthUiState updates
10. Navigate to /home
```

### Session Restoration

```
On app startup:
1. AppInitializationService.initialize() runs
2. TokenService loads token from secure storage
3. UserService restores cached user data
4. AuthViewModel.restoreSession() checks for existing session
5. If valid token exists: load user data → AuthUiState.success()
6. If no token: AuthUiState.initial()
7. Navigation redirects based on auth state
```

### Logout Flow

```
1. User clicks logout
2. AuthViewModel.logout() called
3. AuthRepository.clearToken() executes
4. Token deleted from secure storage
5. User data cleared from cache
6. AuthUiState reset to initial
7. Navigation redirects to /login
```

---

## 🔑 Key Components Deep Dive

### 1. AuthUiState Model

**Location**: `lib/presentation/models/auth_ui_state.dart`

```dart
class AuthUiState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  
  // Factory constructors for common states
  factory AuthUiState.loading()
  factory AuthUiState.success(UserEntity user)
  factory AuthUiState.error(String message)
  factory AuthUiState.initial()
  
  // Computed property
  bool get isAuthenticated => user != null;
}
```

**Purpose**: 
- Clean separation between domain data (UserEntity) and UI state (loading, error)
- Immutable design for predictable state changes
- Factory constructors simplify state creation

---

### 2. AuthViewModel (MVVM ViewModel)

**Location**: `lib/presentation/providers/auth_viewmodel.dart`

```dart
class AuthViewModel extends StateNotifier<AuthUiState> {
  // Methods
  Future<void> login(String email, String password)
  Future<void> register(String email, String password, String displayName)
  Future<void> logout()
  Future<void> restoreSession()
  
  // Private helpers
  String _parseErrorMessage(dynamic error)
}
```

**Responsibilities**:
- Manage authentication state lifecycle
- Coordinate between domain layer (usecases) and UI
- Transform errors into user-friendly messages
- Handle session restoration on app launch

**Error Handling Strategy**:
```dart
try {
  final user = await loginUseCase.call(email: email, password: password);
  state = AuthUiState.success(user);
} catch (e) {
  state = AuthUiState.error(_parseErrorMessage(e));
}
```

---

### 3. Token Service (Secure Storage)

**Location**: `lib/core/utils/token_service.dart`

**Key Features**:
- Uses `flutter_secure_storage` (platform-native encrypted storage)
- NOT SharedPreferences (plaintext storage - insecure for JWTs)
- Async API for all operations
- Singleton pattern for app-wide access

```dart
class TokenService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveAccessToken(String token)
  Future<String?> getAccessToken()
  Future<bool> isLoggedIn()
  Future<void> clearTokens()
  Future<void> addTokenToHeaders(RequestOptions options)
}
```

**Security Benefits**:
- ✅ Encrypted at rest (iOS Keychain, Android Keystore)
- ✅ No plaintext storage
- ✅ Platform-native protection
- ✅ Automatic cleanup on app uninstall

---

### 4. Dio Client with Interceptors

**Location**: `lib/core/network/dio_client.dart`

**Interceptor Chain**:
```
1. _AuthTokenInterceptor (adds JWT to headers)
   ↓
2. LogInterceptor (debug logging only)
   ↓
3. HTTP Request/Response
```

**Auth Interceptor**:
```dart
class _AuthTokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await _tokenService.addTokenToHeaders(options);
    handler.next(options);
  }
}
```

**Features**:
- Automatic token injection on every request
- Async token retrieval from secure storage
- Proper error propagation
- Debug logging in development mode

---

### 5. UI State Patterns

### Login Screen

**Location**: `lib/presentation/screens/auth/login_screen.dart`

```dart
class LoginScreen extends ConsumerStatefulWidget {
  // Local state
  TextEditingController _emailController;
  TextEditingController _passwordController;
  GlobalKey<FormState> _formKey;
  
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).login(email, password);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    
    // Listen for successful login
    ref.listen(authViewModelProvider, (previous, authState) {
      if (authState.isAuthenticated && mounted) {
        context.go('/home');
      }
    });
    
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field with validation
            CustomTextField(
              label: 'Email',
              validator: FormValidators.validateEmail,
              enabled: !authState.isLoading,
            ),
            
            // Password field with visibility toggle
            CustomTextField(
              label: 'Password',
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? ... : ...),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            
            // Error message display
            if (authState.errorMessage != null)
              ErrorContainer(message: authState.errorMessage),
            
            // Submit button with loading state
            PrimaryButton(
              label: authState.isLoading ? 'Signing in...' : 'Sign In',
              onPressed: authState.isLoading ? null : _handleLogin,
              isLoading: authState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Register Screen

**Location**: `lib/presentation/screens/auth/register_screen.dart`

**Additional Features**:
- Real-time password strength indicator
- Password confirmation validation
- Display name input field
- Visual password strength feedback (Weak/Fair/Good/Strong)

```dart
LinearProgressIndicator(
  value: _passwordStrength,
  valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
)
```

---

## 📱 Form Validation System

**Location**: `lib/presentation/utils/form_validators.dart`

```dart
class FormValidators {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) 
      return 'Invalid email format';
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
  
  static String? validateConfirmPassword(String password, String? confirm) {
    if (confirm?.isEmpty ?? true) return 'Please confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }
  
  static String? validateDisplayName(String? value) {
    if (value?.isEmpty ?? true) return 'Name is required';
    if (value!.length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}

class PasswordStrength {
  static double calculateStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) strength += 0.125;
    return strength.clamp(0, 1);
  }
}
```

---

## 🌐 Navigation with Auth Guards

**Location**: `lib/routes/app_routes.dart`

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        redirect: (context, state) {
          if (!authState.isAuthenticated) return '/login';
          return null;
        },
      ),
      // ... other routes
    ],
  );
});
```

**Key Features**:
- Automatic redirect based on authentication status
- Initial location determined by auth state
- Protected routes prevent unauthenticated access
- Smooth navigation transitions

---

## 🔄 Data Flow Example: Complete Login

### Sequence Diagram

```
User                  UI              ViewModel           Domain           Data
  |                    |                  |                 |               |
  |--Enter Email------>|                  |                 |               |
  |--Enter Password--->|                  |                 |               |
  |--Click Login------>|                  |                 |               |
  |                    |--validate------->|                 |               |
  |                    |<--valid---------|                 |               |
  |                    |--login()-------->|                 |               |
  |                    |                  |--LoginUseCase()-->|             |
  |                    |                  |                 |--call()------>|
  |                    |                  |                 |               |--POST /login
  |                    |                  |                 |               |
  |                    |                  |                 |               |<--200 + JWT
  |                    |                  |                 |<--UserEntity--|
  |                    |                  |<--UserEntity----|               |
  |                    |                  |                 |               |
  |                    |                  |--Save JWT------->|               |
  |                    |                  |                 |--flutter_secure_storage
  |                    |                  |                 |               |
  |                    |<--AuthUiState.success(user)-|               |
  |<--Logged in + Navigate to /home-------|               |
```

---

## 🛡️ Error Handling Strategy

### Layer-Specific Error Management

**Presentation Layer** (UI):
```dart
if (authState.errorMessage != null) {
  ErrorContainer(
    icon: Icons.error_outline,
    message: authState.errorMessage!,
    backgroundColor: AppColors.error.withValues(alpha: 0.1),
  );
}
```

**State Management Layer** (ViewModel):
```dart
String _parseErrorMessage(dynamic error) {
  if (error.contains('invalid email')) return 'Invalid email address';
  if (error.contains('password')) return 'Password must be at least 8 characters';
  if (error.contains('already exists')) return 'Email already registered';
  if (error.contains('Unauthorized')) return 'Invalid email or password';
  if (error.contains('timeout')) return 'Connection timeout. Please try again.';
  if (error.contains('Network')) return 'Network error. Please try again.';
  return 'An error occurred. Please try again.';
}
```

**Data Layer** (API Service):
```dart
try {
  final response = await _dio.post(AppConstants.authLogin, data: {...});
  if (response.statusCode == 200) {
    return AuthResponse.fromJson(response.data);
  }
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw NetworkException('Request timeout');
  }
  if (e.response?.statusCode == 401) {
    throw AuthException('Invalid credentials');
  }
}
```

---

## 📦 Dependencies

All required packages are in `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1
  
  # Networking
  dio: ^5.4.0
  
  # Navigation
  go_router: ^14.0.0
  
  # Secure Storage
  flutter_secure_storage: ^9.2.2
  
  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  
  # UI
  flutter:
    sdk: flutter
```

---

## 🖥️ Running the App

### Prerequisites

```bash
# Install Flutter
flutter --version  # should be 3.11.0+

# Install dependencies
flutter pub get

# Generate code (if needed)
flutter pub run build_runner build
```

### Running

```bash
# Development
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

### Testing Authentication

**Test Credentials** (assuming backend is running):
```
Email: test@example.com
Password: Password123!
```

**Test Flows**:
1. ✅ Login → Navigate to home
2. ✅ Logout → Navigate to login
3. ✅ Session restore → Check token persistence
4. ✅ Invalid credentials → Error message display
5. ✅ Network timeout → Graceful error handling
6. ✅ Form validation → Real-time feedback

---

## ✨ Production Checklist

- [x] Clean Architecture pattern implemented
- [x] MVVM-style ViewModel with Riverpod
- [x] Secure token storage (flutter_secure_storage)
- [x] Proper error handling and user feedback
- [x] Form validation with real-time feedback
- [x] Loading states and UI feedback
- [x] Material 3 design system
- [x] Navigation guards
- [x] Session restoration
- [x] Complete separation of concerns
- [x] No business logic in UI
- [x] Comprehensive error messages
- [x] Password strength indicator
- [x] Interceptor-based token injection
- [x] Async token operations

---

## 🚀 Future Enhancements

1. **Forgot Password**: Recovery flow via email
2. **Two-Factor Authentication**: Enhanced security
3. **Biometric Authentication**: Face/Touch ID login
4. **Social Login**: Google/Apple authentication
5. **Session Management**: Token refresh using refresh tokens
6. **Offline Support**: Local auth with sync queue
7. **Analytics**: Track login/registration events
8. **Rate Limiting**: Prevent brute force attacks

---

## 📞 Support

For issues or questions about the authentication implementation:
1. Check the existing PRODUCTION_GUIDE.md
2. Review this document's relevant section
3. Check flutter logs: `flutter logs`
4. Run: `flutter doctor` to verify setup

---

## 📄 Document Info

- **Created**: March 2026
- **Last Updated**: March 18, 2026
- **Status**: Production Ready ✅
- **Author**: AI Development Assistant

