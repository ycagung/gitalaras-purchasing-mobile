import 'package:equatable/equatable.dart';
import 'package:gspro/models/requisition_approver.dart';

class OrderApprover extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String orderId;
  final String approverId;
  final int score;
  final bool? approved;
  final ApproverInfo? approver;

  const OrderApprover({
    required this.id,
    this.createdAt,
    required this.orderId,
    required this.approverId,
    required this.score,
    this.approved,
    this.approver,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _parseNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  factory OrderApprover.fromJson(Map<String, dynamic> json) {
    return OrderApprover(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      orderId:
          json['order_id']?.toString() ?? json['orderId']?.toString() ?? '',
      approverId:
          json['approver_id']?.toString() ??
          json['approverId']?.toString() ??
          '',
      score: _parseInt(json['score']) ?? 0,
      approved: _parseNullableBool(json['approved']),
      approver: json['approver'] != null
          ? ApproverInfo.fromJson(json['approver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'order_id': orderId,
      'approver_id': approverId,
      'score': score,
      'approved': approved,
      'approver': approver?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    orderId,
    approverId,
    score,
    approved,
    approver,
  ];
}
