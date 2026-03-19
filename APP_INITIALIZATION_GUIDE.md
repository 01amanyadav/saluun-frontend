/// App Initialization with Authentication System
/// 
/// This shows how to properly initialize your Flutter app with the Saluun auth system.
/// Place this code in your main.dart file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/auth/auth_manager.dart';
import 'package:saluun_frontend/core/network/dio_client.dart';
import 'package:saluun_frontend/presentation/providers/auth_manager_provider.dart';
import 'package:saluun_frontend/routes/app_routes.dart';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication system
  await _initializeAuth();

  // Run app
  runApp(const ProviderScope(child: SaluunApp()));
}

// ============================================================================
// AUTHENTICATION INITIALIZATION
// ============================================================================

/// Initialize the authentication system before running the app.
/// This ensures:
/// 1. Token storage is ready
/// 2. DioClient callbacks are configured
/// 3. AuthManager is prepared
/// 4. Auto-login is set up
Future<void> _initializeAuth() async {
  try {
    // Initialize DioClient with error handling
    final dioClient = DioClient();

    // Set up session expiration callback for centralized logout handling
    DioClient.setSessionExpiredCallback(() {
      print('[Auth] Session expired - user will be logged out');
      // Navigation will be handled automatically by auth state change
      // The app will redirect to /login when isAuthenticatedProvider changes
    });

    print('[Auth] Authentication system initialized');
  } catch (e) {
    print('[Auth] Error during initialization: $e');
    // Continue anyway - auth will fail gracefully on first use
  }
}

// ============================================================================
// MAIN APP WIDGET
// ============================================================================

class SaluunApp extends ConsumerWidget {
  const SaluunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router to handle navigation
    final router = _buildRouter(ref);

