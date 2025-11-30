import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.code});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure(message: 'No user found with this email');
      case 'wrong-password':
        return const AuthFailure(message: 'Wrong password');
      case 'email-already-in-use':
        return const AuthFailure(message: 'Email is already in use');
      case 'weak-password':
        return const AuthFailure(message: 'Password is too weak');
      case 'invalid-email':
        return const AuthFailure(message: 'Invalid email address');
      case 'user-disabled':
        return const AuthFailure(message: 'This account has been disabled');
      case 'too-many-requests':
        return const AuthFailure(message: 'Too many attempts. Please try again later');
      default:
        return AuthFailure(message: 'Authentication failed: $code');
    }
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed', super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found', super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied', super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred', super.code});
}

