/// Exception thrown when a server error occurs
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

/// Exception thrown when a cache operation fails
class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

/// Exception thrown when a network error occurs
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);
}

/// Exception thrown when authentication fails
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);
}
