import 'package:equatable/equatable.dart';
import 'package:gspro/models/attachment.dart';
import 'package:gspro/models/detailed_requisition.dart';
import 'package:gspro/models/requisition.dart';
import 'package:gspro/models/requisition_status.dart';

abstract class RequisitionState extends Equatable {
  const RequisitionState();

  @override
  List<Object?> get props => [];
}

class RequisitionInitial extends RequisitionState {
  const RequisitionInitial();
}

class RequisitionLoading extends RequisitionState {
  const RequisitionLoading();
}

class RequisitionsLoadedState extends RequisitionState {
  final List<Requisition> requisitions;

  const RequisitionsLoadedState({required this.requisitions});

  @override
  List<Object?> get props => [requisitions];
}

class RequisitionLoadedState extends RequisitionState {
  final DetailedRequisition detailedRequisition;
  final List<Attachment> attachments;

  const RequisitionLoadedState({
    required this.detailedRequisition,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [detailedRequisition, attachments];
}

class RequisitionStatusesLoadedState extends RequisitionState {
  final List<RequisitionStatus> statuses;

  const RequisitionStatusesLoadedState({required this.statuses});

  @override
  List<Object?> get props => [statuses];
}

class RequisitionError extends RequisitionState {
  final String message;

  const RequisitionError({required this.message});

  @override
  List<Object?> get props => [message];
}

