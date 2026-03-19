# Flutter Authentication System - Complete Guide

## Overview

This authentication system follows **Clean Architecture** principles with proper separation of concerns:

```
Presentation Layer (UI)
        ↓
State Management (Riverpod)
        ↓
Domain Layer (Repositories)
        ↓
Data Layer (API Services)
        ↓
Infrastructure (Token Storage, DioClient)
```

## Architecture Layers

### 1. **Infrastructure Layer** (`lib/core/`)

#### TokenService (`core/utils/token_service.dart`)
Handles secure token storage using `flutter_secure_storage`:

```dart
// Save token after login
await tokenService.saveAccessToken(token);

// Retrieve token for API calls
final token = await tokenService.getAccessToken();

// Clear tokens on logout
await tokenService.clearTokens();

// Check if user is logged in
final isLoggedIn = await tokenService.isLoggedIn();
```

**Key Methods:**
- `saveAccessToken(String token)` - Save JWT token securely
- `getAccessToken()` - Retrieve JWT token
- `saveRefreshToken(String token)` - Save refresh token (optional)
- `getRefreshToken()` - Retrieve refresh token
- `clearTokens()` - Delete all tokens
- `isLoggedIn()` - Check authentication status
- `addTokenToHeaders(RequestOptions)` - Attach token to HTTP requests

#### DioClient (`core/network/dio_client.dart`)
HTTP client with intelligent interceptor system:

```dart
// Automatically handles:
// ✅ Token attachment to all requests
// ✅ 401 Unauthorized responses (session expiration)
// ✅ Error handling and mapping
// ✅ Debug logging in development

final dioClient = DioClient();
final response = await dioClient.get('/user/profile');
```

**Interceptors:**
1. **_AuthTokenInterceptor** - Attaches JWT to requests
2. **_ErrorHandlingInterceptor** - Handles 401, errors, timeouts
3. **LogInterceptor** (debug only) - Logs all requests/responses

#### AuthManager (`core/auth/auth_manager.dart`)
Centralized auth state and operations:

```dart
final authManager = AuthManager(
  authRepository: authRepository,
  tokenService: tokenService,
  userService: userService,
);

// Initialize on app start
await authManager.initialize();

// Check if authenticated
if (authManager.isAuthenticated) {
  // User is logged in
}

// Perform operations
await authManager.login(email, password);
await authManager.register(email, password, name);
await authManager.logout();
```

### 2. **Data Layer** (`lib/data/`)

#### AuthService (`datasources/auth_service.dart`)
API communication layer:

```dart
// Communicates with backend
final response = await authService.login(email, password);
final authResponse = AuthResponse.fromJson(response.data);
```

#### AuthRepositoryImpl (`repositories/auth_repository_impl.dart`)
Data layer implementation:

```dart
class AuthRepositoryImpl implements AuthRepository {
  Future<UserEntity> login(String email, String password) async {
    // 1. Call API
    final response = await authService.login(email, password);
    
    // 2. Save token
    await tokenService.saveAccessToken(response.token);
    
    // 3. Save user info
    await userService.saveUser(response.user);
    
    // 4. Return domain entity
    return _mapUserToEntity(response.user);
  }
}
```

### 3. **Domain Layer** (`lib/domain/`)

#### AuthRepository (Abstract Interface)
```dart
abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<void> clearToken();
}
```

#### UseCases
```dart
// LoginUseCase - orchestrates login flow
final user = await loginUseCase(email: email, password: password);

// LogoutUseCase - orchestrates logout flow
await logoutUseCase();

// GetCurrentUserUseCase - retrieves cached user
final user = await getCurrentUserUseCase();
```

### 4. **Presentation Layer** (`lib/presentation/`)

#### AuthViewModel (`viewmodels/auth/auth_view_model.dart`)
Manages UI state using StateNotifier:

```dart
class AuthViewModel extends StateNotifier<AuthUiState> {
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _loginUseCase(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(e),
      );
    }
  }
}
```

#### Providers (`providers/`)

**AuthViewModelProvider:**
```dart
final authViewModelProvider = 
  StateNotifierProvider<AuthViewModel, AuthUiState>((ref) {
    return AuthViewModel(
      repository: ref.watch(authRepositoryProvider),
      loginUseCase: ref.watch(loginUseCaseProvider),
      ...
    );
  });
```

**AuthManagerProvider:**
```dart
final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager(
    authRepository: ref.watch(authRepositoryProvider),
    tokenService: tokenService,
    userService: userService,
  );
});

// Watch authentication state
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authManagerProvider).isUserAuthenticated();
});
```

