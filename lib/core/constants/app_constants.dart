/// Centralized application constants
///
/// This class contains all app-wide constants organized by category.
/// Keep this file DRY - avoid duplicating values elsewhere.
class AppConstants {
  // ============================================================================
  // APP INFO & METADATA
  // ============================================================================

  static const String appName = 'Saluun';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your personal salon booking assistant';
  static const String developerName = 'Saluun Team';

  // ============================================================================
  // API CONFIGURATION
  // ============================================================================

  /// Backend API Base URL
  /// Development: http://10.21.87.95:5000/api or http://localhost:5000/api
  /// Production: https://api.saluun.com
  static const String apiBaseUrl = 'http://10.21.87.95:5000/api';

  /// API Communication Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// API Headers
  static const String contentType = 'application/json';
  static const String userAgent = 'Saluun/1.0.0';

  // ============================================================================
  // API ENDPOINTS
  // ============================================================================

  // Auth Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  // User Endpoints
  static const String userProfile = '/user/profile';
  static const String userUpdate = '/user/profile';
  static const String userChangePassword = '/user/change-password';
  static const String userAvatar = '/user/avatar';

  // Salon Endpoints
  static const String salons = '/salons';
  static const String salonDetails = '/salons/:id';
  static const String salonSearch = '/salons/search';
  static const String salonSlots = '/salons/:id/slots';
  static const String salonRatings = '/salons/:id/ratings';

  // Service Endpoints
  static const String services = '/services';
  static const String serviceDetails = '/services/:id';
  static const String salonServices = '/services/salon/:salonId';

  // Booking Endpoints
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookings/:bookingId';
  static const String bookingCancel = '/bookings/:bookingId/cancel';
  static const String bookingReschedule = '/bookings/:bookingId/reschedule';
  static const String bookingMyBookings = '/bookings/my-bookings';
  static const String bookingComplete = '/bookings/:bookingId/complete';

  // Rating Endpoints
  static const String ratings = '/ratings';
  static const String ratingCreate = '/ratings';
  static const String ratingUpdate = '/ratings/:id';

  // ============================================================================
  // STORAGE KEYS
  // ============================================================================

  // Token & Auth Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String isLoggedInKey = 'is_logged_in';

  // User Data Keys
  static const String userKey = 'user_data';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userPhoneKey = 'user_phone';

  // App Preference Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String analyticsKey = 'analytics_enabled';
  static const String firstLaunchKey = 'first_launch';

  // ============================================================================
  // JWT & AUTHENTICATION
  // ============================================================================

  static const String jwtAuthHeader = 'Authorization';
  static const String jwtBearerPrefix = 'Bearer ';
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // ============================================================================
  // PAGINATION & LIMITS
  // ============================================================================

  static const int pageSize = 20;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);

  // ============================================================================
  // DISPLAY FORMATS & STRINGS
  // ============================================================================

  // Date & Time Formats
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatLong = 'EEEE, MMMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeZoneFormat = 'HH:mm z';

  // UI Strings
  static const String buttonLoadingText = 'Processing...';
  static const String buttonRetryText = 'Retry';
  static const String buttonCancelText = 'Cancel';
  static const String buttonConfirmText = 'Confirm';
  static const String buttonSaveText = 'Save';
  static const String buttonDeleteText = 'Delete';

  // Error Messages
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'Unauthorized. Please login again.';
  static const String errorForbidden =
      'You do not have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation =
      'Please check your input and try again.';
  static const String errorUnknown =
      'An unknown error occurred. Please try again.';

  // Success Messages
  static const String successSaved = 'Saved successfully!';
  static const String successDeleted = 'Deleted successfully!';
  static const String successUpdated = 'Updated successfully!';
  static const String successLogout = 'Logged out successfully!';
  static const String successBooked = 'Booking confirmed!';

  // ============================================================================
  // NUMERIC CONSTANTS
  // ============================================================================

  // Rating
  static const double minRating = 0.0;
  static const double maxRating = 5.0;

  // Price
  static const double minPrice = 0.0;

  // Durations (in minutes)
  static const int minBookingDuration = 15;
  static const int maxBookingDuration = 480; // 8 hours

  // Search & Filtering
  static const int minSearchLength = 2;
  static const int maxSearchLength = 100;
  static const int maxFilters = 10;

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableOfflineMode = true;
  static const bool enableSocialAuth = false;
  static const bool enableLocationServices = true;
}
