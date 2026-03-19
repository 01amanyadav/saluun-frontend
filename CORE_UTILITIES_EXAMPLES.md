/// Core Utilities - Practical Implementation Examples
/// 
/// Real-world examples showing how to use all available utilities together.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saluun_frontend/core/index.dart';

// ============================================================================
// EXAMPLE 1: User Registration Form with Validation
// ============================================================================

class RegistrationForm {
  /// Validate all fields using String extensions
  Map<String, String?> validateForm({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    final errors = <String, String?>{};

    // Validate name
    if (name.isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    } else {
      Logger.action('Name validated', data: name);
    }

    // Validate email using extension
    if (!email.isValidEmail()) {
      errors['email'] = AppConstants.errorValidation;
      Logger.warning('Invalid email format', tag: 'Validation');
    } else {
      Logger.action('Email validated', data: email);
    }

    // Validate phone using extension
    if (!phone.isValidPhoneNumber()) {
      errors['phone'] = 'Invalid phone number format';
      Logger.warning('Invalid phone format', tag: 'Validation');
    } else {
      Logger.action('Phone validated', data: phone);
    }

    // Validate password
    if (password.length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    } else {
      Logger.info('Password validation passed');
    }

    return errors;
  }

  /// Register user and return NetworkResult
  Future<NetworkResult<User>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Validate first
      final errors = validateForm(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (errors.isNotEmpty) {
        Logger.warning('Form validation failed', tag: 'Auth');
        return Error(errors.values.whereType<String>().first);
      }

      // Log operation start
      final timer = Logger.startTimer('User registration');

      // Prepare request
      final requestData = {
        'name': name.toTitleCase(),
        'email': email,
        'phone': phone,
        'password': password,
      };

      Logger.api('POST /auth/register', requestData.keys.join(', '));

      // Make API call
      final response = await DioClient().post(
        AppConstants.authRegister,
        data: requestData,
      );

      timer.stop();

      // Parse response
      final user = User.fromJson(response.data);
      Logger.info('User registered: ${user.email}', tag: 'Auth');

      return Success(user);
    } on DioException catch (e) {
      Logger.error('Registration failed', error: e);
      return Error(AppConstants.errorServer);
    } catch (e) {
      Logger.fatal('Unexpected registration error', error: e);
      return Error(AppConstants.errorUnknown);
    }
  }
}

// ============================================================================
// EXAMPLE 2: Booking List with Date Formatting
// ============================================================================

class BookingListDisplay {
  /// Format bookings for display using DateTime extensions
  String formatBookingInfo(Booking booking) {
    final dateFormatted = booking.bookingDate.toReadable();
    final timeFormatted = booking.bookingTime.timeOnly();
    final timeAgo = booking.createdAt.timeAgo();

    return '$dateFormatted at $timeFormatted (booked $timeAgo)';
  }

  /// Get booking status with date comparison
  String getBookingStatus(Booking booking) {
    final now = DateTime.now();

    if (booking.completedAt != null) {
      return 'Completed ${booking.completedAt!.timeAgo()}';
    }

    if (booking.bookingDate.isPast) {
      return 'Missed';
    }

    if (booking.bookingDate.isTomorrow) {
      return 'Tomorrow at ${booking.bookingTime.timeOnly()}';
    }

    if (booking.bookingDate.isToday) {
      return 'Today at ${booking.bookingTime.timeOnly()}';
    }

    final daysUntil = booking.bookingDate.difference(now).inDays;
    return 'In $daysUntil days';
  }

  /// Build booking card widget using extensions
  Widget buildBookingCard(Booking booking, VoidCallback onTap) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon name
          Text(
            booking.salonName.toTitleCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).withSmallPadding(),

          // Date and time
          Text(
            formatBookingInfo(booking),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ).withSmallPadding(),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(booking),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              getBookingStatus(booking),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ).withSmallPadding(),

          // Buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: onTap,
                child: const Text('View Details'),
              ).flexible(),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Logger.action('Reschedule', data: booking.id),
                child: const Text('Reschedule'),
              ).flexible(),
            ],
          ).withSmallPadding(),
        ],
      )
      .withBorder(color: Colors.grey[300]!, width: 1)
      .withBorderRadius(12)
      .withMargin(all: 8)
      .onTap(() {
        Logger.action('Booking tapped', data: booking.id);
        onTap();
      }),
    );
  }

  Color _getStatusColor(Booking booking) {
    if (booking.completedAt != null) return Colors.green;
    if (booking.bookingDate.isPast) return Colors.grey;
    if (booking.bookingDate.isToday) return Colors.orange;
    return Colors.blue;
  }
}

