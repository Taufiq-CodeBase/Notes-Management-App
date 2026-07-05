import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication required']);
}

class ValidationFailure extends Failure {
  final String field;

  const ValidationFailure({
    required this.field,
    String message = 'Validation error',
  }) : super(message);

  @override
  List<Object?> get props => [field, message];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}