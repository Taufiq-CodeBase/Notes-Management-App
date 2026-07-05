import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticating extends AuthState {
  const Authenticating();
}

class Authenticated extends AuthState {
  final String uid;

  const Authenticated(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AuthFailed extends AuthState {
  final String message;

  const AuthFailed(this.message);

  @override
  List<Object?> get props => [message];
}