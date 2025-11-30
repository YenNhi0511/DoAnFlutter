class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({this.message = 'Server error', this.code});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({this.message = 'Authentication error', this.code});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({this.message = 'Validation error'});

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({this.message = 'Not found'});

  @override
  String toString() => 'NotFoundException: $message';
}

