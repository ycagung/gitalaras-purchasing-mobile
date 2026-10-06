import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrderEvent {
  final Map<String, dynamic>? filters;

  const OrdersLoaded({this.filters});

  @override
  List<Object?> get props => [filters];
}

class OrderLoaded extends OrderEvent {
  final String orderNumber;

  const OrderLoaded({required this.orderNumber});

  @override
  List<Object?> get props => [orderNumber];
}

class OrderApproved extends OrderEvent {
  final String orderId;
  final List<Map<String, dynamic>> items;

  /// Base64-encoded PNG of the approver's drawn signature.
  final String signature;

  const OrderApproved({
    required this.orderId,
    required this.items,
    required this.signature,
  });

  @override
  List<Object?> get props => [orderId, items, signature];
}

class OrderRejected extends OrderEvent {
  final String orderId;

  /// Base64-encoded PNG of the approver's drawn signature.
  final String signature;

  const OrderRejected({required this.orderId, required this.signature});

  @override
  List<Object?> get props => [orderId, signature];
}
