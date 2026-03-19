/// Quick Reference - Core Utilities Cheat Sheet
/// 
/// Fast lookup for all utilities without reading full documentation.

# Core Utilities - Quick Reference

## 📦 Complete File Structure

```
lib/core/
├── constants/
│   └── app_constants.dart          (50+ constants organized)
├── network/
│   ├── network_result.dart         (Success, Error, Loading)
│   └── dio_client.dart             (HTTP with interceptors)
├── extensions/
│   ├── string_extensions.dart      (19 string utilities)
│   ├── datetime_extensions.dart    (25 datetime utilities)
│   ├── number_extensions.dart      (20+ number utilities)
│   ├── build_context_extensions.dart (30 context utilities)
│   └── widget_extensions.dart      (35 widget utilities)
├── utils/
│   ├── logger.dart                 (Complete logging system)
│   ├── token_service.dart          (Secure storage)
│   ├── user_service.dart           (User management)
│   └── app_initialization.dart     (App setup)
├── exceptions/
│   └── app_exceptions.dart         (Custom exceptions)
├── auth/
│   └── auth_manager.dart           (Auth management)
├── theme/
│   └── app_theme.dart              (Theme definition)
└── index.dart                      (Barrel export ⭐)
```

## 💡 One-Line Imports

```dart
import 'package:saluun_frontend/core/index.dart';
// Now everything is available!
```

---

## 📝 String Extensions (19)

| Usage | Result |
|-------|--------|
| `'hello'.capitalize()` | `'Hello'` |
| `'hello world'.toTitleCase()` | `'Hello World'` |
| `'hello'.repeat(3)` | `'hellohellohello'` |
| `'hello world'.truncate(5)` | `'he...'` |
| `'hello'.getInitials()` | `'H'` |
| `'john doe'.getInitials(2)` | `'JD'` |
| `'Hello World'.toSlug()` | `'hello-world'` |
| `'123'.isNumeric()` | `true` |
| `'user@mail.com'.isValidEmail()` | `true` |
| `'1-800-123-4567'.isValidPhoneNumber()` | `true` |
| `'https://example.com'.isValidUrl()` | `true` |
| `'abc'.removeWhitespace()` | `'abc'` |
| `'<p>hi</p>'.removeHTMLTags()` | `'hi'` |
| `'123'.toIntOrNull()` | `123` |
| `'3.14'.toDoubleOrNull()` | `3.14` |
| `'hello'.reverse()` | `'olleh'` |
| `'abc'.equalsIgnoreCase('ABC')` | `true` |
| `'abc'.firstChar` | `'a'` |
| `'abc'.lastChar` | `'c'` |

---

## 📅 DateTime Extensions (25)

| Usage | Result |
|-------|--------|
| `DateTime.now().toReadable()` | `'Monday, March 18, 2026'` |
| `DateTime.now().timeOnly()` | `'14:30'` |
| `DateTime.now().toShortDate()` | `'18/03/2026'` |
| `DateTime.now().toLongDate()` | `'Monday, March 18, 2026'` |
| `DateTime.now().toTimeString()` | `'2:30 PM'` |
| `DateTime.now().timeAgo()` | `'2 hours ago'` |
| `DateTime.now().isToday` | `true` |
| `DateTime.now().isPast` | `false` |
| `DateTime.now().isFuture` | `true` |
| `DateTime.now().startOfDay` | `00:00:00` |
| `DateTime.now().endOfDay` | `23:59:59` |
| `DateTime.now().startOfMonth` | `1st of month` |
| `DateTime.now().endOfMonth` | `Last of month` |
| `DateTime.now().daysFromNow` | `0` |
| `DateTime(2026,3,20).daysFromNow` | `2` |

---

## 🔢 Number Extensions (20+)

| Usage | Result |
|-------|--------|
| `1234.5.formatCurrency()` | `'$1,234.50'` |
| `1000000.formatNumber()` | `'1,000,000'` |
| `0.75.toPercentage()` | `'75%'` |
| `1024.formatBytes()` | `'1.0 KB'` |
| `4.5.formatRating()` | `'4.5'` |
| `3661.formatDuration()` | `'1h 1m 1s'` |
| `100.increaseBy(10)` | `110` |
| `100.decreaseBy(20)` | `80` |
| `25.percentageOf(100)` | `25.0` |
| `50.isBetween(0, 100)` | `true` |
| `5.isPositive` | `true` |
| `-5.isNegative` | `true` |
| `0.isZero` | `true` |
| `4.isEven` | `true` |
| `5.isOdd` | `true` |
| `4.getOrdinalSuffix()` | `'4th'` |
| `3.14159.roundTo(2)` | `3.14` |

---

## 🎨 BuildContext Extensions (30)

| Category | Usage |
|----------|-------|
| **Navigation** | `context.go('/home')` |
| | `context.push('/profile')` |
| | `context.pop()` |
| | `context.goNamed('home')` |
| **Theming** | `context.primaryColor` |
| | `context.secondaryColor` |
| | `context.textTheme` |
| | `context.displayLarge` |
| **Screen Info** | `context.screenWidth` |
| | `context.screenHeight` |
| | `context.isPortrait` |
| | `context.isSmallScreen` |
| | `context.isKeyboardVisible` |
| **Dialogs** | `context.showSnackBar('Message')` |
| | `context.showSuccessSnackBar('Done!')` |
| | `context.showErrorSnackBar('Error')` |
| | `context.showConfirmDialog(...)` |
| | `context.showLoadingDialog()` |
| **Keyboard** | `context.hideKeyboard()` |

---

## 🎁 Widget Extensions (35)

