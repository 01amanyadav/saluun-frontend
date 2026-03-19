/// Exceptions
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException(super.message, {this.statusCode});
}

class AuthException extends AppException {
  AuthException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class StorageException extends AppException {
  StorageException(super.message);
}
