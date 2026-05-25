import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String type;
  final String name;
  final int? locationId;
  final String? picName;
  final String? picPhoneNumber;

  const Supplier({
    required this.id,
    this.createdAt,
    this.createdBy,
    required this.type,
    required this.name,
    this.locationId,
    this.picName,
    this.picPhoneNumber,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      type: json['type'] as String,
      name: json['name'] as String,
      locationId: json['location_id'] as int?,
      picName: json['pic_name'] as String?,
      picPhoneNumber: json['pic_phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'type': type,
      'name': name,
      'location_id': locationId,
      'pic_name': picName,
      'pic_phone_number': picPhoneNumber,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, createdBy, type, name, locationId, picName, picPhoneNumber];
}

