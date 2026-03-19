/// CORE UTILITIES LAYER - Complete Usage Guide
/// 
/// This document explains all utilities in the core layer following Clean Architecture principles.

# Core Utilities Layer - Complete Guide

## 📋 Overview

The core utilities layer provides reusable, independent utilities that improve code quality and consistency across the app. These utilities have **zero dependency** on business logic or UI frameworks (except extensions).

## 🗂️ Directory Structure

```
lib/core/
├── constants/
│   └── app_constants.dart        # App-wide constants
├── network/
│   ├── network_result.dart       # Generic state wrapper
│   └── dio_client.dart           # HTTP client with interceptors
├── extensions/
│   ├── string_extensions.dart    # String utilities
│   ├── datetime_extensions.dart  # DateTime utilities
│   ├── number_extensions.dart    # Number utilities
│   ├── build_context_extensions.dart # BuildContext utilities
│   └── widget_extensions.dart    # Widget utilities
├── utils/
│   ├── logger.dart               # Logging utility
│   ├── token_service.dart        # Secure token storage
│   ├── user_service.dart         # User data management
│   └── app_initialization.dart   # App initialization
├── exceptions/
│   └── app_exceptions.dart       # Custom exceptions
├── auth/
│   └── auth_manager.dart         # Authentication management
├── theme/
│   └── app_theme.dart            # App theming
└── index.dart                    # Barrel export

```

---

## 1️⃣ NetworkResult - Generic State Wrapper

### Purpose
Represents the state of an API operation without throwing exceptions.

### States
- **Success<T>** - Operation successful with data
- **Error<T>** - Operation failed with error message
- **Loading<T>** - Operation in progress

### Usage Examples

```dart
// Import
import 'package:saluun_frontend/core/index.dart';

// Create success result
final result = Success<User>(user);

// Create error result
final result = Error<User>('Failed to load user');

// Create loading result
final result = Loading<User>();

// Pattern match with when()
result.when(
  success: (user) => print('User: ${user.name}'),
  error: (message) => print('Error: $message'),
  loading: () => print('Loading...'),
);

// Get data directly
final user = result.dataOrNull;    // null if not success
final error = result.errorOrNull;  // null if not error

// Check state
if (result.isSuccess) { /* ... */ }
if (result.isError) { /* ... */ }
if (result.isLoading) { /* ... */ }

// Map to another type
final nameResult = result.map(
  success: (user) => user.name,
  error: (msg) => Error(msg),
  loading: () => Loading(),
);
```

### In Repositories

```dart
class UserRepository {
  Future<NetworkResult<User>> getUser(String id) async {
    try {
      final response = await dioClient.get('/users/$id');
      return Success(User.fromJson(response.data));
    } on DioException catch (e) {
      return Error('Failed to fetch user: ${e.message}');
    } catch (e) {
      return Error('Unknown error occurred');
    }
  }
}
```

### In ViewModels with Riverpod

```dart
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  final result = await repository.getUser('123');
  
  return result.when(
    success: (user) => user,
    error: (msg) {
      ref.read(authErrorProvider.notifier).state = msg;
      throw Exception(msg);
    },
    loading: () => throw Exception('Loading'),
  );
});
```

---

## 2️⃣ Constants - Centralized Configuration

### Purpose
Single source of truth for all app-wide constants.

### Usage Examples

```dart
import 'package:saluun_frontend/core/index.dart';

// API Configuration
final baseUrl = AppConstants.apiBaseUrl;
final timeout = AppConstants.apiTimeout;

// API Endpoints
final endpoint = AppConstants.userProfile;

// Storage Keys
TokenService.saveToken(token); // Uses appConstants.accessTokenKey

// Display Strings
showErrorDialog(AppConstants.errorNetwork);

// Pagination
List items = List.generate(AppConstants.pageSize, ...);

// Numeric Constants
if (rating.isBetween(AppConstants.minRating, AppConstants.maxRating)) {
  // Valid rating
}
```

### Adding New Constants

When adding new constants, group them by category:

```dart
class AppConstants {
  // ============================================================================
  // NEW FEATURE CONSTANTS
  // ============================================================================

  static const String newFeatureEnabled = true;
  static const int maxItems = 50;
  static const String defaultText = 'Hello';
}
```

---

## 3️⃣ Extension Functions

### 3.1 String Extensions

```dart
import 'package:saluun_frontend/core/index.dart';

// Capitalize
'hello'.capitalize()              // → 'Hello'
'hello world'.toTitleCase()       // → 'Hello World'

// Validation
'user@example.com'.isValidEmail()         // → true
'1-234-567-8900'.isValidPhoneNumber()     // → true
'https://example.com'.isValidUrl()        // → true

// Manipulation
'hello world'.truncate(5)         // → 'he...'
'<p>hello</p>'.removeHTMLTags()   // → 'hello'
'hello'.repeat(3)                 // → 'hellohellohello'

// Formatting
'hello'.getInitials()             // → 'H'
'john doe'.getInitials()          // → 'JD'
'Hello World'.toSlug()            // → 'hello-world'

// Conversion
'123'.toIntOrNull()               // → 123
'3.14'.toDoubleOrNull()           // → 3.14
```

