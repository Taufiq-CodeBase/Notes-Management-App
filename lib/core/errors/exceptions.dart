class ServerException implements Exception {
  final String message;
  final Object? cause;

  const ServerException([this.message = 'Server error', this.cause]);

  @override
  String toString() => 'ServerException($message)';
}

class AuthException implements Exception {
  final String message;
  final Object? cause;

  const AuthException([this.message = 'Authentication failed', this.cause]);

  @override
  String toString() => 'AuthException($message)';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException($message)';
}