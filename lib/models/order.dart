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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      createdBy: json['createdBy']?.toString(),
      requisitionId: json['requisitionId']?.toString(),
      number: json['number']?.toString() ?? '',
      issuerId: json['issuerId']?.toString() ?? '',
      issueDate: json['issueDate']?.toString() ?? '',
      supplierId: json['supplierId']?.toString() ?? '',
      paymentTermId: json['paymentTermId']?.toString(),
      deliveryTerm: json['deliveryTerm']?.toString(),
      deliveryDate: json['deliveryDate']?.toString(),
      deliveryPointId: json['deliveryPointId'] is int
          ? json['deliveryPointId']
          : int.tryParse(json['deliveryPointId']?.toString() ?? ''),
      remarks: json['remarks']?.toString(),
      statusId: json['statusId'] is int
          ? json['statusId']
          : int.tryParse(json['statusId']?.toString() ?? '') ?? 1,
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