### 3.2 DateTime Extensions

```dart
// Formatting
DateTime.now().toReadable()       // → 'Monday, March 18, 2026'
DateTime.now().timeOnly()         // → '14:30'
DateTime.now().toShortDate()      // → '18/03/2026'
DateTime.now().toLongDate()       // → 'Monday, March 18, 2026'
DateTime.now().timeAgo()          // → '2 hours ago'

// Checking
DateTime.now().isToday            // → true
DateTime.now().isPast             // → false
DateTime.now().isFuture           // → true

// Start/End of period
DateTime.now().startOfDay         // → 00:00:00
DateTime.now().endOfDay           // → 23:59:59
DateTime.now().startOfMonth       // → 1st of month
```

### 3.3 BuildContext Extensions

```dart
// Navigation
context.go('/home');
context.push('/profile');
context.pop();
context.showSnackBar('Success!');

// Theming
context.primaryColor              // → Theme's primary color
context.textTheme
context.displayLarge

// Screen Info
context.screenWidth               // → Screen width in pixels
context.isPortrait                // → Portrait mode?
context.isSmallScreen             // → Width < 480?
context.isKeyboardVisible         // → Is keyboard open?

// Dialogs
context.showConfirmDialog(
  title: 'Confirm',
  message: 'Are you sure?',
);
context.showLoadingDialog();
context.hideKeyboard();
```

### 3.4 Widget Extensions

```dart
// Padding & Margins
Text('Hello').withPadding(all: 16)
Text('Hello').withMargin(horizontal: 8, vertical: 12)

// Styling
Text('Hello').withBackground(Colors.blue)
Text('Hello').withBorder(color: Colors.black)
Text('Hello').withBorderRadius(16)
Text('Hello').withOpacity(0.5)

// Layout
Text('Hello').center()
Text('Hello').expanded()
Text('Hello').withSize(200, 100)

// Interaction
Text('Hello').onTap(() => print('Tapped'))
Text('Hello').withTooltip('Click me')

// Shortcuts
Text('Hello').withLargePadding()   // 24px padding
Text('Hello').withMediumPadding()  // 16px padding
Text('Hello').withSmallPadding()   // 8px padding
```

### 3.5 Number Extensions

```dart
// Formatting
1234.5.formatCurrency()           // → '$1,234.50'
1000000.formatNumber()            // → '1,000,000'
0.75.toPercentage()               // → '75%'
1024.formatBytes()                // → '1.0 KB'

// Checking
5.isPositive                       // → true
-5.isNegative                      // → true
0.isZero                           // → true
4.isEven                           // → true
5.isOdd                            // → true

// Calculation
25.percentageOf(100)              // → 25.0
100.increaseBy(10)                // → 110
100.decreaseBy(20)                // → 80
3661.formatDuration()             // → '1h 1m 1s'
```

---

## 4️⃣ Logger Utility

### Purpose
Centralized logging system that:
- Automatically disables in release mode
- Supports multiple log levels
- Includes timestamp and tags
- Provides performance monitoring

### Usage Examples

```dart
import 'package:saluun_frontend/core/index.dart';

// Basic logging
Logger.debug('User data loaded', tag: 'Auth');
Logger.info('App started');
Logger.warning('API response slow');
Logger.error('Failed to save data', error: exception);
Logger.fatal('Authentication failed');

// Network logging
Logger.network('GET /users', statusCode: 200, duration: 150);

// Database operations
Logger.database('Query executed', duration: 45);

// Performance monitoring
Logger.performance('Screen render', duration: 250);

// User actions
Logger.action('Button tapped', data: 'LoginButton');

// Lifecycle events
Logger.lifecycle('App resumed');

// Exception logging
Logger.logException(
  exception,
  context: 'During data fetch',
  stackTrace: stackTrace,
);
```

### Performance Timer

```dart
// Automatic timing
final timer = Logger.startTimer('Data processing');
// ... do work ...
timer.stop(); // Logs: [Performance] Data processing (245ms)

// With custom label
final timer = Logger.startTimer('Load');
// ... do work ...
timer.stop(customLabel: 'Data load complete'); // Logs with custom label

// Check elapsed time
if (timer.elapsed > 1000) {
  print('Took too long!');
}

// Check if exceeds threshold
if (timer.exceedsThreshold(500)) {
  Logger.warning('Operation took longer than expected');
}
```

### Configuration

```dart
// Disable logging (for sensitive operations)
Logger.setLoggingEnabled(false);

// Re-enable
Logger.setLoggingEnabled(true);

// Clear logs
Logger.clearLogs();

// Add separator for readability
Logger.separator();

// Dump object data
Logger.dump({'user': 'John', 'email': 'john@example.com'});
```

### Log Levels (with colors in output)
- **DEBUG** - [DEBUG] Detailed information
- **INFO** - [INFO] Confirmation messages
- **WARNING** - [WARNING] ⚠️ Potential issues
- **ERROR** - [ERROR] ❌ Serious problems
- **FATAL** - [FATAL] 🔴 Critical errors

