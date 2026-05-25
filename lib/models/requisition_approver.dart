import 'package:equatable/equatable.dart';

class ApproverInfo extends Equatable {
  final String? name;
  final String email;

  const ApproverInfo({this.name, required this.email});

  factory ApproverInfo.fromJson(Map<String, dynamic> json) {
    return ApproverInfo(
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }

  @override
  List<Object?> get props => [name, email];
}

class RequisitionApprover extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String requisitionId;
  final String approverId;
  final int score;
  final bool? approved;
  final ApproverInfo? approver;

  const RequisitionApprover({
    required this.id,
    this.createdAt,
    required this.requisitionId,
    required this.approverId,
    required this.score,
    this.approved,
    this.approver,
  });

  // Helper method to safely parse DateTime from string
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

  // Helper method to safely parse int from string or int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  // Helper method to safely parse nullable bool
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

  factory RequisitionApprover.fromJson(Map<String, dynamic> json) {
    return RequisitionApprover(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      requisitionId:
          json['requisition_id']?.toString() ??
          json['requisitionId']?.toString() ??
          '',
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
      'requisition_id': requisitionId,
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
    requisitionId,
    approverId,
    score,
    approved,
    approver,
  ];
}
