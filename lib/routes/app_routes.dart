import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/presentation/screens/auth/login_screen.dart';
import 'package:saluun_frontend/presentation/screens/auth/register_screen.dart';
import 'package:saluun_frontend/presentation/screens/home/home_screen.dart';
import 'package:saluun_frontend/presentation/screens/salons/salon_list_screen.dart';
import 'package:saluun_frontend/presentation/screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
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

      // App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/salons',
        name: 'salons',
        builder: (context, state) => const SalonListScreen(),
      ),
      GoRoute(
        path: '/salon/:id',
        name: 'salonDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: const Text('Salon Details')),
            body: Center(child: Text('Salon Detail: $id\n(Coming soon)')),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],

    // Error Page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('404: ${state.error}')),
    ),
  );
});