## Authentication Flow

### 1. **App Startup**

```
AppStartupSequence:
    ↓
Configure Dio with Token Interceptor
    ↓
Initialize AuthManager
    ↓
Check for existing token
    ↓
    ├─→ Token exists → Navigate to HomeScreen
    └─→ No token → Navigate to LoginScreen
```

**Implementation:**
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch initialization state
    final isInitializing = ref.watch(isInitializingAuthProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isInitializing) {
      return const SplashScreen();
    }

    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: isAuthenticated ? '/home' : '/login',
        routes: [...],
      ),
    );
  }
}
```

### 2. **Login Flow**

```
User enters credentials
    ↓
Press "Login" button
    ↓
AuthViewModel.login(email, password)
    ↓
Show loading spinner
    ↓
DioClient.post('/auth/login', data: {...})
    ↓
    ├─→ Success:
    │     ├─ Save token (TokenService)
    │     ├─ Save user info (UserService)
    │     ├─ Update AuthViewModel state
    │     └─ Navigate to HomeScreen
    │
    └─→ Error:
          ├─ Show error message
          ├─ Clear loading state
          └─ Highlight error field
```

**Code Example:**
```dart
class LoginScreen extends ConsumerWidget {
  void _handleLogin(WidgetRef ref) async {
    await ref.read(authViewModelProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );

    final authState = ref.read(authViewModelProvider);
    if (authState.user != null) {
      // Login successful
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Column(
        children: [
          if (authState.errorMessage != null)
            ErrorBanner(message: authState.errorMessage!),
          
          CustomButton(
            label: 'Login',
            onPressed: _handleLogin,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }
}
```

### 3. **API Request with Token**

```
App makes API request
    ↓
_AuthTokenInterceptor.onRequest()
    ↓
TokenService.getAccessToken()
    ↓
Add to headers: Authorization: Bearer <token>
    ↓
Send request to API
    ↓
    ├─→ 200 OK → Return response
    ├─→ 401 Unauthorized → Handle session expiration
    ├─→ 5xx Error → Log and throw
    └─→ Network error → Handle timeout
```

### 4. **Session Expiration (401)**

```
API returns 401 Unauthorized
    ↓
_ErrorHandlingInterceptor.onError()
    ↓
Call: DioClient._onSessionExpired()
    ↓
AuthManager.handleSessionExpired()
    ↓
├─ Clear JWT token from storage
├─ Clear user data
├─ Reset auth state
└─ Invalidate AuthViewModel
    ↓
Navigation: Redirect to LoginScreen
    ↓
Show toast: "Your session has expired. Please login again."
```

**Implementation:**
```dart
// In AuthManager initialization
DioClient.setSessionExpiredCallback(() {
  authManager.handleSessionExpired().then((_) {
    // Reset auth state in Riverpod
    ref.invalidate(authViewModelProvider);
    // Navigation happens via router redirect
  });
});
```

### 5. **Logout Flow**

```
User taps "Logout"
    ↓
Show confirmation dialog
    ↓
User confirms
    ↓
AuthViewModel.logout()
    ↓
├─ Clear token from storage
├─ Clear user data
├─ Reset state
└─ Call API /auth/logout (optional)
    ↓
Navigate to LoginScreen
    ↓
Show toast: "Logged out successfully"
```

**Code Example:**
```dart
class ProfileScreen extends ConsumerWidget {
  void _handleLogout(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authViewModelProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      label: 'Logout',
      onPressed: () => _handleLogout(ref),
    );
  }
}
```

## Token Management

### Token Structure
```dart
// JWT token contains:
header.payload.signature

// Payload example:
{
  "sub": "user_id",
  "email": "user@example.com",
  "iat": 1640000000,
  "exp": 1640086400,  // Expiration timestamp
  "aud": "app_id"
}
```

### Storage Details

**Token Service uses flutter_secure_storage:**
```dart
// Platform-specific secure storage:
// iOS: Keychain
// Android: Keystore + Encrypted SharedPreferences
// Windows/Linux/macOS: Encrypted local storage

const accessTokenKey = 'access_token';
const refreshTokenKey = 'refresh_token';
```

### Refresh Token Strategy (Optional)

If backend supports refresh tokens:

```dart
// In AuthManager
Future<void> _refreshToken() async {
  final refreshToken = await _tokenService.getRefreshToken();
  
  final newAccessToken = await _authRepository.refreshToken(
    refreshToken: refreshToken,
  );
  
  await _tokenService.saveAccessToken(newAccessToken);
}
```

## Protected Routes

```dart
// In app_routes.dart
GoRoute(
  path: '/home',
  name: 'home',
  builder: (context, state) => const HomeScreen(),
  // Redirect if not authenticated
  redirect: (context, state) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (!isLoggedIn) {
      return '/login';
    }
    return null;
  },
)
```

## Error Handling

### Error Types

```dart
AuthException
  ├─ InvalidCredentials (401)
  ├─ UserNotFound (404)
  ├─ ServerError (5xx)
  ├─ NetworkError (timeout, no connection)
  └─ UnknownError
```

### Mapping Errors

```dart
String _mapError(Object error) {
  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 401:
        return 'Invalid email or password';
      case 404:
        return 'User not found';
      case 500:
        return 'Server error. Please try again later';
      case null:
        return 'Network error. Check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
  return 'Unknown error';
}
```

## Security Best Practices

✅ **Do:**
- Store JWT in platform-specific secure storage (not SharedPreferences)
- Clear token on logout
- Handle 401 responses immediately
- Validate tokens before using
- Use HTTPS for all API calls
- Set reasonable expiration times
- Implement refresh token rotation

❌ **Don't:**
- Store JWT in SharedPreferences
- Log tokens in debug output
- Send tokens as URL parameters
- Hardcode tokens in code
- Ignore 401 responses
- Store sensitive data in JWT claims

## Configuration

### Update API Base URL
```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl = 'https://api.saluun.com/api';
```

### Token Keys
```dart
static const String accessTokenKey = 'access_token';
static const String refreshTokenKey = 'refresh_token';
static const String jwtAuthHeader = 'Authorization';
static const String jwtBearerPrefix = 'Bearer ';
```

## Testing

```dart
// Test token storage
test('Token is saved securely', () async {
  await tokenService.saveAccessToken('test_token');
  final token = await tokenService.getAccessToken();
  expect(token, 'test_token');
});

// Test authentication state
test('User is logged in after successful login', () async {
  await authManager.login('user@example.com', 'password123');
  expect(authManager.isAuthenticated, true);
});

// Test session expiration
test('User is logged out on 401', () async {
  await authManager.handleSessionExpired();
  expect(authManager.isAuthenticated, false);
});
```

## Troubleshooting

### "Session expired" error appears after login
- Check token expiration time
- Ensure backend is returning valid JWT
- Verify token is being saved correctly

### Token not being attached to requests
- Check TokenService.addTokenToHeaders()
- Verify interceptor is registered in DioClient
- Ensure token exists in secure storage

### 401 error but token exists locally
- Token may be expired on backend
- Implement refresh token logic
- Force logout and re-login

### Clear cache/token for testing
```dart
// Manually clear all auth data
await tokenService.clearTokens();
await userService.clearUser();
await authManager.logout();
```

## Summary

```
┌─────────────────────────────────────────┐
│         Flutter App Startup              │
└──────────────┬──────────────────────────┘
               │
               ├─→ Initialize DioClient
               │
               ├─→ Initialize AuthManager
               │
               └─→ Check token exists
                   ├─→ Yes → Navigate to /home
                   └─→ No → Navigate to /login
                   
┌─────────────────────────────────────────┐
│      User Makes API Request              │
└──────────────┬──────────────────────────┘
               │
               ├─→ _AuthTokenInterceptor adds JWT
               │
               ├─→ Send to backend
               │
               ├─→ Receive response
               │
               └─→ _ErrorHandlingInterceptor
                   ├─→ 200 OK → Continue
                   ├─→ 401 → handleSessionExpired()
                   └─→ Error → Throw exception
```

## File Structure

```
lib/
├── core/
│   ├── auth/
│   │   └── auth_manager.dart
│   ├── network/
│   │   └── dio_client.dart (enhanced)
│   ├── utils/
│   │   ├── token_service.dart
│   │   └── user_service.dart
│   └── constants/
│       └── app_constants.dart
├── data/
│   ├── datasources/
│   │   └── auth_service.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── auth/
├── presentation/
│   ├── providers/
│   │   ├── auth_manager_provider.dart
│   │   ├── auth_view_model_provider.dart
│   │   └── core_providers.dart
│   ├── viewmodels/
│   │   └── auth/
│   │       ├── auth_view_model.dart
│   │       └── auth_ui_state.dart
│   └── screens/
│       └── auth/
│           ├── login_screen.dart
│           └── register_screen.dart
└── routes/
    └── app_routes.dart
```

---

This architecture provides:
✅ Clean separation of concerns
✅ Secure token handling
✅ Proper state management
✅ Automatic session persistence
✅ Graceful error handling
✅ Scalable and maintainable code