// ============================================================================
// EXAMPLE 3: Salon Rating Display with Number Formatting
// ============================================================================

class SalonRatingDisplay {
  /// Format ratings and reviews
  String formatRatingText(double rating, int reviewCount) {
    final formattedRating = rating.formatRating(decimals: 1);
    return '$formattedRating ⭐ ($reviewCount reviews)';
  }

  /// BuildRating bar with percentage formatting
  Widget buildRatingBar(String label, int votes, int totalVotes) {
    final percentage = votes.percentageOf(totalVotes);
    final percentageText = percentage.toPercentage(decimals: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label).expanded(),
            Text(percentageText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ).withSmallPadding(),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Display salon stats using number extensions
  Widget buildSalonStats(Salon salon) {
    return Container(
      child: Column(
        children: [
          // Rating
          Text(
            formatRatingText(salon.rating, salon.reviewCount),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).withMediumPadding(),

          const Divider(),

          // Price range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price Range:'),
              Text(
                '${salon.minPrice.formatCurrency()} - ${salon.maxPrice.formatCurrency()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ).withSmallPadding(),

          // Average service duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Avg. Service Time:'),
              Text(
                salon.avgDuration.formatDuration(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ).withSmallPadding(),

          // Total bookings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bookings:'),
              Text(
                salon.totalBookings.formatNumber(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ).withSmallPadding(),
        ],
      )
      .withBorder(color: Colors.grey[300]!, width: 1)
      .withBorderRadius(12)
      .withPadding(all: 16),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Data Processing with Performance Monitoring
// ============================================================================

class DataProcessor {
  /// Process large dataset with performance monitoring
  Future<NetworkResult<List<Service>>> processServices(List<dynamic> rawData) async {
    try {
      final timer = Logger.startTimer('Process services');

      // Validate input
      if (rawData.isEmpty) {
        return Error('No services found');
      }

      Logger.debug('Processing ${rawData.length} services', tag: 'Data');

      // Process data
      final services = rawData
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();

      timer.stop();

      Logger.info('Services processed successfully', tag: 'Data');
      return Success(services);
    } catch (e) {
      Logger.error('Failed to process services', error: e);
      return Error(AppConstants.errorServer);
    }
  }

  /// Filter and sort services with logging
  List<Service> filterServices(
    List<Service> services, {
    required double minPrice,
    required double maxPrice,
    required int minDuration,
  }) {
    Logger.debug(
      'Filtering services: price ${minPrice.formatCurrency()}-${maxPrice.formatCurrency()}, min duration ${minDuration}m',
      tag: 'Filter',
    );

    final timer = Logger.startTimer('Filter services');

    final filtered = services
        .where((s) =>
            s.price.isBetween(minPrice, maxPrice) &&
            s.duration >= minDuration)
        .toList();

    // Sort by rating
    filtered.sort((a, b) => b.rating.compareTo(a.rating));

    timer.stop();

    Logger.info('Filtered: ${filtered.length} services', tag: 'Filter');
    return filtered;
  }
}

// ============================================================================
// EXAMPLE 5: Error Handling with Custom Exceptions
// ============================================================================

class ErrorHandler {
  /// Handle different API errors using extensions and logging
  Future<void> handleApiError(dynamic error, BuildContext context) async {
    Logger.error('API Error', error: error);

    String message = AppConstants.errorUnknown;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectTimeout:
        case DioExceptionType.receiveTimeout:
          message = AppConstants.errorTimeout;
          Logger.warning('Request timeout', tag: 'Network');
          break;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            message = AppConstants.errorUnauthorized;
          } else if (statusCode == 403) {
            message = AppConstants.errorForbidden;
          } else if (statusCode == 404) {
            message = AppConstants.errorNotFound;
          } else {
            message = AppConstants.errorServer;
          }
          Logger.warning('Bad response: $statusCode', tag: 'Network');
          break;

        case DioExceptionType.unknown:
          message = AppConstants.errorNetwork;
          Logger.warning('Unknown network error', tag: 'Network');
          break;

        default:
          message = AppConstants.errorNetwork;
      }
    } else if (error is AppException) {
      message = error.message;
      Logger.warning('App exception: ${error.runtimeType}', tag: 'App');
    }

    // Show error to user
    if (context.mounted) {
      context.showErrorSnackBar(message);
    }
  }
}

// ============================================================================
// EXAMPLE 6: Screen with All Utilities Combined
// ============================================================================

class SalonDetailScreen extends ConsumerWidget {
  final String salonId;

  const SalonDetailScreen({required this.salonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.lifecycle('Salon detail screen opened: $salonId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Details'),
      ),
      body: FutureBuilder(
        future: _loadSalonData(salonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading salon details...')
                      .withMediumPadding(),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            Logger.error('Failed to load salon', error: snapshot.error);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}')
                      .withMediumPadding(),
                  ElevatedButton(
                    onPressed: () {
                      Logger.action('Retry salon loading');
                      // Trigger rebuild
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final result = snapshot.data as NetworkResult<Salon>?;
          if (result == null) {
            return const Center(child: Text('No data'));
          }

          return result.when(
            success: (salon) => _buildSalonContent(context, salon),
            error: (message) => Center(
              child: Text(message).withMediumPadding(),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Future<NetworkResult<Salon>> _loadSalonData(String id) async {
    try {
      final timer = Logger.startTimer('Load salon details');
      Logger.api('GET /salons/$id');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      timer.stop();
      Logger.info('Salon loaded: $id');

      // Return mock data
      return Success(
        Salon(
          id: id,
          name: 'Elite Salon',
          rating: 4.5,
          reviewCount: 128,
          minPrice: 50,
          maxPrice: 200,
          avgDuration: 60,
          totalBookings: 2500,
        ),
      );
    } catch (e) {
      Logger.error('Salon loading failed', error: e);
      return Error(AppConstants.errorServer);
    }
  }

  Widget _buildSalonContent(BuildContext context, Salon salon) {
    final ratingDisplay = SalonRatingDisplay();
    final formatter = SalonRatingDisplay();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: context.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon.name.toTitleCase(),
                  style: context.headlineLarge?.copyWith(color: Colors.white),
                ).withMediumPadding(),
                Text(
                  formatter.formatRatingText(salon.rating, salon.reviewCount),
                  style: context.bodyLarge?.copyWith(color: Colors.white70),
                ).withMediumPadding(),
              ],
            ),
          ),

          // Stats
          ratingDisplay.buildSalonStats(salon).withLargePadding(),

          // Rating breakdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating Breakdown',
                style: context.titleLarge,
              ).withMediumPadding(),
              ratingDisplay.buildRatingBar('5 ⭐', 95, 128).withSmallPadding(),
              const SizedBox(height: 12),
              ratingDisplay.buildRatingBar('4 ⭐', 28, 128).withSmallPadding(),
              const SizedBox(height: 12),
              ratingDisplay.buildRatingBar('3 ⭐', 5, 128).withSmallPadding(),
            ],
          ).withLargePadding(),

          // Book button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Logger.action('Book now tapped', data: salon.id);
                context.goNamed('booking');
              },
              child: const Text('Book Now'),
            ),
          ).withLargePadding(),
        ],
      ),
    );
  }
}

