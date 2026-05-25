import 'package:equatable/equatable.dart';

class Requisition extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String number;
  final String? requesterId;
  final String? requesterName;
  final String requestDate;
  final String? departmentId;
  final String? department;
  final String? priority;
  final String? purpose;
  final String? projectNumber;
  final String? projectName;
  final int? deliveryPointId;
  final String? requiredDate;
  final String? remarks;
  final int statusId;
  final String? category;
  final bool approved;
  final String? dueDate;
  final int? approvalCount;
  final num? approvalScore;

  const Requisition({
    required this.id,
    this.createdAt,
    this.createdBy,
    required this.number,
    this.requesterId,
    this.requesterName,
    required this.requestDate,
    this.departmentId,
    this.department,
    this.priority,
    this.purpose,
    this.projectNumber,
    this.projectName,
    this.deliveryPointId,
    this.requiredDate,
    this.remarks,
    required this.statusId,
    this.category,
    required this.approved,
    this.dueDate,
    this.approvalCount,
    this.approvalScore,
  });

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

  // Helper method to safely parse bool from string or bool
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

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

  // Helper method to safely parse num from string or num
  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return num.tryParse(value);
    }
    return null;
  }

  factory Requisition.fromJson(Map<String, dynamic> json) {
    return Requisition(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      createdBy: json['created_by']?.toString(),
      number: json['number']?.toString() ?? '',
      requesterId: json['requester_id']?.toString(),
      requesterName: json['requester_name']?.toString(),
      requestDate: json['requestDate']?.toString() ?? '',
      departmentId: json['department_id']?.toString(),
      department: json['department']?.toString(),
      priority: json['priority']?.toString(),
      purpose: json['purpose']?.toString(),
      projectNumber: json['project_number']?.toString(),
      projectName: json['project_name']?.toString(),
      deliveryPointId: _parseInt(json['delivery_point_id']),
      requiredDate: json['required_date']?.toString(),
      remarks: json['remarks']?.toString(),
      statusId:
          _parseInt(json['status']) ??
          _parseInt(json['statusId']) ??
          _parseInt(json['status_id']) ??
          0,
      category: json['category']?.toString(),
      approved: _parseBool(json['approved'], defaultValue: false),
      dueDate: json['due_date']?.toString(),
      approvalCount:
          _parseInt(json['approvalCount']) ?? _parseInt(json['approval_count']),
      approvalScore:
          _parseNum(json['approvalScore']) ?? _parseNum(json['approval_score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'number': number,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requestDate': requestDate,
      'department_id': departmentId,
      'department': department,
      'priority': priority,
      'purpose': purpose,
      'project_number': projectNumber,
      'project_name': projectName,
      'delivery_point_id': deliveryPointId,
      'required_date': requiredDate,
      'remarks': remarks,
      'status': statusId,
      'category': category,
      'approved': approved,
      'due_date': dueDate,
      'approvalCount': approvalCount,
      'approvalScore': approvalScore,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdBy,
    number,
    requesterId,
    requesterName,
    requestDate,
    departmentId,
    department,
    priority,
    purpose,
    projectNumber,
    projectName,
    deliveryPointId,
    requiredDate,
    remarks,
    statusId,
    category,
    approved,
    dueDate,
    approvalCount,
    approvalScore,
  ];
}
