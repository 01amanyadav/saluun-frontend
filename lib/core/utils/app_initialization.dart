import 'package:saluun_frontend/core/utils/token_service.dart';
import 'package:saluun_frontend/core/utils/user_service.dart';

/// Service to initialize the application
class AppInitializationService {
  static Future<void> initialize() async {
    // Initialize token service
    await tokenService.init();

    // Initialize user service
    await userService.init();

    print('✅ App initialization complete');
  }
}
