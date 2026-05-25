import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:gspro/models/auth_response.dart';
import 'package:gspro/models/device.dart';
import 'package:gspro/models/user.dart';
import 'package:gspro/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Either<String, LoginResponse>> login({
    required String email,
    required String password,
    required Device device,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {'email': email, 'password': password, 'device': device.toJson()},
        includeAuth: false, // Don't include auth token for login
      );

      // Check if response has the data directly or wrapped in 'data' field
      if (response['accessToken'] != null && response['sessionId'] != null) {
        // Response has data directly
        final loginResponse = LoginResponse.fromJson(
          response as Map<String, dynamic>,
        );
        return Right(loginResponse);
      } else if (response['status'] == 200 && response['data'] != null) {
        // Response has data wrapped in 'data' field
        final loginResponse = LoginResponse.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        return Right(loginResponse);
      } else {
        // Try to extract error message from various possible response formats
        String errorMessage = 'Login failed';
        if (response['message'] != null) {
          errorMessage = response['message'].toString();
        } else if (response['error'] != null) {
          errorMessage = response['error'].toString();
        } else if (response['errors'] != null) {
          // Handle array of errors
          final errors = response['errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors.first.toString();
          } else if (errors is Map) {
            errorMessage = errors.values.first.toString();
          }
        }
        return Left(errorMessage);
      }
    } catch (e) {
      // Simplify error messages as requested
      if (e is ApiException) {
        if (e.statusCode == 401 || e.statusCode == 400) {
          return const Left('Invalid credentials');
        }
        return Left(e.message);
      }
      return Left(e.toString());
    }
  }

  Future<Either<String, RefreshResponse>> refresh({
    required String userId,
    required String sessionId,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/refresh',
        body: {'userId': userId, 'sessionId': sessionId},
        includeAuth: false, // Refresh doesn't need auth token
      );

      // Check if response has the data directly or wrapped in 'data' field
      if (response['accessToken'] != null) {
        // Response has data directly
        final refreshResponse = RefreshResponse.fromJson(
          response as Map<String, dynamic>,
        );
        return Right(refreshResponse);
      } else if (response['status'] == 200 && response['data'] != null) {
        // Response has data wrapped in 'data' field
        final refreshResponse = RefreshResponse.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        return Right(refreshResponse);
      } else {
        return Left(response['message'] as String? ?? 'Refresh failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, User>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/user');

      // Debug: Log the raw response
      print('DEBUG getCurrentUser response: $response');

      // Check if response has the data directly or wrapped in 'data' field
      if (response != null && response is Map<String, dynamic>) {
        final responseMap = response;

        // Debug: Log the response structure
        print('DEBUG responseMap keys: ${responseMap.keys.toList()}');
        print('DEBUG responseMap name field: ${responseMap['name']}');
        print('DEBUG responseMap userName field: ${responseMap['userName']}');
        print('DEBUG responseMap username field: ${responseMap['username']}');
        print('DEBUG responseMap avatar field: ${responseMap['avatar']}');
        print('DEBUG responseMap avatarUrl field: ${responseMap['avatarUrl']}');

        // Check if response has user data directly
        if (responseMap['id'] != null || responseMap['email'] != null) {
          // Response has user data directly
          final user = User.fromJson(responseMap);
          print('DEBUG parsed user name: ${user.name}');
          print('DEBUG parsed user avatar: ${user.avatar}');
          return Right(user);
        }

        // Check if response has data wrapped in 'data' field
        // This handles both {status: 200, data: {...}} and {message: "...", data: {...}} formats
        if (responseMap['data'] != null) {
          final data = responseMap['data'];
          if (data is Map<String, dynamic>) {
            print('DEBUG data keys: ${data.keys.toList()}');
            print('DEBUG data name field: ${data['name']}');
            print('DEBUG data userName field: ${data['userName']}');
            print('DEBUG data username field: ${data['username']}');
            print('DEBUG data avatar field: ${data['avatar']}');
            print('DEBUG data avatarUrl field: ${data['avatarUrl']}');
            final user = User.fromJson(data);
            print('DEBUG parsed user name: ${user.name}');
            print('DEBUG parsed user avatar: ${user.avatar}');
            return Right(user);
          } else {
            return Left('Invalid data format');
          }
        }

        // If neither format matches, return error
        return Left(responseMap['message'] as String? ?? 'Failed to get user');
      } else {
        return Left('Invalid response format');
      }
    } catch (e) {
      print('DEBUG getCurrentUser error: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> logout() async {
    try {
      final response = await _apiService.post(
        '/auth/logout',
        includeAuth: true, // Logout needs auth token
      );

      // Check if response has status field or just message
      if (response['status'] == 200 || response['message'] != null) {
        return const Right(null);
      } else {
        return Left(response['message'] as String? ?? 'Logout failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
