import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String? requisitionId;
  final String? orderId;
  final String productId;
  final int? index;
  final String? name;
  final int qty;
  final String uom;
  final String? price;
  final String? tax;
  final String? discount;
  final String? total;
  final String? remarks;

  const Item({
    required this.id,
    this.createdAt,
    this.createdBy,
    this.requisitionId,
    this.orderId,
    required this.productId,
    this.index,
    this.name,
    required this.qty,
    required this.uom,
    this.price,
    this.tax,
    this.discount,
    this.total,
    this.remarks,
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

  // Helper method to safely parse DateTime from string
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

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      createdBy: json['created_by']?.toString(),
      requisitionId: json['requisition_id']?.toString(),
      orderId: json['order_id']?.toString(),
      productId: json['product_id']?.toString() ?? '',
      index: _parseInt(json['index']),
      name: json['name']?.toString(),
      qty: _parseInt(json['qty']) ?? 0,
      uom: json['uom']?.toString() ?? '',
      price: json['price']?.toString(),
      tax: json['tax']?.toString(),
      discount: json['discount']?.toString(),
      total: json['total']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'requisition_id': requisitionId,
      'order_id': orderId,
      'product_id': productId,
      'index': index,
      'name': name,
      'qty': qty,
      'uom': uom,
      'price': price,
      'tax': tax,
      'discount': discount,
      'total': total,
      'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        createdBy,
        requisitionId,
        orderId,
        productId,
        index,
        name,
        qty,
        uom,
        price,
        tax,
        discount,
        total,
        remarks,
      ];
}

