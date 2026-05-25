import 'package:equatable/equatable.dart';

class RequisitionStatus extends Equatable {
  final int id;
  final String name;
  final int order;

  const RequisitionStatus({
    required this.id,
    required this.name,
    required this.order,
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

  factory RequisitionStatus.fromJson(Map<String, dynamic> json) {
    return RequisitionStatus(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      order: _parseInt(json['order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, name, order];
}

