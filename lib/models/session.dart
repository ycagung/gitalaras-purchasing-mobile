import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? closedAt;
  final String userId;
  final String deviceId;
  final DateTime expiredAt;
  final bool valid;

  const Session({
    required this.id,
    this.createdAt,
    this.closedAt,
    required this.userId,
    required this.deviceId,
    required this.expiredAt,
    required this.valid,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      valid: json['valid'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'user_id': userId,
      'device_id': deviceId,
      'expired_at': expiredAt.toIso8601String(),
      'valid': valid,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, closedAt, userId, deviceId, expiredAt, valid];
}

