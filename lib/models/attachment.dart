import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String? requisitionId;
  final String name;
  final String url;
  final String mimeType;
  final String createdBy;
  final String createdAt;
  final String? deletedAt;
  final String? deletedBy;
  final String? presignedUrl;

  const Attachment({
    required this.id,
    this.requisitionId,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.createdBy,
    required this.createdAt,
    this.deletedAt,
    this.deletedBy,
    this.presignedUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String? ?? '',
      requisitionId: json['requisitionId'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      url: json['url'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      deletedAt: json['deletedAt'] as String?,
      deletedBy: json['deletedBy'] as String?,
      presignedUrl: json['presignedUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requisitionId': requisitionId,
      'name': name,
      'url': url,
      'mimeType': mimeType,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'deletedAt': deletedAt,
      'deletedBy': deletedBy,
      'presignedUrl': presignedUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        requisitionId,
        name,
        url,
        mimeType,
        createdBy,
        createdAt,
        deletedAt,
        deletedBy,
        presignedUrl,
      ];
}
