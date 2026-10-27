import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/order/order_event.dart';
import 'package:gspro/bloc/order/order_state.dart';
import 'package:gspro/models/attachment.dart';
import 'package:gspro/repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderInitial()) {
    on<OrdersLoaded>(_onOrdersLoaded);
    on<OrderLoaded>(_onOrderLoaded);
    on<OrderApproved>(_onOrderApproved);
    on<OrderRejected>(_onOrderRejected);
  }

  Future<void> _onOrdersLoaded(
    OrdersLoaded event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await _orderRepository.getOrders(filters: event.filters);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (orders) => emit(OrdersLoadedState(orders: orders)),
    );
  }

  Future<void> _onOrderLoaded(
    OrderLoaded event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await _orderRepository.getDetailedOrder(
      orderNumber: event.orderNumber,
    );

    if (result.isLeft()) {
      emit(OrderError(message: result.fold((l) => l, (r) => '')));
      return;
    }

    final detailedOrder = result.fold((l) => null, (r) => r);
    if (detailedOrder == null) return;

    final attachmentResult = await _orderRepository.getOrderAttachments(
      detailedOrder.header.id,
    );

    final attachments = attachmentResult.fold((l) => <Attachment>[], (r) => r);

    emit(
      OrderLoadedState(
        detailedOrder: detailedOrder,
        attachments: attachments,
      ),
    );
  }

  Future<void> _onOrderApproved(
    OrderApproved event,
    Emitter<OrderState> emit,
  ) async {
    // Capture the order number before emitting loading state
    String? orderNumber;
    if (state is OrderLoadedState) {
      orderNumber = (state as OrderLoadedState).detailedOrder.header.number;
    }

    emit(const OrderLoading());

    final approveResult = await _orderRepository.approveOrder(
      orderId: event.orderId,
      items: event.items,
    );

    if (approveResult.isLeft()) {
      final error = approveResult.fold((l) => l, (r) => '');
      emit(OrderError(message: error));
      return;
    }

    final order = approveResult.fold((l) => null, (r) => r);
    if (order == null) {
      emit(const OrderError(message: 'Failed to approve order'));
      return;
    }

    // Reload the detailed order
    final numberToReload = orderNumber ?? order.number;

    if (numberToReload.isNotEmpty) {
      final reloadResult = await _orderRepository.getDetailedOrder(
        orderNumber: numberToReload,
      );

      reloadResult.fold(
        (error) => emit(OrderError(message: error)),
        (detailedOrder) async {
          final attachmentResult = await _orderRepository.getOrderAttachments(
            detailedOrder.header.id,
          );
          final attachments = attachmentResult.fold((l) => <Attachment>[], (r) => r);
          emit(
            OrderLoadedState(
              detailedOrder: detailedOrder,
              attachments: attachments,
            ),
          );
        },
      );
    } else {
      emit(
        const OrderError(
          message: 'Could not reload order details after approval',
        ),
      );
    }
  }

  Future<void> _onOrderRejected(
    OrderRejected event,
    Emitter<OrderState> emit,
  ) async {
    // Capture the order number before emitting loading state
    String? orderNumber;
    if (state is OrderLoadedState) {
      orderNumber = (state as OrderLoadedState).detailedOrder.header.number;
    }

    emit(const OrderLoading());

    final rejectResult = await _orderRepository.rejectOrder(
      orderId: event.orderId,
    );

    if (rejectResult.isLeft()) {
      final error = rejectResult.fold((l) => l, (r) => '');
      emit(OrderError(message: error));
      return;
    }

    final order = rejectResult.fold((l) => null, (r) => r);
    if (order == null) {
      emit(const OrderError(message: 'Failed to reject order'));
      return;
    }

    // Reload the detailed order
    final numberToReload = orderNumber ?? order.number;

    if (numberToReload.isNotEmpty) {
      final reloadResult = await _orderRepository.getDetailedOrder(
        orderNumber: numberToReload,
      );

      reloadResult.fold(
        (error) => emit(OrderError(message: error)),
        (detailedOrder) async {
          final attachmentResult = await _orderRepository.getOrderAttachments(
            detailedOrder.header.id,
          );
          final attachments = attachmentResult.fold((l) => <Attachment>[], (r) => r);
          emit(
            OrderLoadedState(
              detailedOrder: detailedOrder,
              attachments: attachments,
            ),
          );
        },
      );
    } else {
      emit(
        const OrderError(
          message: 'Could not reload order details after rejection',
        ),
      );
    }
  }
}
