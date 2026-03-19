/// BOOKING SYSTEM INTEGRATION EXAMPLES
/// 
/// This file shows common ways to integrate the BookingScreen
/// into your existing application.

// =============================================================================
// EXAMPLE 1: Navigation from SalonDetailsScreen
// =============================================================================

// In salon_details_screen.dart, add this to your service card tap:
void onServiceTap(Service service) {
  context.pushNamed(
    'booking',
    pathParameters: {
      'salonId': widget.salonId,
    },
    queryParameters: {
      'serviceId': service.id,
    },
  );
}

// Or using the context.go method:
void onServiceTap(Service service) {
  context.go('/booking/${widget.salonId}?serviceId=${service.id}');
}

// =============================================================================
// EXAMPLE 2: Navigation from Home Screen (with salon selection)
// =============================================================================

void navigateToBooking(String salonId, String serviceId) {
  context.pushNamed(
    'booking',
    pathParameters: {'salonId': salonId},
    queryParameters: {'serviceId': serviceId},
  );
}

// =============================================================================
// EXAMPLE 3: Using Riverpod to watch booking state
// =============================================================================

class BookingStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);

    return bookingState.when(
      loading: () => const CircularProgressIndicator(),
      success: (booking) => Text('Booking ID: ${booking?.id}'),
      error: (error) => Text('Error: $error'),
      idle: () => const SizedBox.shrink(),
    );
  }
}

// =============================================================================
// EXAMPLE 4: Reset booking state after navigation
// =============================================================================

class BookingAwareWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<BookingAwareWidget> createState() =>
      _BookingAwareWidgetState();
}

class _BookingAwareWidgetState extends ConsumerState<BookingAwareWidget> {
  @override
  void initState() {
    super.initState();
    // Reset booking state when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// =============================================================================
// EXAMPLE 5: Custom booking button component
// =============================================================================

class BookServiceButton extends StatelessWidget {
  final String salonId;
  final String? serviceId;
  final String label;

  const BookServiceButton({
    required this.salonId,
    this.serviceId,
    this.label = 'Book Service',
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: label,
      onPressed: () {
        context.pushNamed(
          'booking',
          pathParameters: {'salonId': salonId},
          queryParameters: if (serviceId != null) {'serviceId': serviceId!},
        );
      },
    );
  }
}

// Usage in any screen:
// BookServiceButton(salonId: salon.id, serviceId: service.id)

// =============================================================================
// EXAMPLE 6: Multi-step booking flow
// =============================================================================

class BookingFlowManager {
  static void startBooking(
    BuildContext context,
    String salonId, {
    String? serviceId,
  }) {
    // You can add pre-booking checks here
    _confirmBookingStart(context, salonId, serviceId);
  }

  static void _confirmBookingStart(
    BuildContext context,
    String salonId,
    String? serviceId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceed to Booking?'),
        content: const Text('You will be directed to the booking form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushNamed(
                'booking',
                pathParameters: {'salonId': salonId},
                queryParameters: if (serviceId != null)
                  {'serviceId': serviceId},
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Usage:
// BookingFlowManager.startBooking(context, salonId, serviceId: serviceId)

// =============================================================================
// EXAMPLE 7: Listen to booking success and perform actions
// =============================================================================

class BookingListener extends ConsumerWidget {
  final Widget child;

  const BookingListener({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BookingUiState>(bookingViewModelProvider, (previous, next) {
      if (next.isSuccess && next.booking != null) {
        // Booking successful
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: Text('Booking ID: ${next.booking!.id}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Optional: reset state after delay
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(bookingViewModelProvider.notifier).reset();
        });
      }
    });

    return child;
  }
}

// Wrap your app or specific widget with BookingListener:
// BookingListener(child: YourApp())

// =============================================================================
// EXAMPLE 8: Handle booking errors with retry
// =============================================================================

class BookingErrorHandler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);

    if (bookingState.errorMessage != null) {
      return Column(
        children: [
          Text(
            'Booking failed: ${bookingState.errorMessage}',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Retry',
            onPressed: () {
              // User can retry by clicking button on BookingScreen
              ref.read(bookingViewModelProvider.notifier).reset();
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// =============================================================================
// EXAMPLE 9: Conditional booking button display
// =============================================================================

class ConditionalBookingButton extends ConsumerWidget {
  final String salonId;
  final String? serviceId;

  const ConditionalBookingButton({
    required this.salonId,
    this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);

    // Only show if not loading and no active booking
    if (bookingState.isLoading || bookingState.isSuccess) {
      return const SizedBox.shrink();
    }

    return CustomButton(
      label: 'Book Now',
      onPressed: () {
        context.pushNamed(
          'booking',
          pathParameters: {'salonId': salonId},
          queryParameters: if (serviceId != null) {'serviceId': serviceId!},
        );
      },
    );
  }
}

// =============================================================================
// EXAMPLE 10: Integration with user profile bookings
// =============================================================================

class MyBookingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final recentBooking = ref.watch(bookingViewModelProvider);

    return bookingsAsync.when(
      data: (bookings) {
        // Show existing bookings
        final allBookings = [
          if (recentBooking.booking != null) recentBooking.booking!,
          ...bookings,
        ];

        return ListView.builder(
          itemCount: allBookings.length,
          itemBuilder: (context, index) {
            final booking = allBookings[index];
            return BookingCard(booking: booking);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

// =============================================================================
// SUMMARY OF IMPORTS NEEDED
// =============================================================================

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/presentation/providers/booking_provider.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/booking_ui_state.dart';
import 'package:saluun_frontend/presentation/widgets/custom_button.dart';
*/
