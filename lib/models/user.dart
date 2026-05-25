import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final int? oldId;
  final DateTime? createdAt;
  final String? createdBy;
  final String email;
  final String? username;
  final String password;
  final String? name;
  final String? avatar;
  final String? employeeId;
  final String? departmentId;
  final int? approvalScore;
  final String? roleId;

  const User({
    required this.id,
    this.oldId,
    this.createdAt,
    this.createdBy,
    required this.email,
    this.username,
    required this.password,
    this.name,
    this.avatar,
    this.employeeId,
    this.departmentId,
    this.approvalScore,
    this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle multiple possible field name variations
    final name = json['name'] as String? ??
        json['userName'] as String? ??
        json['user_name'] as String?;
    final avatar = json['avatar'] as String? ??
        json['avatarUrl'] as String? ??
        json['avatar_url'] as String?;

    return User(
      id: json['id'] as String,
      oldId: json['old_id'] as int? ?? json['oldId'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      createdBy: json['created_by'] as String? ?? json['createdBy'] as String?,
      email: json['email'] as String,
      username: json['username'] as String? ?? json['userName'] as String?,
      password: json['password'] as String? ?? '', // Password may not be in response
      name: name,
      avatar: avatar,
      employeeId: json['employee_id'] as String? ??
          json['employeeId'] as String?,
      departmentId: json['department_id'] as String? ??
          json['departmentId'] as String?,
      approvalScore: json['approval_score'] as int? ??
          json['approvalScore'] as int?,
      roleId: json['role_id'] as String? ?? json['roleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'old_id': oldId,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'email': email,
      'username': username,
      'password': password,
      'name': name,
      'avatar': avatar,
      'employee_id': employeeId,
      'department_id': departmentId,
      'approval_score': approvalScore,
      'role_id': roleId,
    };
  }

  User copyWith({
    String? id,
    int? oldId,
    DateTime? createdAt,
    String? createdBy,
    String? email,
    String? username,
    String? password,
    String? name,
    String? avatar,
    String? employeeId,
    String? departmentId,
    int? approvalScore,
    String? roleId,
  }) {
    return User(
      id: id ?? this.id,
      oldId: oldId ?? this.oldId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      employeeId: employeeId ?? this.employeeId,
      departmentId: departmentId ?? this.departmentId,
      approvalScore: approvalScore ?? this.approvalScore,
      roleId: roleId ?? this.roleId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        oldId,
        createdAt,
        createdBy,
        email,
        username,
        password,
        name,
        avatar,
        employeeId,
        departmentId,
        approvalScore,
        roleId,
      ];
}

