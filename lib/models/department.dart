import 'package:equatable/equatable.dart';

class Department extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String title;
  final String? description;

  const Department({
    required this.id,
    this.createdAt,
    this.createdBy,
    required this.title,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'title': title,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, createdBy, title, description];
}

