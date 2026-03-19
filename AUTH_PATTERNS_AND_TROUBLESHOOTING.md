/// Saluun Flutter Authentication - Patterns & Troubleshooting
/// 
/// Common patterns for using the authentication system and solutions for
/// typical issues.

// ============================================================================
// COMMON PATTERNS
// ============================================================================

// PATTERN 1: Check Auth Before Showing Screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/presentation/providers/auth_manager_provider.dart';

class ProtectedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (!isAuth) {
      // Redirect to login (shouldn't happen due to router guard, but safe fallback)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser?.name}'),
      ),
      body: const Center(child: Text('Protected content')),
    );
  }
}

// PATTERN 2: Show Loading State While Auth Initializing
// ============================================================================

class InitAwareWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitializing = ref.watch(isInitializingAuthProvider);

    return isInitializing
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : const ActualWidget();
  }
}

// PATTERN 3: Handle API Response Errors
// ============================================================================

class BookingService {
  Future<BookingEntity> createBooking(BookingRequest request) async {
    try {
      // Make API call (token auto-attached)
      final response = await dioClient.post('/bookings', data: request);

      // Handle specific status codes
      if (response.statusCode == 201) {
        // Success
        return BookingEntity.fromJson(response.data);
      } else if (response.statusCode == 400) {
        // Bad request
        throw ValidationException('Invalid booking data');
      } else if (response.statusCode == 403) {
        // Forbidden (already booked?)
        throw BookingException('You cannot book this slot');
      } else if (response.statusCode == 401) {
        // Unauthorized (handled by interceptor automatically)
        throw SessionException('Your session expired');
      }

      throw UnknownException('Unknown error');
    } on DioException catch (e) {
      // DioException already processed by interceptors
      // Just handle it here
      rethrow;
    }
  }
}

// PATTERN 4: Retry Failed Requests
// ============================================================================

class RetryableOperation extends ConsumerStatefulWidget {
  final Future<T> Function() operation;

  const RetryableOperation({required this.operation});

  @override
  ConsumerState<RetryableOperation> createState() =>
      _RetryableOperationState();
}

class _RetryableOperationState extends ConsumerState<RetryableOperation> {
  int _retryCount = 0;
  static const _maxRetries = 3;

  Future<T> _executeWithRetry<T>() async {
    try {
      return await widget.operation();
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));

        return _executeWithRetry<T>();
      }

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to show result
    return FutureBuilder(
      future: _executeWithRetry(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Column(
            children: [
              Text('Error: ${snapshot.error}'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _retryCount = 0;
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          );
        }

        return Text('Result: ${snapshot.data}');
      },
    );
  }
}

// PATTERN 5: Display Error Messages with Auto-Dismiss
// ============================================================================

class ErrorNotification extends ConsumerStatefulWidget {
  final String message;
  final Duration displayDuration;

  const ErrorNotification({
    required this.message,
    this.displayDuration = const Duration(seconds: 5),
  });

  @override
  ConsumerState<ErrorNotification> createState() =>
      _ErrorNotificationState();
}

class _ErrorNotificationState extends ConsumerState<ErrorNotification> {
  @override
  void initState() {
    super.initState();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void dismiss() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: Colors.red[800]!, width: 4)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[800]),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.message)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: dismiss,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// PATTERN 6: Form Validation with Auth Check
// ============================================================================

class LoginFormValidator {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value!)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }

    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Name is required';
    }

    if (value!.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }
}

// PATTERN 7: Debounce API Calls
// ============================================================================

class DebouncedSearch extends ConsumerStatefulWidget {
  final Function(String) onSearch;

  const DebouncedSearch({required this.onSearch});

  @override
  ConsumerState<DebouncedSearch> createState() => _DebouncedSearchState();
}

class _DebouncedSearchState extends ConsumerState<DebouncedSearch> {
  final TextEditingController _controller = TextEditingController();
  Future<void>? _searchFuture;

