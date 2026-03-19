/// Network Result - Generic State Wrapper for API Responses
///
/// Represents the state of an API operation:
/// - Success: Data loaded successfully
/// - Error: Operation failed with error message
/// - Loading: Operation in progress
///
/// Usage:
/// ```dart
/// final result = await repository.fetchSalons();
/// result.when(
///   success: (data) => print('Salons: $data'),
///   error: (message) => print('Error: $message'),
///   loading: () => print('Loading...'),
/// );
/// ```

sealed class NetworkResult<T> {
  const NetworkResult();

  /// Execute function based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) error,
    required R Function() loading,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Error<T>(message: final message) => error(message),
      Loading<T>() => loading(),
    };
  }

  /// Execute function based on result type (with null return)
  void whenOrNull({
    void Function(T data)? success,
    void Function(String message)? error,
    void Function()? loading,
  }) {
    switch (this) {
      case Success<T>(data: final data):
        success?.call(data);
      case Error<T>(message: final message):
        error?.call(message);
      case Loading<T>():
        loading?.call();
    }
  }

  /// Map result to another type
  NetworkResult<R> map<R>({
    required R Function(T data) success,
    required NetworkResult<R> Function(String message) error,
    required NetworkResult<R> Function() loading,
  }) {
    return switch (this) {
      Success<T>(data: final data) => Success(success(data)),
      Error<T>(message: final message) => error(message),
      Loading<T>() => loading(),
    };
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is error
  bool get isError => this is Error<T>;

  /// Check if result is loading
  bool get isLoading => this is Loading<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Get error message if error, null otherwise
  String? get errorOrNull =>
      this is Error<T> ? (this as Error<T>).message : null;

  /// Get data or throw exception
  T get dataOrThrow {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    throw Exception(errorOrNull ?? 'No data available');
  }
}

/// Success state with data
final class Success<T> extends NetworkResult<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Error state with message
final class Error<T> extends NetworkResult<T> {
  final String message;

  const Error(this.message);

  @override
  String toString() => 'Error(message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Loading state
final class Loading<T> extends NetworkResult<T> {
  const Loading();

  @override
  String toString() => 'Loading()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
