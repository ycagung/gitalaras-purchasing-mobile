import 'package:dartz/dartz.dart';
import 'package:gspro/models/detailed_requisition.dart';
import 'package:gspro/models/requisition.dart';
import 'package:gspro/services/api_service.dart';

class RequisitionRepository {
  final ApiService _apiService;

  RequisitionRepository(this._apiService);

  Future<Either<String, List<Requisition>>> getRequisitions({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters?.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final response = await _apiService.get(
        '/requisition/all',
        queryParameters: queryParams,
      );

      // Handle both response formats: {status: 200, data: [...]} and {message: "...", data: [...]}
      if (response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          final requisitions = data
              .map((json) => Requisition.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(requisitions);
        } else {
          return Left('Invalid data format: expected List');
        }
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to get requisitions',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, DetailedRequisition>> getDetailedRequisition({
    required String requisitionNumber,
  }) async {
    try {
      // Replace "-" with "/" in requisitionNumber for the API call
      final requisitionNums = requisitionNumber.replaceAll('-', '/');
      final response = await _apiService.get(
        '/requisition/detailed',
        queryParameters: {'requisitionNums': requisitionNums},
      );

      // Handle both response formats: {status: 200, data: [...]} and {message: "...", data: [...]}
      if (response['data'] != null) {
        final data = response['data'];
        if (data is List && data.isNotEmpty) {
          // API returns array, take first element
          final detailedRequisition = DetailedRequisition.fromJson(
            data[0] as Map<String, dynamic>,
          );
          return Right(detailedRequisition);
        } else if (data is Map<String, dynamic>) {
          // Handle case where it's a single object
          final detailedRequisition = DetailedRequisition.fromJson(data);
          return Right(detailedRequisition);
        } else {
          return Left('Invalid data format: expected List or Map');
        }
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to get requisition',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Requisition>> approveRequisition({
    required String requisitionId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiService.post(
        '/requisition/approve',
        body: {'requisitionId': requisitionId, 'items': items},
      );

      // Handle both response formats: {status: 200, data: {...}} and {message: "...", data: {...}}
      // Also handle case where response is just {message: "..."} without data
      if (response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final requisition = Requisition.fromJson(data);
          return Right(requisition);
        } else if (data is List && data.isNotEmpty) {
          // Handle case where data is a list
          final requisition = Requisition.fromJson(
            data[0] as Map<String, dynamic>,
          );
          return Right(requisition);
        } else {
          return Left('Invalid data format: expected Map or List');
        }
      } else if (response['message'] != null || response['status'] == 200) {
        // Success response without data - return a minimal requisition
        // The bloc will reload the detailed requisition anyway
        return Right(
          Requisition(
            id: requisitionId,
            number: '',
            requestDate: '',
            statusId: 0,
            approved: true,
          ),
        );
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to approve requisition',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Requisition>> rejectRequisition({
    required String requisitionId,
  }) async {
    try {
      final response = await _apiService.post(
        '/requisition/reject',
        body: {'requisitionId': requisitionId},
      );

      // Handle both response formats: {status: 200, data: {...}} and {message: "...", data: {...}}
      // Also handle case where response is just {message: "..."} without data
      if (response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final requisition = Requisition.fromJson(data);
          return Right(requisition);
        } else if (data is List && data.isNotEmpty) {
          // Handle case where data is a list
          final requisition = Requisition.fromJson(
            data[0] as Map<String, dynamic>,
          );
          return Right(requisition);
        } else {
          return Left('Invalid data format: expected Map or List');
        }
      } else if (response['message'] != null || response['status'] == 200) {
        // Success response without data - return a minimal requisition
        // The bloc will reload the detailed requisition anyway
        return Right(
          Requisition(
            id: requisitionId,
            number: '',
            requestDate: '',
            statusId: 0,
            approved: false,
          ),
        );
      } else {
        return Left(
          response['message'] as String? ?? 'Failed to reject requisition',
        );
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
