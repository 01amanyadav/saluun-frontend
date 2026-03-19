/// Authentication System - Practical Code Examples
/// 
/// This file contains ready-to-use code snippets for common auth scenarios.

// ============================================================================
// EXAMPLE 1: Check Authentication Status
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/presentation/providers/auth_manager_provider.dart';

class AuthStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitializing = ref.watch(isInitializingAuthProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// ============================================================================
// EXAMPLE 2: Login Implementation
// ============================================================================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);

    final success = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.user != null && authState.errorMessage == null) {
      // Login successful - navigate to home
      context.go('/home');
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Logout Implementation
// ============================================================================

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Perform logout
      await ref.read(authViewModelProvider.notifier).logout();

      if (context.mounted) {
        // Navigate to login
        context.go('/login');

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser != null) ...[
              Text(
                currentUser.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(currentUser.email),
              const SizedBox(height: 32),
            ],
            ElevatedButton.icon(
              onPressed: () => _handleLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Protected Routes (Auto-logout on 401)
// ============================================================================

// The error handling is automatic via DioClient interceptor.
// When API returns 401:
// 1. _ErrorHandlingInterceptor catches it
// 2. Calls DioClient._onSessionExpired()
// 3. AuthManager.handleSessionExpired() clears tokens
// 4. Router automatically redirects to /login
// 5. User sees "Session expired" message

// No additional code needed - it's handled centrally!

// ============================================================================
// EXAMPLE 5: Get Current Token
// ============================================================================

class TokenDebugWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(currentAuthTokenProvider);

    return tokenAsync.when(
      data: (token) {
        if (token == null) {
          return const Text('No token found');
        }
        return Column(
          children: [
            const Text('Current Token:'),
            SelectableText(
              token.substring(0, 50) + '...',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// EXAMPLE 6: Manual Token Refresh (Optional)
// ============================================================================

class TokenRefreshExample extends ConsumerWidget {
  Future<void> _refreshAuth(WidgetRef ref) async {
    final authManager = ref.read(authManagerProvider);

    // Manually refresh auth state
    await authManager.refreshAuthState();

    // Or get fresh token
    final token = await authManager.getToken();
    print('Current token: $token');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _refreshAuth(ref),
      child: const Text('Refresh Auth'),
    );
  }
}

// ============================================================================
// EXAMPLE 7: Navigate Based on Auth State
// ============================================================================

class AuthBasedNavigation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isInitializing = ref.watch(isInitializingAuthProvider);

    // Show splash while initializing
    if (isInitializing) {
      return const SplashScreen();
    }

    // Show appropriate screen based on auth state
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: isAuthenticated
          ? const HomeScreen()
          : const Center(
              child: Text('Please login to continue'),
            ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Display Auth Errors
// ============================================================================

class AuthErrorDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authError = ref.watch(authErrorProvider);
    final authManager = ref.watch(authManagerProvider);

    return SafeArea(
      child: Column(
        children: [
          if (authError != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[900]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authError,
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      authManager.clearError();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 9: Register New User
// ============================================================================

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _handleRegister() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);

    await authViewModel.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.user != null && authState.errorMessage == null) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                enabled: !authState.isLoading,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: !authState.isLoading,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !authState.isLoading,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleRegister,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

// ============================================================================
// EXAMPLE 10: API Request with Auto Token Injection
// ============================================================================

class ProfileDataWidget extends ConsumerWidget {
  Future<Map<String, dynamic>> _fetchProfile(WidgetRef ref) async {
    final dioClient = ref.read(dioClientProvider);

    // Token is automatically added by _AuthTokenInterceptor
    // No need to manually add Authorization header
    final response = await dioClient.get('/user/profile');

    return response.data;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _fetchProfile(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final profile = snapshot.data as Map<String, dynamic>;
        return Text('Name: ${profile['name']}');
      },
    );
  }
}

// ============================================================================
// SUMMARY OF KEY COMPONENTS
// ============================================================================

/*
Key Providers to Use:
├─ isAuthenticatedProvider        → Check if user is logged in
├─ isInitializingAuthProvider     → Check if auth is initializing
├─ currentAuthTokenProvider       → Get current JWT token
├─ authErrorProvider              → Get current auth error
├─ authViewModelProvider          → Watch/control auth state
├─ authManagerProvider            → Direct access to AuthManager
├─ currentUserProvider            → Get logged-in user
└─ dioClientProvider              → Make authenticated API calls

Navigation:
├─ /login       → LoginScreen
├─ /register    → RegisterScreen
├─ /home        → Protected (requires auth)
├─ /profile     → Protected (requires auth)
└─ /my-bookings → Protected (requires auth)

On 401 Error:
1. DioClient._ErrorHandlingInterceptor catches it
2. Calls DioClient._onSessionExpired()
3. AuthManager.handleSessionExpired()
4. Clears tokens
5. Re-routes to /login
6. Shows "Session expired" message
*/
