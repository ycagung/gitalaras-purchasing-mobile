import 'package:equatable/equatable.dart';
import 'package:gspro/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final bool isInitial;
  const AuthLoading({this.isInitial = false});

  @override
  List<Object?> get props => [isInitial];
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;
  final String sessionId;
  final String userId;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
    required this.sessionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [user, accessToken, sessionId, userId];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

