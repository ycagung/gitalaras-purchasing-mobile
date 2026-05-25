import 'package:equatable/equatable.dart';

class OrderStatus extends Equatable {
  final int id;
  final String name;
  final int order;

  const OrderStatus({
    required this.id,
    required this.name,
    required this.order,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'] as int,
      name: json['name'] as String,
      order: json['order'] as int,
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

