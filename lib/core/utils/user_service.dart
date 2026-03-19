import 'package:shared_preferences/shared_preferences.dart';
import 'package:saluun_frontend/core/constants/app_constants.dart';
import 'package:saluun_frontend/data/models/api_models.dart';
import 'package:saluun_frontend/core/utils/token_service.dart';

/// Service to manage user data locally and in memory
class UserService {
  late SharedPreferences _prefs;
  User? _currentUser;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserFromStorage();
  }

  /// Load user from local storage
  void _loadUserFromStorage() {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        // Simple JSON string storage
        _currentUser = User.fromJson({
          // Parse the stored user data
          'id': _prefs.getString('${AppConstants.userKey}_id') ?? '',
          'name': _prefs.getString('${AppConstants.userKey}_name') ?? '',
          'email': _prefs.getString('${AppConstants.userKey}_email') ?? '',
          'phone': _prefs.getString('${AppConstants.userKey}_phone'),
          'profileImage': _prefs.getString(
            '${AppConstants.userKey}_profileImage',
          ),
          'role': _prefs.getString('${AppConstants.userKey}_role'),
          'createdAt':
              _prefs.getString('${AppConstants.userKey}_createdAt') ??
              DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Error loading user from storage: $e');
      }
    }
  }

  /// Save user
  Future<void> saveUser(User user) async {
    _currentUser = user;
    await _prefs.setString('${AppConstants.userKey}_id', user.id);
    await _prefs.setString('${AppConstants.userKey}_name', user.name);
    await _prefs.setString('${AppConstants.userKey}_email', user.email);
    if (user.phone != null) {
      await _prefs.setString('${AppConstants.userKey}_phone', user.phone!);
    }
    if (user.profileImage != null) {
      await _prefs.setString(
        '${AppConstants.userKey}_profileImage',
        user.profileImage!,
      );
    }
    if (user.role != null) {
      await _prefs.setString('${AppConstants.userKey}_role', user.role!);
    }
    await _prefs.setString(
      '${AppConstants.userKey}_createdAt',
      user.createdAt.toIso8601String(),
    );
  }

  /// Get current user
  User? getCurrentUser() {
    return _currentUser;
  }

  /// Clear user
  Future<void> clearUser() async {
    _currentUser = null;
    await _prefs.remove(AppConstants.userKey);
    await _prefs.remove('${AppConstants.userKey}_id');
    await _prefs.remove('${AppConstants.userKey}_name');
    await _prefs.remove('${AppConstants.userKey}_email');
    await _prefs.remove('${AppConstants.userKey}_phone');
    await _prefs.remove('${AppConstants.userKey}_profileImage');
    await _prefs.remove('${AppConstants.userKey}_role');
    await _prefs.remove('${AppConstants.userKey}_createdAt');
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _currentUser != null && tokenService.isLoggedIn();
  }
}

/// Singleton instance
final userService = UserService();
