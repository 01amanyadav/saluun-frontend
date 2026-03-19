/// String Extension Utilities
///
/// Provides helpful extension methods for String operations.

extension StringExtensions on String {
  /// Capitalize first letter of string
  /// Example: "hello world" → "Hello world"
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  /// Example: "hello world" → "Hello World"
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }

  /// Remove whitespace from string
  /// Example: "hello world" → "helloworld"
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is a valid email
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number
  /// Accepts various formats: +1-234-567-8900, (123) 456-7890, 1234567890, etc.
  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$');
    return phoneRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool isValidUrl() {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Truncate string to maximum length with ellipsis
  /// Example: "hello world".truncate(5) → "he..."
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Check if string contains any HTML/XML tags
  bool hasHTMLTags() {
    return RegExp(r'<[^>]*>').hasMatch(this);
  }

  /// Remove HTML/XML tags from string
  String removeHTMLTags() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Reverse string
  /// Example: "hello" → "olleh"
  String reverse() {
    return split('').reversed.join('');
  }

  /// Check if string equals another string (case-insensitive)
  bool equalsIgnoreCase(String other) {
    return toLowerCase() == other.toLowerCase();
  }

  /// Repeat string n times
  /// Example: "ab".repeat(3) → "ababab"
  String repeat(int count) {
    return List.filled(count, this).join();
  }

  /// Get first character
  String? get firstChar => isNotEmpty ? this[0] : null;

  /// Get last character
  String? get lastChar => isNotEmpty ? this[length - 1] : null;

  /// Convert string to slug (URL-friendly format)
  /// Example: "Hello World" → "hello-world"
  String toSlug() {
    return toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  /// Check if string is numeric
  bool isNumeric() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Parse string to int, returning null if invalid
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Parse string to double, returning null if invalid
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Get initials from name
  /// Example: "John Doe" → "JD"
  String getInitials({int maxInitials = 2}) {
    return split(' ')
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  /// Check if string is only special characters
  bool isOnlySpecialCharacters() {
    return RegExp(r'^[!@#$%^&*()_+\-=\[\]{};\':"\\|,.<>\/?]+$').hasMatch(this);
  }

  /// Limit string lines
  /// Example: "line1\nline2\nline3".limitLines(2) → "line1\nline2"
  String limitLines(int maxLines) {
    final lines = split('\n');
    return lines.take(maxLines).join('\n');
  }
}
