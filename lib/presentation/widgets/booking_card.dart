import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saluun_frontend/domain/entities/booking_entity.dart';

/// Reusable BookingCard widget for displaying booking information
class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
    this.showCancelButton = true,
  });

  /// Get status color based on booking status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'completed':
        return Colors.blue[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Get status icon based on booking status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.history;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Check if booking can be cancelled
  bool _canBeCancelled() {
    final status = booking.status.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Booking ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking #${booking.id.substring(0, 8).toUpperCase()}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(booking.bookingDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          booking.status[0].toUpperCase() +
                              booking.status.substring(1),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Booking Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.schedule,
                      label: 'Time',
                      value: booking.bookingTime,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.attach_money,
                      label: 'Price',
                      value: booking.totalPrice != null
                          ? 'Rs ${booking.totalPrice!.toStringAsFixed(0)}'
                          : 'N/A',
                      theme: theme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Service and Salon IDs (smaller text)
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.local_offer,
                      label: 'Service',
                      value: 'ID: ${booking.serviceId.substring(0, 6)}',
                      theme: theme,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.store,
                      label: 'Salon',
                      value: 'ID: ${booking.salonId.substring(0, 6)}',
                      theme: theme,
                      compact: true,
                    ),
                  ),
                ],
              ),

              // Cancel Button (if applicable)
              if (showCancelButton && _canBeCancelled()) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel Booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail item with icon and label
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool compact = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: compact ? 16 : 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: compact ? 11 : 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
