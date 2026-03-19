import 'package:saluun_frontend/domain/entities/user_entity.dart';

/// UI State for Authentication
///
/// Represents the complete state of authentication UI including loading,
/// user data, and error states. This model bridges the domain layer (UserEntity)
/// with the presentation layer (screens/widgets).
class AuthUiState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  const AuthUiState({this.isLoading = false, this.user, this.errorMessage});

  /// Create a loading state
  factory AuthUiState.loading() {
    return const AuthUiState(isLoading: true);
  }

  /// Create a success state with user data
  factory AuthUiState.success(UserEntity user) {
    return AuthUiState(user: user, isLoading: false);
  }

  /// Create an error state
  factory AuthUiState.error(String message) {
    return AuthUiState(errorMessage: message, isLoading: false);
  }

  /// Create an initial/empty state
  factory AuthUiState.initial() {
    return const AuthUiState();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => user != null;

  /// Copy with convenience method
  AuthUiState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthUiState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'AuthUiState(isLoading: $isLoading, user: ${user?.email}, errorMessage: $errorMessage)';
}
