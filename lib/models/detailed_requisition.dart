import 'package:equatable/equatable.dart';
import 'package:gspro/models/item.dart';
import 'package:gspro/models/requisition.dart';
import 'package:gspro/models/requisition_approver.dart';
import 'package:gspro/models/requisition_change.dart';
import 'package:gspro/models/requisition_print.dart';
import 'package:gspro/models/requisition_status.dart';

class DetailedRequisition extends Equatable {
  final Requisition header;
  final List<Item> items;
  final List<RequisitionApprover> approvals;
  final RequisitionStatus status;
  final List<RequisitionChange> changes;
  final List<RequisitionPrint> prints;

  const DetailedRequisition({
    required this.header,
    required this.items,
    required this.approvals,
    required this.status,
    this.changes = const [],
    this.prints = const [],
  });

  factory DetailedRequisition.fromJson(Map<String, dynamic> json) {
    // Safely extract header, defaulting to empty map if null
    final headerData = json['header'];
    final headerMap = headerData is Map
        ? Map<String, dynamic>.from(headerData)
        : <String, dynamic>{};

    // Safely extract status, defaulting to empty map if null
    final statusData = json['status'];
    final statusMap = statusData is Map
        ? Map<String, dynamic>.from(statusData)
        : <String, dynamic>{};

    return DetailedRequisition(
      header: Requisition.fromJson(headerMap),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Item.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      approvals:
          (json['approvals'] as List<dynamic>?)
              ?.map(
                (approver) => RequisitionApprover.fromJson(
                  approver as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      status: RequisitionStatus.fromJson(statusMap),
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map(
                (change) =>
                    RequisitionChange.fromJson(change as Map<String, dynamic>),
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
      'approvals': approvals.map((approver) => approver.toJson()).toList(),
      'status': status.toJson(),
      'changes': changes.map((change) => change.toJson()).toList(),
      'prints': prints.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    header,
    items,
    approvals,
    status,
    changes,
    prints,
  ];
}
