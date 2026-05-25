import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gspro/bloc/requisition/requisition_event.dart';
import 'package:gspro/bloc/requisition/requisition_state.dart';
import 'package:gspro/repositories/requisition_repository.dart';

class RequisitionBloc extends Bloc<RequisitionEvent, RequisitionState> {
  final RequisitionRepository _requisitionRepository;

  RequisitionBloc({required RequisitionRepository requisitionRepository})
    : _requisitionRepository = requisitionRepository,
      super(const RequisitionInitial()) {
    on<RequisitionsLoaded>(_onRequisitionsLoaded);
    on<RequisitionLoaded>(_onRequisitionLoaded);
    on<RequisitionApproved>(_onRequisitionApproved);
    on<RequisitionRejected>(_onRequisitionRejected);
  }

  Future<void> _onRequisitionsLoaded(
    RequisitionsLoaded event,
    Emitter<RequisitionState> emit,
  ) async {
    emit(const RequisitionLoading());

    final result = await _requisitionRepository.getRequisitions(
      filters: event.filters,
    );

    result.fold(
      (error) => emit(RequisitionError(message: error)),
      (requisitions) =>
          emit(RequisitionsLoadedState(requisitions: requisitions)),
    );
  }

  Future<void> _onRequisitionLoaded(
    RequisitionLoaded event,
    Emitter<RequisitionState> emit,
  ) async {
    emit(const RequisitionLoading());

    final result = await _requisitionRepository.getDetailedRequisition(
      requisitionNumber: event.requisitionNumber,
    );

    result.fold(
      (error) => emit(RequisitionError(message: error)),
      (detailedRequisition) => emit(
        RequisitionLoadedState(detailedRequisition: detailedRequisition),
      ),
    );
  }

  Future<void> _onRequisitionApproved(
    RequisitionApproved event,
    Emitter<RequisitionState> emit,
  ) async {
    // Capture the requisition number before emitting loading state
    String? requisitionNumber;
    if (state is RequisitionLoadedState) {
      requisitionNumber =
          (state as RequisitionLoadedState).detailedRequisition.header.number;
    }

    emit(const RequisitionLoading());

    // First approve the requisition
    final approveResult = await _requisitionRepository.approveRequisition(
      requisitionId: event.requisitionId,
      items: event.items,
    );

    // Handle the result - check if it's Left (error) or Right (success)
    if (approveResult.isLeft()) {
      final error = approveResult.fold((l) => l, (r) => '');
      emit(RequisitionError(message: error));
      return;
    }

    // Success case - get the requisition from Right
    final requisition = approveResult.fold((l) => null, (r) => r);
    if (requisition == null) {
      emit(const RequisitionError(message: 'Failed to approve requisition'));
      return;
    }

    // After approval, reload the detailed requisition using the captured number
    // If we don't have the number from state, try to get it from the response
    final numberToReload = requisitionNumber ?? requisition.number;

    if (numberToReload.isNotEmpty) {
      final reloadResult = await _requisitionRepository.getDetailedRequisition(
        requisitionNumber: numberToReload,
      );

      reloadResult.fold(
        (error) => emit(RequisitionError(message: error)),
        (detailedRequisition) => emit(
          RequisitionLoadedState(detailedRequisition: detailedRequisition),
        ),
      );
    } else {
      // If we can't get the requisition number, emit error
      emit(
        const RequisitionError(
          message: 'Could not reload requisition details after approval',
        ),
      );
    }
  }

  Future<void> _onRequisitionRejected(
    RequisitionRejected event,
    Emitter<RequisitionState> emit,
  ) async {
    // Capture the requisition number before emitting loading state
    String? requisitionNumber;
    if (state is RequisitionLoadedState) {
      requisitionNumber =
          (state as RequisitionLoadedState).detailedRequisition.header.number;
    }

    emit(const RequisitionLoading());

    // First reject the requisition
    final rejectResult = await _requisitionRepository.rejectRequisition(
      requisitionId: event.requisitionId,
    );

    // Handle the result - check if it's Left (error) or Right (success)
    if (rejectResult.isLeft()) {
      final error = rejectResult.fold((l) => l, (r) => '');
      emit(RequisitionError(message: error));
      return;
    }

    // Success case - get the requisition from Right
    final requisition = rejectResult.fold((l) => null, (r) => r);
    if (requisition == null) {
      emit(const RequisitionError(message: 'Failed to reject requisition'));
      return;
    }

    // After rejection, reload the detailed requisition using the captured number
    // If we don't have the number from state, try to get it from the response
    final numberToReload = requisitionNumber ?? requisition.number;

    if (numberToReload.isNotEmpty) {
      final reloadResult = await _requisitionRepository.getDetailedRequisition(
        requisitionNumber: numberToReload,
      );

      reloadResult.fold(
        (error) => emit(RequisitionError(message: error)),
        (detailedRequisition) => emit(
          RequisitionLoadedState(detailedRequisition: detailedRequisition),
        ),
      );
    } else {
      // If we can't get the requisition number, emit error
      emit(
        const RequisitionError(
          message: 'Could not reload requisition details after rejection',
        ),
      );
    }
  }
}