// ============================================================================
// MOCK MODELS (for example purposes)
// ============================================================================

class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Booking {
  final String id;
  final String salonName;
  final DateTime bookingDate;
  final DateTime bookingTime;
  final DateTime createdAt;
  final DateTime? completedAt;

  Booking({
    required this.id,
    required this.salonName,
    required this.bookingDate,
    required this.bookingTime,
    required this.createdAt,
    this.completedAt,
  });
}

class Service {
  final String id;
  final String name;
  final double price;
  final int duration;
  final double rating;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.rating,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

class Salon {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final double minPrice;
  final double maxPrice;
  final int avgDuration;
  final int totalBookings;

  Salon({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.minPrice,
    required this.maxPrice,
    required this.avgDuration,
    required this.totalBookings,
  });
}

// ============================================================================
// SUMMARY
// ============================================================================

/*
This example demonstrates:

1. ✅ NetworkResult for consistent API response handling
2. ✅ Logger for detailed operation tracking
3. ✅ String extensions for validation and formatting
4. ✅ DateTime extensions for date/time operations
5. ✅ Number extensions for formatting prices and durations
6. ✅ BuildContext extensions for UI feedback
7. ✅ Widget extensions for cleaner UI code
8. ✅ AppConstants for centralized values
9. ✅ Exception handling with proper logging
10. ✅ Performance monitoring with Logger timers

All these utilities work together seamlessly to create maintainable,
scalable, and consistent code following Clean Architecture principles.
*/
