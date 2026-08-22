import 'package:equatable/equatable.dart';

class ProjectMemberRole extends Equatable {
  final String id;
  final String title;

  const ProjectMemberRole({required this.id, required this.title});

  factory ProjectMemberRole.fromJson(Map<String, dynamic> json) {
    return ProjectMemberRole(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title];
}

class ProjectMemberUser extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? employeeId;
  final ProjectMemberRole? role;

  const ProjectMemberUser({
    required this.id,
    this.name,
    required this.email,
    this.employeeId,
    this.role,
  });

  factory ProjectMemberUser.fromJson(Map<String, dynamic> json) {
    return ProjectMemberUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '',
      employeeId: json['employeeId']?.toString(),
      role: json['role'] != null
          ? ProjectMemberRole.fromJson(json['role'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, email, employeeId, role];
}

class ProjectMember extends Equatable {
  final int id;
  final int? sequence;
  final ProjectMemberUser user;

  const ProjectMember({required this.id, this.sequence, required this.user});

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sequence: json['sequence'] is int
          ? json['sequence'] as int
          : int.tryParse(json['sequence']?.toString() ?? ''),
      user: ProjectMemberUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [id, sequence, user];
}

class ProjectDetail extends Equatable {
  final String id;
  final String projectNumber;
  final String projectName;
  final List<ProjectMember> members;

  const ProjectDetail({
    required this.id,
    required this.projectNumber,
    required this.projectName,
    required this.members,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      id: json['id']?.toString() ?? '',
      projectNumber: json['projectNumber']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((m) => ProjectMember.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, projectNumber, projectName, members];
}