    return MaterialApp.router(
      title: 'Saluun',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  /// Build the app theme
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Build the router with auth-aware route guards
  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      // Initial path when app starts
      initialLocation: '/',

      // Handle errors
      errorPageBuilder: (context, state) {
        return MaterialPage(
          child: Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // Auth guard for protected routes
      redirect: (context, state) {
        // This is called whenever navigation happens
        final authState = ref.read(isAuthenticatedProvider);
        final isInitializing = ref.read(isInitializingAuthProvider);

        // Show splash while auth is initializing
        if (isInitializing && state.matchedLocation != '/') {
          return '/';
        }

        // Redirect to login if not authenticated and trying to access protected route
        if (!authState && _isProtectedRoute(state.matchedLocation)) {
          return '/login';
        }

        // Redirect to home if authenticated and on login/register
        if (authState && (
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register'
        )) {
          return '/home';
        }

        // No redirect needed
        return null;
      },

      // Define all routes
      routes: [
        // Splash/Home route
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // App routes (protected)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/bookings',
          name: 'bookings',
          builder: (context, state) => const SalonsListScreen(),
        ),
        GoRoute(
          path: '/salon/:id',
          name: 'salonDetails',
          builder: (context, state) => SalonDetailsScreen(
            salonId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/booking',
          name: 'booking',
          builder: (context, state) => const BookingScreen(),
        ),
        GoRoute(
          path: '/my-bookings',
          name: 'myBookings',
          builder: (context, state) => const MyBookingsScreen(),
        ),
      ],
    );
  }

  /// Check if route requires authentication
  bool _isProtectedRoute(String location) {
    final protectedRoutes = [
      '/home',
      '/profile',
      '/bookings',
      '/salon',
      '/booking',
      '/my-bookings',
    ];

    return protectedRoutes.any((route) => location.startsWith(route));
  }
}

// ============================================================================
// SPLASH SCREEN - Show while auth is initializing
// ============================================================================

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth initialization
    final isInitializing = ref.watch(isInitializingAuthProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Once auth is initialized, navigate appropriately
    if (!isInitializing) {
      // Use WidgetsBinding to ensure navigation happens after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/name
            Icon(
              Icons.spa,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Saluun',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Status text
            Text(
              isInitializing ? 'Initializing...' : 'Redirecting...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPLETE INITIALIZATION FLOW
// ============================================================================

/*
APP STARTUP FLOW:
├─ 1. main() called
│   ├─ WidgetsFlutterBinding.ensureInitialized()
│   ├─ _initializeAuth()
│   │   ├─ DioClient() created
│   │   ├─ DioClient.setSessionExpiredCallback() configured
│   │   └─ Ready for auth operations
│   ├─ runApp(SaluunApp())
│   └─ App widget built
│
├─ 2. SaluunApp builds
│   ├─ GoRouter created with routes and guards
│   ├─ MaterialApp.router configured
│   └─ Initial route is '/' (SplashScreen)
│
├─ 3. SplashScreen displays
│   ├─ AuthManager.initialize() is called by authManagerProvider
│   │   ├─ Check TokenService for existing token
│   │   ├─ If found, fetch user info and validate
│   │   ├─ Set isInitializingAuthProvider to true while loading
│   │   └─ Set isInitializingAuthProvider to false when done
│   │
│   └─ While isInitializing == true:
│       └─ Display splash screen with loader
│
├─ 4. AuthManager.initialize() completes
│   ├─ If token valid and user loaded:
│   │   ├─ isAuthenticatedProvider → true
│   │   └─ Router redirects to /home
│   │
│   └─ If no token or token invalid:
│       ├─ isAuthenticatedProvider → false
│       └─ Router redirects to /login
│
└─ 5. App ready
    ├─ User can see home screen or login screen
    ├─ All API requests have automatic token injection
    ├─ 401 responses trigger automatic logout and redirect
    └─ Normal app flow continues

SUBSEQUENT API CALLS:
├─ Any API request via DioClient
├─ _AuthTokenInterceptor automatically:
│   ├─ Gets token from TokenService
│   ├─ Adds Authorization: Bearer <token> header
│   └─ Sends request
│
├─ If response is 401:
│   ├─ _ErrorHandlingInterceptor catches error
│   ├─ Calls DioClient._onSessionExpired()
│   ├─ AuthManager.handleSessionExpired():
│   │   ├─ Clears token
│   │   ├─ Sets isAuthenticatedProvider to false
│   │   └─ Triggers callback
│   │
│   └─ Router automatically:
│       ├─ Redirects to /login
│       ├─ Shows session expired message
│       └─ User can login again
│
└─ If response is successful:
    └─ Data is returned normally

USER LOGIN FLOW:
├─ User on LoginScreen enters credentials
├─ Clicks "Login" button
├─ AuthViewModel.login() called
├─ API call: POST /auth/login with credentials
├─ If successful:
│   ├─ Token received and saved to TokenService
│   ├─ User info saved to CurrentUserService
│   ├─ AuthViewModel state updates
│   └─ Router redirects to /home
│
└─ If failed:
    ├─ Error displayed in UI
    └─ User can retry

USER LOGOUT FLOW:
├─ User clicks "Logout" button
├─ Confirmation dialog shown
├─ AuthViewModel.logout() called
├─ TokenService.clearToken()
├─ CurrentUserService.clearUser()
├─ AuthViewModel state resets
├─ Router redirects to /login
└─ All API headers cleared (no token)
*/

// ============================================================================
// KEY POINTS TO REMEMBER
// ============================================================================

/*
1. INITIALIZATION
   - Call _initializeAuth() in main() before runApp()
   - This sets up DioClient and its callbacks
   - AuthManager initialization happens lazily in authManagerProvider

2. AUTH STATE WATCHING
   - Use isAuthenticatedProvider to check if user is logged in
   - Use isInitializingAuthProvider to show splash screen
   - Use currentUserProvider to get user data
   - Use authErrorProvider to show error messages

3. TOKEN MANAGEMENT
   - Tokens are automatically added to all API requests
   - Tokens are automatically cleared on logout
   - Tokens are automatically cleared on 401 response
   - No manual token handling needed!

4. ERROR HANDLING
   - 401 errors are caught by DioClient interceptor
   - User is automatically logged out
   - App automatically redirects to /login
   - No try-catch needed for 401 handling!

5. PROTECTED ROUTES
   - Use GoRouter's redirect callback to guard routes
   - Check isAuthenticatedProvider in redirect
   - Redirect to /login if not authenticated
   - See _buildRouter() for implementation

6. API CALLS
   - All API calls automatic token injection
   - No need to manually add Authorization header
   - Use DioClient from dioClientProvider
   - Example: ref.read(dioClientProvider).get('/user/profile')
*/
