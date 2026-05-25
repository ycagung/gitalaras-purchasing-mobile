import 'package:equatable/equatable.dart';
import 'package:gspro/models/item.dart';
import 'package:gspro/models/order.dart';
import 'package:gspro/models/order_approver.dart';
import 'package:gspro/models/order_status.dart';
import 'package:gspro/models/requisition_approver.dart';
import 'package:gspro/models/requisition_change.dart';
import 'package:gspro/models/requisition_print.dart';
import 'package:gspro/models/supplier.dart';

class DetailedOrder extends Equatable {
  final Order header;
  final List<Item> items;
  final List<OrderApprover> approvals;
  final OrderStatus status;
  final Supplier? supplier;
  final ApproverInfo? issuer;
  final Map<String, dynamic>? deliveryPoint;
  final List<RequisitionChange> changes;
  final List<RequisitionPrint> prints;

  const DetailedOrder({
    required this.header,
    required this.items,
    required this.approvals,
    required this.status,
    this.supplier,
    this.issuer,
    this.deliveryPoint,
    this.changes = const [],
    this.prints = const [],
  });

  /// Helper to get delivery point name safely
  String get deliveryPointName {
    if (deliveryPoint == null) return '-';
    return deliveryPoint!['name']?.toString() ?? '-';
  }

  factory DetailedOrder.fromJson(Map<String, dynamic> json) {
    // Safely extract header
    final headerData = json['header'];
    final headerMap = headerData is Map
        ? Map<String, dynamic>.from(headerData)
        : <String, dynamic>{};

    // Safely extract status
    final statusData = json['status'];
    final statusMap = statusData is Map
        ? Map<String, dynamic>.from(statusData)
        : <String, dynamic>{'id': 0, 'name': 'Unknown', 'order': 0};

    return DetailedOrder(
      header: Order.fromJson(headerMap),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Item.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      approvals:
          (json['approvals'] as List<dynamic>?)
              ?.map((a) => OrderApprover.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      status: OrderStatus.fromJson(statusMap),
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      issuer: json['issuer'] != null
          ? ApproverInfo.fromJson(json['issuer'] as Map<String, dynamic>)
          : null,
      deliveryPoint: json['deliveryPoint'] != null
          ? Map<String, dynamic>.from(json['deliveryPoint'] as Map)
          : null,
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map(
                (c) => RequisitionChange.fromJson(c as Map<String, dynamic>),
              )
              .toList() ??
          [],
      prints:
          (json['prints'] as List<dynamic>?)
              ?.map((p) => RequisitionPrint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'approvals': approvals.map((a) => a.toJson()).toList(),
      'status': status.toJson(),
      'supplier': supplier?.toJson(),
      'issuer': issuer?.toJson(),
      'deliveryPoint': deliveryPoint,
      'changes': changes.map((c) => c.toJson()).toList(),
      'prints': prints.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    header,
    items,
    approvals,
    status,
    supplier,
    issuer,
    deliveryPoint,
    changes,
    prints,
  ];
}
