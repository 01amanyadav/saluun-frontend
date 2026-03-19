import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saluun_frontend/data/models/api_models.dart';
import 'package:saluun_frontend/presentation/models/salon_details.dart';
import 'package:saluun_frontend/presentation/providers/booking_provider.dart';
import 'package:saluun_frontend/presentation/providers/salon_provider.dart';
import 'package:saluun_frontend/presentation/widgets/booking_slot_picker.dart';
import 'package:saluun_frontend/presentation/widgets/custom_button.dart';

/// Booking screen for scheduling salon services
///
/// Features:
/// - Service selection with pricing and duration display
/// - Date picker for booking date
/// - Time slot picker with predefined slots
/// - Input validation
/// - Loading state during API call
/// - Success/Error notifications
/// - Complete booking form following Material 3 design
class BookingScreen extends ConsumerStatefulWidget {
  final String salonId;
  final String? initialServiceId;

  const BookingScreen({
    super.key,
    required this.salonId,
    this.initialServiceId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late ScrollController _scrollController;

  // Form state
  String? _selectedServiceId;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // Predefined time slots (can be customized or loaded from API)
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedServiceId = widget.initialServiceId;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Validate all required fields
  bool _validateForm() {
    if (_selectedServiceId == null) {
      _showErrorSnackbar('Please select a service');
      return false;
    }
    if (_selectedDate == null) {
      _showErrorSnackbar('Please select a date');
      return false;
    }
    if (_selectedTimeSlot == null) {
      _showErrorSnackbar('Please select a time slot');
      return false;
    }
    return true;
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle booking creation
  Future<void> _handleBooking() async {
    if (!_validateForm()) {
      return;
    }

    final bookingViewModel = ref.read(bookingViewModelProvider.notifier);

    // Format date as YYYY-MM-DD
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    await bookingViewModel.createBooking(
      salonId: widget.salonId,
      serviceId: _selectedServiceId!,
      bookingDate: dateString,
      bookingTime: _selectedTimeSlot!,
    );

    if (!mounted) return;

    // Check state and handle success/error
    final bookingState = ref.read(bookingViewModelProvider);
    if (bookingState.isSuccess) {
      _showSuccessSnackbar('Booking created successfully!');
      // Navigate back or to bookings list after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.pop();
      }
    } else if (bookingState.errorMessage != null) {
      _showErrorSnackbar(bookingState.errorMessage!);
    }
  }

  /// Pick date using DatePicker
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final salonDetailsAsync = ref.watch(
      salonDetailsWithServicesProvider(widget.salonId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service'), elevation: 0),
      body: salonDetailsAsync.when(
        data: (salonDetails) {
          if (salonDetails == null) {
            return const Center(child: Text('Salon not found'));
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Info Card
                _buildSalonInfoCard(salonDetails),
                const SizedBox(height: 32),

                // Service Selection Section
                _buildServiceSelectionSection(salonDetails),
                const SizedBox(height: 32),

                // Date Selection Section
                _buildDateSelectionSection(),
                const SizedBox(height: 32),

                // Time Slot Selection Section
                _buildTimeSlotSelectionSection(),
                const SizedBox(height: 32),

                // Booking Summary
                if (_selectedServiceId != null)
                  _buildBookingSummary(salonDetails),
                const SizedBox(height: 24),

                // Book Button
                CustomButton(
                  label: 'Confirm Booking',
                  onPressed: _handleBooking,
                  isLoading: bookingState.isLoading,
                  isEnabled: !bookingState.isLoading,
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading salon: $error')),
      ),
    );
  }

  /// Build salon info card at top
  Widget _buildSalonInfoCard(SalonDetails salonDetails) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salonDetails.salon.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    salonDetails.salon.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build service selection section
  // ONLY showing fixed parts cleanly integrated

  /// Build service selection section
  Widget _buildServiceSelectionSection(SalonDetails salonDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (salonDetails.services.isEmpty)
          Center(
            child: Text(
              'No services available',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salonDetails.services.length,
            itemBuilder: (context, index) {
              final service = salonDetails.services[index];
              final isSelected = _selectedServiceId == service.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceId = service.id;
                  });
                },
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              if (service.durationMinutes != null)
                                Text(
                                  'Duration: ${service.durationMinutes} mins',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),

                              if (service.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  service.description!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs ${service.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Build date selection section
  Widget _buildDateSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickDate,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'Tap to select date',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build time slot selection section
  Widget _buildTimeSlotSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BookingSlotPicker(
          timeSlots: _timeSlots,
          selectedSlot: _selectedTimeSlot,
          onSlotSelected: (slot) {
            setState(() {
              _selectedTimeSlot = slot;
            });
          },
        ),
      ],
    );
  }

  /// Build booking summary card
  Widget _buildBookingSummary(SalonDetails salonDetails) {
    final selectedService = salonDetails.services.firstWhere(
      (s) => s.id == _selectedServiceId,
      orElse: () => null as Service,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _summaryRow('Service', selectedService.name),
            _summaryRow(
              'Price',
              'Rs ${selectedService.price.toStringAsFixed(0)}',
            ),
            if (_selectedDate != null)
              _summaryRow('Date', _formatDate(_selectedDate!)),
            if (_selectedTimeSlot != null)
              _summaryRow('Time', _selectedTimeSlot!),
          ],
        ),
      ),
    );
  }

  /// Build summary row for booking summary
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
