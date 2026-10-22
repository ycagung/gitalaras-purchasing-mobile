import 'package:equatable/equatable.dart';

abstract class RequisitionEvent extends Equatable {
  const RequisitionEvent();

  @override
  List<Object?> get props => [];
}

class RequisitionsLoaded extends RequisitionEvent {
  final Map<String, dynamic>? filters;

  const RequisitionsLoaded({this.filters});

  @override
  List<Object?> get props => [filters];
}

class RequisitionLoaded extends RequisitionEvent {
  final String requisitionNumber;

  const RequisitionLoaded({required this.requisitionNumber});

  @override
  List<Object?> get props => [requisitionNumber];
}

class RequisitionApproved extends RequisitionEvent {
  final String requisitionId;
  final List<Map<String, dynamic>> items;

  /// Base64-encoded PNG of the approver's drawn signature.
  final String signature;

  const RequisitionApproved({
    required this.requisitionId,
    required this.items,
    required this.signature,
  });

  @override
  List<Object?> get props => [requisitionId, items, signature];
}

class RequisitionRejected extends RequisitionEvent {
  final String requisitionId;

  /// Base64-encoded PNG of the approver's drawn signature.
  final String signature;

  const RequisitionRejected({
    required this.requisitionId,
    required this.signature,
  });

  @override
  List<Object?> get props => [requisitionId, signature];
}

class RequisitionChecked extends RequisitionEvent {
  final String requisitionId;

  /// Base64-encoded PNG of the checker's drawn signature.
  final String signature;

  const RequisitionChecked({required this.requisitionId, required this.signature});

  @override
  List<Object?> get props => [requisitionId, signature];
}
