import 'package:equatable/equatable.dart';
import 'package:gspro/models/detailed_order.dart';
import 'package:gspro/models/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrdersLoadedState extends OrderState {
  final List<Order> orders;

  const OrdersLoadedState({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderLoadedState extends OrderState {
  final DetailedOrder detailedOrder;

  const OrderLoadedState({required this.detailedOrder});

  @override
  List<Object?> get props => [detailedOrder];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
