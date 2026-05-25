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

  const RequisitionApproved({required this.requisitionId, required this.items});

  @override
  List<Object?> get props => [requisitionId, items];
}

class RequisitionRejected extends RequisitionEvent {
  final String requisitionId;

  const RequisitionRejected({required this.requisitionId});

  @override
  List<Object?> get props => [requisitionId];
}
