import 'package:dartz/dartz.dart' hide Order;
import 'package:gspro/models/attachment.dart';
import 'package:gspro/models/detailed_order.dart';
import 'package:gspro/models/order.dart';
import 'package:gspro/services/api_service.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  Future<Either<String, List<Order>>> getOrders({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters?.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = await _apiService.get(
        '/order/all',
        queryParameters: queryParams,
      );

      if (response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          final orders = data
              .map((json) => Order.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(orders);
        } else {
          return Left('Invalid data format: expected List');
        }
      } else {
        return Left(response['message'] as String? ?? 'Failed to get orders');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, DetailedOrder>> getDetailedOrder({
    required String orderNumber,
  }) async {
    try {
      final orderNums = orderNumber.replaceAll('-', '/');
      final response = await _apiService.get(
        '/order/detailed',
        queryParameters: {'orderNums': orderNums},
      );

      if (response['data'] != null) {
        final data = response['data'];
        if (data is List && data.isNotEmpty) {
          final detailedOrder = DetailedOrder.fromJson(
            data[0] as Map<String, dynamic>,
          );
          return Right(detailedOrder);
        } else if (data is Map<String, dynamic>) {
          final detailedOrder = DetailedOrder.fromJson(data);
          return Right(detailedOrder);
        } else {
          return Left('Invalid data format: expected List or Map');
        }
      } else {
        return Left(response['message'] as String? ?? 'Failed to get order');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Attachment>>> getOrderAttachments(
    String orderId,
  ) async {
    try {
      final response = await _apiService.get('/order/$orderId/attachments');

      if (response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          final attachments = data
              .map((json) => Attachment.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(attachments);
        } else {
          return Left('Invalid data format: expected List');
        }
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to get attachments',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Order>> approveOrder({
    required String orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiService.post(
        '/order/approve',
        body: {'orderId': orderId, 'items': items},
      );

      if (response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final order = Order.fromJson(data);
          return Right(order);
        } else if (data is List && data.isNotEmpty) {
          final order = Order.fromJson(data[0] as Map<String, dynamic>);
          return Right(order);
        } else {
          return Left('Invalid data format: expected Map or List');
        }
      } else if (response['message'] != null || response['status'] == 200) {
        return Right(
          Order(
            id: orderId,
            number: '',
            issuerId: '',
            issueDate: '',
            supplierId: '',
            statusId: 0,
          ),
        );
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to approve order',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Order>> rejectOrder({required String orderId}) async {
    try {
      final response = await _apiService.post(
        '/order/reject',
        body: {'orderId': orderId},
      );

      if (response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final order = Order.fromJson(data);
          return Right(order);
        } else if (data is List && data.isNotEmpty) {
          final order = Order.fromJson(data[0] as Map<String, dynamic>);
          return Right(order);
        } else {
          return Left('Invalid data format: expected Map or List');
        }
      } else if (response['message'] != null || response['status'] == 200) {
        return Right(
          Order(
            id: orderId,
            number: '',
            issuerId: '',
            issueDate: '',
            supplierId: '',
            statusId: 0,
          ),
        );
      } else {
        return Left(response['message'] as String? ?? 'Failed to reject order');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
