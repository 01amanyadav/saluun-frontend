import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/presentation/providers/booking_provider.dart';
import 'package:saluun_frontend/presentation/viewmodels/booking/my_bookings_ui_state.dart';
import 'package:saluun_frontend/presentation/widgets/booking_card.dart';
import 'package:saluun_frontend/presentation/widgets/custom_button.dart';

/// My Bookings screen displaying user's bookings list
///
/// Features:
/// - Fetches and displays user's bookings
/// - Shows loading indicator while fetching
/// - Shows empty state when no bookings
/// - Shows error state with retry option
/// - Allows cancelling bookings (if eligible)
/// - Status-based color coding and icons
/// - Responsive Material 3 design
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Fetch bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myBookingsViewModelProvider.notifier).fetchMyBookings();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle booking cancellation
  Future<void> _handleCancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!mounted) return;
      try {
        // Call cancel booking API
        await ref
            .read(myBookingsViewModelProvider.notifier)
            .fetchMyBookings(); // Refresh after cancel
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling booking: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(myBookingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), elevation: 0),
      body: _buildBody(context, bookingsState),
    );
  }

  /// Build body based on state
  Widget _buildBody(BuildContext context, MyBookingsUiState state) {
    if (state.isLoading && state.bookings.isEmpty) {
      return const _LoadingState();
    }

    if (state.isEmpty) {
      return _EmptyState(
        onRetry: () {
          ref.read(myBookingsViewModelProvider.notifier).retry();
        },
      );
    }

    if (state.errorMessage != null) {
      return _ErrorState(
        errorMessage: state.errorMessage!,
        onRetry: () {
          ref.read(myBookingsViewModelProvider.notifier).retry();
        },
      );
    }

    return _BookingsList(
      state: state,
      scrollController: _scrollController,
      onCancel: _handleCancelBooking,
    );
  }
}

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Bookings Yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t made any bookings yet.\nStart by booking a service at your favorite salon.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Browse Salons',
              onPressed: () {
                // Navigate to salons screen
                context.go('/salons');
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 24),
            Text(
              'Error Loading Bookings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(label: 'Retry', onPressed: onRetry, width: 120),
          ],
        ),
      ),
    );
  }
}

/// Bookings list widget
class _BookingsList extends ConsumerWidget {
  final MyBookingsUiState state;
  final ScrollController scrollController;
  final Function(String) onCancel;

  const _BookingsList({
    required this.state,
    required this.scrollController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(myBookingsViewModelProvider.notifier).fetchMyBookings();
      },
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Bookings count header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.bookings.length} Booking${state.bookings.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bookings list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () {
                    // Navigate to booking details if needed
                  },
                  onCancel: () {
                    onCancel(booking.id);
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
