import 'package:flutter/material.dart';

/// Custom widget for selecting time slots
class BookingSlotPicker extends StatefulWidget {
  final List<String> timeSlots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const BookingSlotPicker({
    super.key,
    required this.timeSlots,
    this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  State<BookingSlotPicker> createState() => _BookingSlotPickerState();
}

class _BookingSlotPickerState extends State<BookingSlotPicker> {
  late String _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.selectedSlot ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.timeSlots.isEmpty) {
      return Center(
        child: Text(
          'No time slots available',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.timeSlots.length, (index) {
          final slot = widget.timeSlots[index];
          final isSelected = _selectedSlot == slot;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSlot = slot;
                });
                widget.onSlotSelected(slot);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