| Usage | Effect |
|-------|--------|
| `.withPadding(all: 16)` | Add 16px padding all sides |
| `.withPadding(horizontal: 8, vertical: 4)` | Add symmetric padding |
| `.withMargin(all: 16)` | Add margin |
| `.withBackground(Colors.blue)` | Add background color |
| `.withBorder(color: Colors.black)` | Add border |
| `.withBorderRadius(16)` | Add border radius |
| `.withOpacity(0.5)` | Add opacity |
| `.center()` | Center widget |
| `.expanded()` | Fill available space |
| `.flexible()` | Make flexible |
| `.withSize(200, 100)` | Set fixed size |
| `.withWidth(200)` | Set width |
| `.withHeight(100)` | Set height |
| `.onTap(() => {...})` | Add tap gesture |
| `.onLongPress(() => {...})` | Add long press |
| `.withTooltip('Help text')` | Add tooltip |
| `.scrollable()` | Make scrollable |
| `.safeArea()` | Wrap in SafeArea |
| `.withElevation(8)` | Add shadow |
| `.withGradient([Colors.blue, Colors.red])` | Add gradient |
| `.rotate(45)` | Rotate 45 degrees |
| `.scale(1.5)` | Scale up |
| `.visibility(isVisible: true)` | Conditional show |
| `.withRipple(onTap: () => {...})` | Add ripple effect |
| **Shortcuts** | |
| `.withLargePadding()` | 24px padding (all) |
| `.withMediumPadding()` | 16px padding (all) |
| `.withSmallPadding()` | 8px padding (all) |

---

## 📊 Logger Methods (5+)

| Method | Usage |
|--------|-------|
| `Logger.debug(msg)` | Detailed debug info |
| `Logger.info(msg)` | Confirmation messages |
| `Logger.warning(msg)` | Potential issues |
| `Logger.error(msg, error: e)` | Serious problems |
| `Logger.fatal(msg)` | Critical errors |
| `Logger.network(endpoint, status: 200)` | Network calls |
| `Logger.database(query, duration: 50)` | DB operations |
| `Logger.performance(name, duration: 250)` | Performance metrics |
| `Logger.api(endpoint, data)` | API logging |
| `Logger.action(action)` | User actions |
| `Logger.lifecycle(event)` | App lifecycle |

**Performance Timer:**
```dart
final timer = Logger.startTimer('Task name');
// ... do work ...
timer.stop();  // Auto-logs: "Task name (245ms)"
```

---

## 🔒 NetworkResult Usage

```dart
// Create
final result = Success(data);
final result = Error('Error message');
final result = Loading<T>();

// Pattern match
result.when(
  success: (data) => ...,
  error: (msg) => ...,
  loading: () => ...,
);

// Get data
final data = result.dataOrNull;     // null if not success
final error = result.errorOrNull;   // null if not error

// Check state
result.isSuccess   // true if Success
result.isError     // true if Error
result.isLoading   // true if Loading

// Map
final mapped = result.map(
  success: (d) => d.name,
  error: (m) => Error(m),
  loading: () => Loading(),
);
```

---

## ⚙️ AppConstants Categories (50+)

| Category | Examples |
|----------|----------|
| **App Info** | appName, appVersion, appDescription |
| **API Config** | apiBaseUrl, apiTimeout, contentType |
| **API Endpoints** | authLogin, authRegister, userProfile, salons, bookings |
| **Storage Keys** | accessTokenKey, userKey, themeKey |
| **JWT** | jwtAuthHeader, jwtBearerPrefix |
| **Formats** | dateFormatShort, timeFormat, dateTimeFormat |
| **Error Messages** | errorNetwork, errorTimeout, errorServer |
| **Success Messages** | successSaved, successDeleted, successLogout |
| **Numeric Limits** | minRating, maxRating, minPrice, maxRetries |
| **Feature Flags** | enableAnalytics, enableOfflineMode |

---

## 🚀 Common Patterns

### Validate Email & Show Error
```dart
if (!email.isValidEmail()) {
  context.showErrorSnackBar('Invalid email');
  return;
}
```

### Format & Display Booking Date
```dart
final dateText = booking.date.toReadable();
final timeAgo = booking.createdAt.timeAgo();
print('Booked on $dateText, $timeAgo');
```

### Handle API Result
```dart
final result = await repo.fetchData();
result.when(
  success: (data) => setState(() => this.data = data),
  error: (msg) => context.showErrorSnackBar(msg),
  loading: () => showLoader(),
);
```

### Build UI with Extensions
```dart
Text('Title')
  .withLargePadding()
  .withBackground(Colors.blue)
  .withBorderRadius(12)
  .onTap(onTap)
```

### Monitor Performance
```dart
final timer = Logger.startTimer('Image processing');
// ... process image ...
timer.stop();  // Logs duration automatically
```

---

## 📈 Extension Chaining

All extensions can be chained together:

```dart
Text('Hello')
  .withPadding(all: 16)
  .withBackground(Colors.blue)
  .withBorderRadius(12)
  .withShadow()
  .onTap(() => print('Tapped'))
  .safeArea()
  .center()
```

---

## 🧪 Testing Quick Tips

```dart
test('string capitalize', () {
  expect('hello'.capitalize(), 'Hello');
});

test('datetime formatting', () {
  final date = DateTime(2026, 3, 18);
  expect(date.toShortDate(), '18/03/2026');
});

test('number formatting', () {
  expect(1234.5.formatCurrency(), '\$1,234.50');
});
```

---

## ⚡ Performance Notes

- **Extensions**: Zero overhead (compile-time)
- **Logger**: Disabled in release mode automatically
- **NetworkResult**: Tiny memory footprint
- **Constants**: Evaluated at compile-time
- **All utilities**: Stateless, no side effects

---

**Last Updated**: March 18, 2026  
**Version**: 1.0.0
