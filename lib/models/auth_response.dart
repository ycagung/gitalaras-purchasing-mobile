import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String accessToken;
  final String sessionId;
  final String userId;

  const LoginResponse({
    required this.accessToken,
    required this.sessionId,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
    );
  }

  @override
  List<Object?> get props => [accessToken, sessionId, userId];
}

class RefreshResponse extends Equatable {
  final String accessToken;
  final String deviceType;

  const RefreshResponse({
    required this.accessToken,
    this.deviceType = '',
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      accessToken: json['accessToken'] as String,
      deviceType: json['deviceType']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [accessToken, deviceType];
}

