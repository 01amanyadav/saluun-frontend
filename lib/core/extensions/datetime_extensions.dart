/// DateTime Extension Utilities
///
/// Provides helpful extension methods for DateTime formatting and comparisons.

extension DateTimeExtensions on DateTime {
  /// Format DateTime to readable string
  /// Example: DateTime.now().toReadable() → "Monday, March 18, 2026"
  String toReadable() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[weekday - 1]}, ${months[month - 1]} $day, $year';
  }

  /// Format time only to readable string (HH:mm)
  /// Example: DateTime.now().timeOnly() → "14:30"
  String timeOnly() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format to short date format (dd/MM/yyyy)
  String toShortDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Format to long date format (EEEE, MMMM dd, yyyy)
  String toLongDate() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${days[weekday - 1]}, ${months[month - 1]} $day, $year';
  }

  /// Format to ISO 8601 format
  String toISO8601() => toIso8601String();

  /// Get time ago format (e.g., "2 hours ago", "3 days ago")
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get date relative to now (returns "Today", "Tomorrow", "Yesterday", or "date")
  String getRelativeDate() {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return toShortDate();
  }

  /// Check if datetime is between two dates
  bool isBetween(DateTime from, DateTime to) {
    return isAfter(from) && isBefore(to);
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final difference = weekday - 1;
    return subtract(Duration(days: difference)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final difference = 7 - weekday;
    return add(Duration(days: difference)).endOfDay;
  }

  /// Get start of month (1st day)
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month (last day)
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Get start of year (Jan 1st)
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get end of year (Dec 31st)
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days.abs();
    final increment = days > 0 ? 1 : -1;

    while (remaining > 0) {
      result = result.add(Duration(days: increment));
      if (result.weekday != 6 && result.weekday != 7) {
        remaining--;
      }
    }

    return result;
  }

  /// Get next occurrence of a specific day of week
  /// Example: DateTime.now().nextOccurrence(DateTime.friday)
  DateTime nextOccurrence(int dayOfWeek) {
    var result = add(const Duration(days: 1));
    while (result.weekday != dayOfWeek) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  /// Get previous occurrence of a specific day of week
  DateTime previousOccurrence(int dayOfWeek) {
    var result = subtract(const Duration(days: 1));
    while (result.weekday != dayOfWeek) {
      result = result.subtract(const Duration(days: 1));
    }
    return result;
  }

  /// Check if leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get number of days in current month
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Format time with AM/PM
  /// Example: DateTime(2026, 3, 18, 14, 30).toTimeString() → "2:30 PM"
  String toTimeString() {
    final ampm = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $ampm';
  }

  /// Format date and time together
  /// Example: "18/03/2026 2:30 PM"
  String toDateTimeString() {
    return '${toShortDate()} ${toTimeString()}';
  }

  /// Get number of days from now
  int get daysFromNow {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  /// Get number of hours from now
  int get hoursFromNow {
    final now = DateTime.now();
    return difference(now).inHours;
  }

  /// Get number of minutes from now
  int get minutesFromNow {
    final now = DateTime.now();
    return difference(now).inMinutes;
  }
}