  void _onSearchChanged(String value) {
    // Cancel previous search
    _searchFuture = Future.delayed(
      const Duration(milliseconds: 500),
      () => widget.onSearch(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: _onSearchChanged,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============================================================================
// TROUBLESHOOTING GUIDE
// ============================================================================

/*
PROBLEM 1: User keeps getting logged out (401 on every request)
├─ Cause: Token is not being saved to TokenService
├─ Check:
│   ├─ Is TokenService.saveToken() called in login?
│   ├─ Is flutter_secure_storage plugin installed?
│   ├─ Check device storage permissions
│   └─ Check TokenService.getToken() returns saved token
│
├─ Solution:
│   ├─ Verify TokenService.saveToken() is called after login
│   ├─ Test with: final token = await TokenService.getToken()
│   ├─ Check secure storage permissions in AndroidManifest.xml
│   ├─ Clear app data and try again
│   └─ Check server returns valid JWT token
│
└─ Code to test:
    final tokenService = TokenService();
    await tokenService.saveToken('test_token');
    final retrieved = await tokenService.getToken();
    print('Saved: test_token, Retrieved: $retrieved');

PROBLEM 2: Token is not being attached to API requests
├─ Cause: _AuthTokenInterceptor is not configured correctly
├─ Check:
│   ├─ Is DioClient initialized before making requests?
│   ├─ Is _AuthTokenInterceptor added to Dio instance?
│   ├─ Is TokenService.getToken() working?
│   └─ Check request logs for Authorization header
│
├─ Solution:
│   ├─ Verify DioClient() is created in main()
│   ├─ Check _AuthTokenInterceptor is added to dio.interceptors
│   ├─ Verify TokenService returns token
│   ├─ Enable verbose logging:
│   │   dio.interceptors.add(LoggingInterceptor())
│   └─ Check Authorization header in request
│
└─ Enable logging:
    late Dio _dio;

    void _setupLogging() {
      _dio.interceptors.add(
        LoggingInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
        ),
      );
    }

PROBLEM 3: 401 error doesn't trigger logout
├─ Cause: Session expiration callback not set or auth state not updating
├─ Check:
│   ├─ Is DioClient.setSessionExpiredCallback() called?
│   ├─ Is AuthManager.handleSessionExpired() being invoked?
│   ├─ Is Router properly watching isAuthenticatedProvider?
│   └─ Check console logs for "Session expired"
│
├─ Solution:
│   ├─ Add callback in main():
│   │   DioClient.setSessionExpiredCallback(() {
│   │     print('[Auth] Session expired - redirecting to login');
│   │   });
│   │
│   ├─ Verify AuthManager logs:
│   │   print('[AuthManager] Handling session expiration')
│   │
│   ├─ Check Router redirect is watching isAuthenticatedProvider
│   │
│   └─ Test manually:
│       context.read(authManagerProvider).handleSessionExpired()
│
└─ Verify in logs:
    [Auth] Session expired - redirecting to login
    [Router] Redirecting to /login

PROBLEM 4: User stays logged out even with valid token
├─ Cause: AuthManager.initialize() not running or failing silently
├─ Check:
│   ├─ Is authManagerProvider being watched?
│   ├─ Is isInitializingAuthProvider changing?
│   ├─ Can TokenService retrieve saved token?
│   ├─ Does API return valid user data?
│   └─ Check console logs
│
├─ Solution:
│   ├─ Verify authManagerProvider is used:
│   │   ref.watch(isAuthenticatedProvider)
│   │
│   ├─ Check initialization logs:
│   │   print('Init: ${authState.isInitializing}')
│   │
│   ├─ Test token retrieval:
│   │   final token = await TokenService.getToken()
│   │   print('Token: $token')
│   │
│   ├─ Test API manually:
│   │   final response = await dio.get('/user/profile')
│   │
│   └─ Check for exceptions:
│       try {
│         await authManager.initialize()
│       } catch (e) {
│         print('Init error: $e')
│       }
│
└─ Add debug provider:
    final authDebugProvider = FutureProvider((ref) async {
      final authManager = ref.watch(authManagerProvider);
      final token = await authManager.getToken();
      return {
        'token': token,
        'isAuth': ref.watch(isAuthenticatedProvider),
      };
    });

PROBLEM 5: Infinite redirect loop between login and home
├─ Cause: Auth state keeps changing or router guard logic is wrong
├─ Check:
│   ├─ Is redirect guard checking correct providers?
│   ├─ Is there a circular dependency in providers?
│   ├─ Is auth state being reset somewhere?
│   └─ Check router logs
│
├─ Solution:
│   ├─ Verify router redirect logic:
│   │   redirect: (context, state) {
│   │     final auth = ref.read(isAuthenticatedProvider);
│   │     if (!auth && _isProtectedRoute(...)) return '/login';
│   │     if (auth && state.matchedLocation == '/login') return '/home';
│   │     return null; // No redirect
│   │   }
│   │
│   ├─ Add logs to redirect:
│   │   print('Current: ${state.matchedLocation}, Auth: $auth')
│   │
│   ├─ Check for circular watchers in providers
│   │
│   └─ Verify login/logout don't immediately reverse state
│
└─ Debug redirect calls:
    print('Redirect to: ${state.matchedLocation}')

PROBLEM 6: Token expires but app doesn't logout immediately
├─ Cause: App is not making API calls or request doesn't trigger 401
├─ Check:
│   ├─ Is user making API requests?
│   ├─ Did server actually return 401?
│   ├─ Is _ErrorHandlingInterceptor actually called?
│   └─ Check network tab
│
├─ Solution:
│   ├─ Ensure app makes API call after token expires
│   │   (e.g., auto-refresh bookings list)
│   │
│   ├─ Verify server returns 401:
│   │   Check server logs or network inspection
│   │
│   ├─ Add logging to interceptor:
│   │   print('Status: ${response.statusCode}')
│   │
│   └─ Trigger manually:
│       final dioClient = ref.read(dioClientProvider);
│       dioClient.get('/protected-endpoint');
│
└─ Test with expired token:
    1. Save a token
    2. Clear it from backend
    3. Make API call
    4. Should get 401 and redirect

PROBLEM 7: Secure storage not working (especially iOS)
├─ Cause: Platform-specific configuration missing
├─ Check:
│   ├─ iOS: Info.plist permissions?
│   ├─ Android: AndroidManifest.xml permissions?
│   ├─ Android: Gradle keystore configuration?
│   └─ Is plugin installed correctly?
│
├─ Solution:
│   ├─ iOS: Add to ios/Runner/Info.plist:
│   │   <key>UIApplicationSharedUserGroupIdentifier</key>
│   │   <string>group.com.example.saluun</string>
│   │
│   ├─ Android: Add to AndroidManifest.xml:
│   │   <uses-permission android:name=
│   │     "android.permission.USE_CREDENTIALS" />
│   │
│   ├─ Test with:
│   │   flutter pub get
│   │   flutter clean
│   │   flutter run
│   │
│   └─ Check logs for platform-specific errors
│
└─ Fallback test:
    Test with in-memory storage instead:
    final token = '[in-memory-token]';

PROBLEM 8: Multiple 401 errors trigger multiple logouts
├─ Cause: Concurrent requests all get 401 and trigger logout
├─ Check:
│   ├─ Are multiple API calls happening simultaneously?
│   ├─ Does sessionExpired callback execute multiple times?
│   └─ Check logs for "Session expired" appearing multiple times
│
├─ Solution:
│   ├─ Add guard to prevent multiple logouts:
│   │   bool _loggingOut = false;
│   │
│   │   void _handleSessionExpired() {
│   │     if (_loggingOut) return;
│   │     _loggingOut = true;
│   │     authManager.handleSessionExpired();
│   │   }
│   │
│   ├─ Or use Riverpod to prevent duplicate calls:
│   │   if (ref.watch(isAuthenticatedProvider) == false) return;
│   │
│   └─ Add debounce:
│       Future.delayed(Duration(milliseconds: 100), () { ... })
│
└─ Monitor logs:
    Should see "Session expired" only once

PROBLEM 9: App crashes on logout (navigation error)
├─ Cause: Navigation happening during build or widget unmount
├─ Check:
│   ├─ Is context.go() called during build?
│   ├─ Is widget unmounted when callback fires?
│   ├─ Check error stack trace
│   └─ Check "mounted" state
│
├─ Solution:
│   ├─ Use WidgetsBinding.addPostFrameCallback:
│   │   WidgetsBinding.instance.addPostFrameCallback((_) {
│   │     context.go('/login');
│   │   });
│   │
│   ├─ Check mounted state:
│   │   if (!mounted) return;
│   │   context.go('/login');
│   │
│   ├─ Use ref.read in providers instead of context
│   │
│   └─ Handle in router redirect (preferred):
│       redirect: (context, state) {
│         if (sessionExpired) return '/login';
│         return null;
│       }
│
└─ Test logout flow carefully

PROBLEM 10: Provider invalidation not triggering UI rebuild
├─ Cause: Provider is not being invalidated or widgets not watching
├─ Check:
│   ├─ Is widget using ConsumerWidget/ConsumerStatefulWidget?
│   ├─ Is ref.watch() being called?
│   ├─ Is ref.invalidate() actually called on logout?
│   └─ Check console for rebuild logs
│
├─ Solution:
│   ├─ Verify widget structure:
│   │   class MyWidget extends ConsumerWidget {
│   │     @override
│   │     Widget build(BuildContext context, WidgetRef ref) { ... }
│   │   }
│   │
│   ├─ Verify watching provider:
│   │   final authState = ref.watch(authViewModelProvider);
│   │
│   ├─ Call invalidate on logout:
│   │   ref.invalidate(authViewModelProvider);
│   │
│   ├─ Add logs to verify:
│   │   print('Widget rebuilt with auth: $authState');
│   │
│   └─ Test rebuild:
│       ref.refresh(authViewModelProvider)
│
└─ Enable Riverpod logger:
    ProviderContainer(observers: [DebugObserver()])
*/

// ============================================================================
// QUICK DIAGNOSTICS SCRIPT
// ============================================================================

class AuthDiagnostics extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInit = ref.watch(isInitializingAuthProvider);
    final authState = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final token = ref.watch(currentAuthTokenProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Diagnostics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DiagnosticRow(
              label: 'Initializing',
              value: authInit.toString(),
              color: authInit ? Colors.orange : Colors.green,
            ),
            _DiagnosticRow(
              label: 'Authenticated',
              value: authState.toString(),
              color: authState ? Colors.green : Colors.red,
            ),
            _DiagnosticRow(
              label: 'User',
              value: user?.email ?? 'None',
              color: user != null ? Colors.green : Colors.yellow,
            ),
            token.when(
              data: (t) => _DiagnosticRow(
                label: 'Token',
                value: t != null ? '${t.substring(0, 20)}...' : 'None',
                color: t != null ? Colors.green : Colors.yellow,
              ),
              loading: () => _DiagnosticRow(
                label: 'Token',
                value: 'Loading...',
                color: Colors.blue,
              ),
              error: (e, st) => _DiagnosticRow(
                label: 'Token Error',
                value: e.toString(),
                color: Colors.red,
              ),
            ),
            if (error != null)
              _DiagnosticRow(
                label: 'Auth Error',
                value: error,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
