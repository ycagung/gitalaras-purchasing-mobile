import 'package:dartz/dartz.dart';
import 'package:gspro/models/project.dart';
import 'package:gspro/services/api_service.dart';

class ProjectRepository {
  final ApiService _apiService;

  ProjectRepository(this._apiService);

  Future<Either<String, ProjectDetail>> getProjectByNumber(
    String projectNumber,
  ) async {
    try {
      final response = await _apiService.get(
        '/project/by-number',
        queryParameters: {'projectNumber': projectNumber},
      );

      if (response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return Right(ProjectDetail.fromJson(data));
        }
        return Left('Invalid data format: expected Map');
      }

      return Left(
        response['message'] as String? ?? 'Failed to get project',
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}
