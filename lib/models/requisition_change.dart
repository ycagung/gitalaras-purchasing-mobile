import 'package:equatable/equatable.dart';

class RequisitionChangeBy extends Equatable {
  final String? name;
  final String? email;

  const RequisitionChangeBy({this.name, this.email});

  factory RequisitionChangeBy.fromJson(Map<String, dynamic> json) {
    return RequisitionChangeBy(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }

  /// Returns displayable name: name > email > "Unknown"
  String get displayName => name ?? email ?? 'Unknown';

  @override
  List<Object?> get props => [name, email];
}

class RequisitionChange extends Equatable {
  final String id;
  final String? content;
  final String? section;
  final DateTime? at;
  final RequisitionChangeBy? by;

  const RequisitionChange({
    required this.id,
    this.content,
    this.section,
    this.at,
    this.by,
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

  factory RequisitionChange.fromJson(Map<String, dynamic> json) {
    return RequisitionChange(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString(),
      section: json['section']?.toString(),
      at: _parseDateTime(json['at']),
      by: json['by'] != null
          ? RequisitionChangeBy.fromJson(json['by'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'section': section,
      'at': at?.toIso8601String(),
      'by': by?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, content, section, at, by];
}