---

## 🏗️ Architecture Best Practices

### ✅ DO

- Keep utilities independent and reusable
- Use logical grouping and organization
- Add constants instead of hardcoding values
- Log important operations for debugging
- Use extensions for common operations
- Document complex utilities

### ❌ DON'T

- Mix business logic with utilities
- Create circular dependencies
- Hardcode values (use constants instead)
- Excessive logging (degrades performance)
- Create overly broad extensions
- Ignore the Clean Architecture principles

---

## 📦 Importing Utilities

### Option 1: Import Individual Files
```dart
import 'package:saluun_frontend/core/utils/logger.dart';
import 'package:saluun_frontend/core/extensions/string_extensions.dart';
```

### Option 2: Import All (Recommended)
```dart
import 'package:saluun_frontend/core/index.dart';
```

### Option 3: Import Specific Categories
```dart
// Just extensions
import 'package:saluun_frontend/core/extensions/string_extensions.dart';
import 'package:saluun_frontend/core/extensions/datetime_extensions.dart';

// Just constants
import 'package:saluun_frontend/core/constants/app_constants.dart';
```

---

## 🧪 Testing Utilities

### Testing Extensions
```dart
test('String capitalization', () {
  expect('hello'.capitalize(), equals('Hello'));
  expect('hello world'.toTitleCase(), equals('Hello World'));
});

test('DateTime formatting', () {
  final date = DateTime(2026, 3, 18);
  expect(date.toShortDate(), equals('18/03/2026'));
});

test('Number formatting', () {
  expect(1234.5.formatCurrency(), equals('\$1,234.50'));
  expect(1000000.formatNumber(), equals('1,000,000'));
});
```

### Testing Logger
```dart
test('Logger should not throw', () {
  expect(() {
    Logger.debug('Test');
    Logger.info('Test');
    Logger.error('Test');
  }, returnsNormally);
});
```

---

## 🔄 Integration Examples

### Example 1: Complete User Loading Flow

```dart
class UserViewModel extends StateNotifier<UserState> {
  final UserRepository repository;

  Future<void> loadUser(String id) async {
    state = const UserState.loading();

    // Use logger to track operation
    final timer = Logger.startTimer('Load user');

    final result = await repository.getUser(id);

    timer.stop();

    result.when(
      success: (user) {
        Logger.info('User ${user.name} loaded successfully');
        state = UserState.success(user);
      },
      error: (message) {
        Logger.error('Failed to load user', error: message);
        state = UserState.error(message);
      },
      loading: () => state = const UserState.loading(),
    );
  }
}
```

### Example 2: Form Validation with Extensions

```dart
class LoginForm {
  bool validateEmail(String email) {
    if (!email.isValidEmail()) {
      Logger.warning('Invalid email: $email');
      return false;
    }
    return true;
  }

  bool validatePhone(String phone) {
    if (!phone.isValidPhoneNumber()) {
      Logger.warning('Invalid phone: $phone');
      return false;
    }
    return true;
  }
}
```

### Example 3: UI Building with Widget Extensions

```dart
Widget buildUserCard(User user) {
  return Container(
    child: Column(
      children: [
        Text(user.name).withLargePadding(),
        Text(user.email),
        ElevatedButton(
          onPressed: () => print('Tapped'),
          child: Text('View Profile'),
        ).withMediumPadding(),
      ],
    )
    .withBorder(color: Colors.grey)
    .withBorderRadius(12)
    .withMargin(all: 8),
  );
}
```

---

## 📊 Performance Considerations

- **Logger**: Automatically disabled in release mode
- **Extensions**: Zero runtime overhead
- **NetworkResult**: Minimal memory footprint
- **Constants**: Compile-time evaluation

---

## 🎯 Next Steps

1. **Use extensions** in UI code for cleaner widgets
2. **Use Logger** for debugging during development
3. **Use NetworkResult** in repositories for consistent error handling
4. **Add constants** instead of hardcoding values
5. **Expand utilities** as needed for your specific features

---

## 📞 Common Issues & Solutions

### Issue: Logger shows no output
**Solution**: Check if `kDebugMode` is true (automatic in debug builds)

### Issue: Extensions not available
**Solution**: Import `package:saluun_frontend/core/index.dart`

### Issue: Constants not updated in running app
**Solution**: Hot reload won't update constants; use hot restart

### Issue: NetworkResult is cluttering code
**Solution**: Use `when()` method for cleaner pattern matching

---

## 📚 Related Documentation

- [APP_INITIALIZATION_GUIDE.md](APP_INITIALIZATION_GUIDE.md) - App startup flow
- [AUTHENTICATION_SYSTEM.md](AUTHENTICATION_SYSTEM.md) - Auth implementation
- [AUTH_PATTERNS_AND_TROUBLESHOOTING.md](AUTH_PATTERNS_AND_TROUBLESHOOTING.md) - Common patterns

---

**Last Updated**: March 18, 2026  
**Version**: 1.0.0
