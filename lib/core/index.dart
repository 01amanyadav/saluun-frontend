/// Core Utilities Barrel Export
///
/// This file exports all core utilities for easy importing.
/// Instead of: import 'package:saluun_frontend/core/utils/logger.dart';
/// Use: import 'package:saluun_frontend/core/index.dart';

// Utils
export 'utils/app_initialization.dart';
export 'utils/logger.dart';
export 'utils/token_service.dart';
export 'utils/user_service.dart';

// Constants
export 'constants/app_constants.dart';

// Network
export 'network/network_result.dart';
export 'network/dio_client.dart';

// Exceptions
export 'exceptions/app_exceptions.dart';

// Auth
export 'auth/auth_manager.dart';

// Theme
export 'theme/app_theme.dart';

// Extensions
export 'extensions/string_extensions.dart';
export 'extensions/datetime_extensions.dart';
export 'extensions/build_context_extensions.dart';
export 'extensions/widget_extensions.dart';
export 'extensions/number_extensions.dart';
