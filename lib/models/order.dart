import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String? requisitionId;
  final String number;
  final String issuerId;
  final String issueDate;
  final String supplierId;
  final String? paymentTermId;
  final String? deliveryTerm;
  final String? deliveryDate;
  final int? deliveryPointId;
  final String? remarks;
  final int statusId;

  const Order({
    required this.id,
    this.createdAt,
    this.createdBy,
    this.requisitionId,
    required this.number,
    required this.issuerId,
    required this.issueDate,
    required this.supplierId,
    this.paymentTermId,
    this.deliveryTerm,
    this.deliveryDate,
    this.deliveryPointId,
    this.remarks,
    required this.statusId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      createdBy: json['created_by']?.toString(),
      requisitionId: json['requisition_id']?.toString(),
      number: json['number']?.toString() ?? '',
      issuerId: json['issuer_id']?.toString() ?? '',
      issueDate: json['issue_date']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      paymentTermId: json['payment_term_id']?.toString(),
      deliveryTerm: json['delivery_term']?.toString(),
      deliveryDate: json['delivery_date']?.toString(),
      deliveryPointId: json['delivery_point_id'] is int
          ? json['delivery_point_id']
          : int.tryParse(json['delivery_point_id']?.toString() ?? ''),
      remarks: json['remarks']?.toString(),
      statusId: json['status_id'] is int
          ? json['status_id']
          : int.tryParse(json['status_id']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'requisition_id': requisitionId,
      'number': number,
      'issuer_id': issuerId,
      'issue_date': issueDate,
      'supplier_id': supplierId,
      'payment_term_id': paymentTermId,
      'delivery_term': deliveryTerm,
      'delivery_date': deliveryDate,
      'delivery_point_id': deliveryPointId,
      'remarks': remarks,
      'status_id': statusId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdBy,
    requisitionId,
    number,
    issuerId,
    issueDate,
    supplierId,
    paymentTermId,
    deliveryTerm,
    deliveryDate,
    deliveryPointId,
    remarks,
    statusId,
  ];
}
