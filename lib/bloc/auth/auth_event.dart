import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
}

class AuthUserLoaded extends AuthEvent {
  final String userId;

  const AuthUserLoaded({required this.userId});

  @override
  List<Object?> get props => [userId];
}

