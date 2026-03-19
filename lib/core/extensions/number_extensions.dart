/// Number Extension Utilities
///
/// Provides helpful extension methods for formatting and manipulating numbers.

extension NumberExtensions on num {
  /// Format number as currency
  /// Example: 1234.5.formatCurrency() → "$1,234.50"
  String formatCurrency({String symbol = '\$', int decimals = 2}) {
    final formatter = _NumberFormatter();
    return formatter.formatCurrency(this, symbol: symbol, decimals: decimals);
  }

  /// Format number with thousand separators
  /// Example: 1000000.formatNumber() → "1,000,000"
  String formatNumber({String separator = ','}) {
    return toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => separator,
    );
  }

  /// Convert to percentage string
  /// Example: 0.75.toPercentage() → "75%"
  String toPercentage({int decimals = 0}) {
    final value = this * 100;
    if (decimals == 0) {
      return '${value.toStringAsFixed(0)}%';
    }
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format bytes to readable size
  /// Example: 1024.formatBytes() → "1.0 KB"
  String formatBytes() {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var bytes = toDouble();
    var suffixIndex = 0;

    while (bytes >= 1024 && suffixIndex < suffixes.length - 1) {
      bytes /= 1024;
      suffixIndex++;
    }

    return '${bytes.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Clamp number between min and max
  /// Example: 50.clamp(0, 100) → 50
  num clamp(num minValue, num maxValue) {
    if (this < minValue) return minValue;
    if (this > maxValue) return maxValue;
    return this;
  }

  /// Get absolute value
  /// Example: (-5).abs() → 5
  num get absolute => this < 0 ? -this : this;

  /// Round to nearest integer
  int get roundToInt => round();

  /// Check if number is even
  bool get isEven => toInt() % 2 == 0;

  /// Check if number is odd
  bool get isOdd => toInt() % 2 != 0;

  /// Convert milliseconds to Duration
  /// Example: 5000.toDuration() → Duration(milliseconds: 5000)
  Duration toDuration() => Duration(milliseconds: toInt());

  /// Format number as rating (e.g., 4.5/5)
  /// Example: 4.5.formatRating() → "4.5"
  String formatRating({int decimals = 1}) {
    return toStringAsFixed(decimals);
  }

  /// Check if number is within range
  /// Example: 50.isBetween(0, 100) → true
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Get percentage of another number
  /// Example: 25.percentageOf(100) → 25.0
  double percentageOf(num other) {
    if (other == 0) return 0;
    return (this / other) * 100;
  }

  /// Increase by percentage
  /// Example: 100.increaseBy(10) → 110 (increase by 10%)
  num increaseBy(num percent) {
    return this + (this * percent / 100);
  }

  /// Decrease by percentage
  /// Example: 100.decreaseBy(10) → 90 (decrease by 10%)
  num decreaseBy(num percent) {
    return this - (this * percent / 100);
  }

  /// Format as duration in human-readable format
  /// Example: 3661.formatDuration() → "1h 1m 1s"
  String formatDuration() {
    final int seconds = toInt();
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    final List<String> parts = [];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (secs > 0 || parts.isEmpty) parts.add('${secs}s');

    return parts.join(' ');
  }
}

/// Internal formatter helper
class _NumberFormatter {
  /// Format number as currency
  String formatCurrency(num amount, {String symbol = '\$', int decimals = 2}) {
    final formatted = amount.toStringAsFixed(decimals);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final withSeparators = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    if (decimals > 0) {
      return '$symbol$withSeparators.$decimalPart';
    }
    return '$symbol$withSeparators';
  }
}

// For int type
extension IntExtensions on int {
  /// Format int with thousand separators
  String formatNumber({String separator = ','}) {
    return toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => separator,
    );
  }

  /// Check if int is even
  bool get isEven => this % 2 == 0;

  /// Check if int is odd
  bool get isOdd => this % 2 != 0;

  /// Get ordinal suffix (1st, 2nd, 3rd, etc.)
  String getOrdinalSuffix() {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Factorial
  int get factorial {
    if (this < 0) throw Exception('Factorial not defined for negative numbers');
    if (this == 0 || this == 1) return 1;
    return this * (this - 1).factorial;
  }

  /// Check if prime number
  bool get isPrime {
    if (this < 2) return false;
    if (this == 2) return true;
    if (isEven) return false;
    for (int i = 3; i * i <= this; i += 2) {
      if (this % i == 0) return false;
    }
    return true;
  }

  /// Check if perfect square
  bool get isPerfectSquare {
    if (this < 0) return false;
    final root = sqrt(toDouble()).toInt();
    return root * root == this;
  }
}

// For double type
extension DoubleExtensions on double {
  /// Check if double is integer value
  bool get isInteger => this == toInt();

  /// Round to specific decimal places
  /// Example: 3.14159.roundTo(2) → 3.14
  double roundTo(int decimals) {
    final multiplier = pow(10, decimals);
    return (this * multiplier).round() / multiplier;
  }

  /// Get square root
  double get squareRoot => sqrt(this);

  /// Check if approximately equal to another double
  bool approximatelyEquals(double other, {double epsilon = 0.0001}) {
    return (this - other).abs() < epsilon;
  }
}

/// Square root implementation
double sqrt(double x) {
  if (x < 0) throw Exception('Cannot calculate square root of negative number');
  if (x == 0) return 0;

  double guess = x / 2;
  double nextGuess = (guess + x / guess) / 2;

  while ((guess - nextGuess).abs() > 0.0001) {
    guess = nextGuess;
    nextGuess = (guess + x / guess) / 2;
  }

  return nextGuess;
}

/// Power function
num pow(num base, int exponent) {
  if (exponent == 0) return 1;
  if (exponent < 0) return 1 / pow(base, -exponent);

  num result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
