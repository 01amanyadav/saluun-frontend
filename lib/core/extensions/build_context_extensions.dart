/// BuildContext Extension Utilities
///
/// Provides helpful extension methods for navigation and accessing common resources.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtensions on BuildContext {
  // ============================================================================
  // NAVIGATION HELPERS
  // ============================================================================

  /// Navigate to a named route
  /// Example: context.goNamed('home')
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) => GoRouter.of(this).goNamed(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  /// Navigate to a route path
  /// Example: context.go('/home')
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Push current route to navigation stack
  /// Example: context.push('/home')
  Future<T?> push<T>(String location, {Object? extra}) =>
      GoRouter.of(this).push<T>(location, extra: extra);

  /// Push named route to navigation stack
  /// Example: context.pushNamed('home')
  Future<T?> pushNamed<T>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) => GoRouter.of(this).pushNamed<T>(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  /// Pop current route
  /// Example: context.pop()
  void pop<T>([T? result]) => GoRouter.of(this).pop(result);

  /// Pop until a named route
  /// Example: context.popUntil('home')
  void popUntilNamed(String name) {
    while (GoRouter.of(this).canPop() &&
        GoRouter.of(this).routeInformationProvider.value.uri.path != name) {
      pop();
    }
  }

  /// Check if can pop
  bool get canPop => GoRouter.of(this).canPop();

  // ============================================================================
  // THEME & STYLING HELPERS
  // ============================================================================

  /// Get app's theme data
  ThemeData get theme => Theme.of(this);

  /// Get app's color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get primary color
  Color get primaryColor => colorScheme.primary;

  /// Get secondary color
  Color get secondaryColor => colorScheme.secondary;

  /// Get tertiary color
  Color get tertiaryColor => colorScheme.tertiary;

  /// Get error color
  Color get errorColor => colorScheme.error;

  /// Get surface color
  Color get surfaceColor => colorScheme.surface;

  /// Get background color
  Color get backgroundColor => colorScheme.background;

  /// Get app's text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get display large text style
  TextStyle? get displayLarge => textTheme.displayLarge;

  /// Get display medium text style
  TextStyle? get displayMedium => textTheme.displayMedium;

  /// Get headline large text style
  TextStyle? get headlineLarge => textTheme.headlineLarge;

  /// Get title large text style
  TextStyle? get titleLarge => textTheme.titleLarge;

  /// Get title medium text style
  TextStyle? get titleMedium => textTheme.titleMedium;

  /// Get body large text style
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  /// Get body medium text style
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  /// Get body small text style
  TextStyle? get bodySmall => textTheme.bodySmall;

  // ============================================================================
  // DEVICE & SCREEN HELPERS
  // ============================================================================

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get device padding (for notch/safe area)
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Get device view insets (for keyboards)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Check if device is in portrait mode
  bool get isPortrait => screenSize.height > screenSize.width;

  /// Check if device is in landscape mode
  bool get isLandscape => screenSize.width > screenSize.height;

  /// Check if screen is small (width < 480)
  bool get isSmallScreen => screenWidth < 480;

  /// Check if screen is medium (width 480-960)
  bool get isMediumScreen => screenWidth >= 480 && screenWidth < 960;

  /// Check if screen is large (width >= 960)
  bool get isLargeScreen => screenWidth >= 960;

  /// Get device pixel ratio
  double get deviceRatio => MediaQuery.of(this).devicePixelRatio;

  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Get status bar height
  double get statusBarHeight => padding.top;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ============================================================================
  // DIALOG & SNACKBAR HELPERS
  // ============================================================================

  /// Show simple snackbar
  /// Example: context.showSnackBar('Message')
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xFF333333),
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Hide current snackbar
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  /// Show simple confirmation dialog
  /// Returns true if confirmed, false if cancelled
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool confirmIsDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: this,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: confirmIsDestructive
                      ? Colors.red
                      : primaryColor,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show loading dialog with message
  void showLoadingDialog({String message = 'Loading...'}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Close any open dialog
  void closeDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  // ============================================================================
  // FOCUS & KEYBOARD HELPERS
  // ============================================================================

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Request focus for a node
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  /// Get current focus
  FocusNode? get currentFocus => FocusScope.of(this).focusedChild;
}
