import 'package:equatable/equatable.dart';

class RequisitionPrint extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? printedById;

  const RequisitionPrint({required this.id, this.createdAt, this.printedById});

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

  factory RequisitionPrint.fromJson(Map<String, dynamic> json) {
    return RequisitionPrint(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      printedById:
          json['printedById']?.toString() ?? json['printed_by_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'printedById': printedById,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, printedById];
}
