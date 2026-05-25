import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'logger_service.dart';
import 'token_storage_service.dart';

class ApiService {
  final Config config;
  final http.Client _client;
  bool _isRefreshing = false;
  bool _sessionExpiredHandled = false;
  VoidCallback? _onSessionExpired;
  
  // Timeout duration for API requests
  static const Duration _requestTimeout = Duration(seconds: 30);

  ApiService({Config? config, http.Client? client})
    : config = config ?? Config.instance,
      _client = client ?? http.Client();

  // Set callback for when session expires (token refresh fails)
  void setSessionExpiredCallback(VoidCallback callback) {
    _onSessionExpired = callback;
    // Reset the flag when callback is set (e.g., on new login)
    _sessionExpiredHandled = false;
  }

  // Clear the session expired callback (e.g., on logout)
  void clearSessionExpiredCallback() {
    _onSessionExpired = null;
    _sessionExpiredHandled = false;
  }

  // Reset the session expired flag (e.g., after successful login)
  void resetSessionExpiredFlag() {
    _sessionExpiredHandled = false;
  }

  // Base URL getter
  String get baseUrl => config.apiBaseUrl;

  // Helper method to build full URL
  Uri _buildUri(String endpoint, {Map<String, String>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  // Helper method to build headers
  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? additionalHeaders,
    String? contentType,
    bool includeAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': contentType ?? 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization token if available and not explicitly excluded
    if (includeAuth) {
      final token = await _getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  // Get access token from storage
  Future<String?> _getAccessToken() async {
    try {
      return await TokenStorageService.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  // Helper method to handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      // Try to extract error message from response body
      String errorMessage = response.body;
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map) {
          errorMessage = errorBody['message']?.toString() ??
              errorBody['error']?.toString() ??
              errorBody['errors']?.toString() ??
              response.body;
        }
      } catch (_) {
        // If parsing fails, use the raw body
        errorMessage = response.body;
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        response: response,
      );
    }
  }

  // Refresh token if needed
  Future<bool> _refreshTokenIfNeeded() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      LoggerService.info(
        'ApiService: Token refresh already in progress, waiting...',
      );
      // Wait for ongoing refresh to complete
      int waitCount = 0;
      while (_isRefreshing && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      return !_isRefreshing;
    }

    try {
      _isRefreshing = true;

      final userId = await TokenStorageService.getUserId();
      final sessionId = await TokenStorageService.getSessionId();

      if (userId == null || sessionId == null) {
        LoggerService.warning(
          'ApiService: No userId or sessionId available for refresh',
        );
        _isRefreshing = false;
        _handleSessionExpired();
        return false;
      }

      LoggerService.info('ApiService: Refreshing token...');

      // Make refresh API call directly
      final response = await _client.post(
        _buildUri('/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'userId': userId, 'sessionId': sessionId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        // Extract accessToken from response
        String? accessToken;
        if (responseData['accessToken'] != null) {
          accessToken = responseData['accessToken'] as String;
        } else if (responseData['status'] == 200 &&
            responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          accessToken = data['accessToken'] as String?;
        }

        if (accessToken != null) {
          // Update token in storage
          await TokenStorageService.saveTokens(
            accessToken: accessToken,
            sessionId: sessionId,
            userId: userId,
          );
          LoggerService.info('ApiService: Token refreshed successfully');
          _isRefreshing = false;
          return true;
        } else {
          LoggerService.error(
            'ApiService: Token refresh response missing accessToken',
          );
          _isRefreshing = false;
          _handleSessionExpired();
          return false;
        }
      } else {
        LoggerService.error(
          'ApiService: Token refresh failed with status ${response.statusCode}',
        );
        _isRefreshing = false;
        _handleSessionExpired();
        return false;
      }
    } catch (e) {
      LoggerService.error('ApiService: Error during token refresh: $e');
      _isRefreshing = false;
      _handleSessionExpired();
      return false;
    }
  }

  // Handle session expiration - trigger logout
  void _handleSessionExpired() {
    // Prevent multiple logout triggers
    if (_sessionExpiredHandled) {
      LoggerService.info(
        'ApiService: Session expiration already handled, skipping',
      );
      return;
    }

    // Mark as handled immediately to prevent multiple calls
    _sessionExpiredHandled = true;

    LoggerService.warning('ApiService: Session expired, triggering logout');
    if (_onSessionExpired != null) {
      try {
        _onSessionExpired!();
      } catch (e) {
        LoggerService.error(
          'ApiService: Error in session expired callback: $e',
        );
        // Reset flag if callback fails so it can be retried if needed
        _sessionExpiredHandled = false;
      }
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool includeAuth = true,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final requestHeaders = await _buildHeaders(
      additionalHeaders: headers,
      includeAuth: includeAuth,
    );

    LoggerService.logApiRequest(
      method: 'GET',
      url: uri.toString(),
      headers: requestHeaders,
    );

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(_requestTimeout, onTimeout: () {
        LoggerService.error('GET request timed out after $_requestTimeout');
        throw ApiException(
          message: 'Request timed out. Please check your internet connection.',
        );
      });
      stopwatch.stop();

      LoggerService.logApiResponse(
        method: 'GET',
        url: uri.toString(),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      // Handle 401/403 Unauthorized/Forbidden - token expired
      if ((response.statusCode == 401 || response.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'GET request returned ${response.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Retry the request once after refresh
          return get(
            endpoint,
            queryParameters: queryParameters,
            headers: headers,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
        // If refresh failed, throw the original error
        return _handleResponse(response);
      }

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();

      // Only retry on ApiException with 401/403 status codes
      if (e is ApiException &&
          (e.statusCode == 401 || e.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'GET request failed with ${e.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return get(
            endpoint,
            queryParameters: queryParameters,
            headers: headers,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
      }

      LoggerService.logApiError(
        method: 'GET',
        url: uri.toString(),
        error: 'GET request failed: $e',
        originalError: e,
      );
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'GET request failed: $e', originalError: e);
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    String? contentType,
    bool includeAuth = true,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final requestHeaders = await _buildHeaders(
      additionalHeaders: headers,
      contentType: contentType,
      includeAuth: includeAuth,
    );

    final requestBody = body != null
        ? (contentType == 'application/json' || contentType == null
              ? json.encode(body)
              : body.toString())
        : null;

    LoggerService.logApiRequest(
      method: 'POST',
      url: uri.toString(),
      headers: requestHeaders,
      body: body,
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: requestHeaders,
            body: requestBody,
          )
          .timeout(_requestTimeout, onTimeout: () {
        LoggerService.error('POST request timed out after $_requestTimeout');
        throw ApiException(
          message: 'Request timed out. Please check your internet connection.',
        );
      });
      stopwatch.stop();

      LoggerService.logApiResponse(
        method: 'POST',
        url: uri.toString(),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      // Handle 401/403 Unauthorized/Forbidden - token expired
      if ((response.statusCode == 401 || response.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'POST request returned ${response.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Retry the request once after refresh
          return post(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
        // If refresh failed, throw the original error
        return _handleResponse(response);
      }

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();

      // Only retry on ApiException with 401/403 status codes
      if (e is ApiException &&
          (e.statusCode == 401 || e.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'POST request failed with ${e.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return post(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
      }

      LoggerService.logApiError(
        method: 'POST',
        url: uri.toString(),
        error: 'POST request failed: $e',
        originalError: e,
      );
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'POST request failed: $e', originalError: e);
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    String? contentType,
    bool includeAuth = true,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final requestHeaders = await _buildHeaders(
      additionalHeaders: headers,
      contentType: contentType,
      includeAuth: includeAuth,
    );

    final requestBody = body != null
        ? (contentType == 'application/json' || contentType == null
              ? json.encode(body)
              : body.toString())
        : null;

    LoggerService.logApiRequest(
      method: 'PUT',
      url: uri.toString(),
      headers: requestHeaders,
      body: body,
    );

    try {
      final response = await _client
          .put(
            uri,
            headers: requestHeaders,
            body: requestBody,
          )
          .timeout(_requestTimeout, onTimeout: () {
        LoggerService.error('PUT request timed out after $_requestTimeout');
        throw ApiException(
          message: 'Request timed out. Please check your internet connection.',
        );
      });
      stopwatch.stop();

      LoggerService.logApiResponse(
        method: 'PUT',
        url: uri.toString(),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      // Handle 401/403 Unauthorized/Forbidden - token expired
      if ((response.statusCode == 401 || response.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'PUT request returned ${response.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return put(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
        // If refresh failed, throw the original error
        return _handleResponse(response);
      }

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();

      // Only retry on ApiException with 401/403 status codes
      if (e is ApiException &&
          (e.statusCode == 401 || e.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'PUT request failed with ${e.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return put(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
      }

      LoggerService.logApiError(
        method: 'PUT',
        url: uri.toString(),
        error: 'PUT request failed: $e',
        originalError: e,
      );
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'PUT request failed: $e', originalError: e);
    }
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    String? contentType,
    bool includeAuth = true,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final requestHeaders = await _buildHeaders(
      additionalHeaders: headers,
      contentType: contentType,
      includeAuth: includeAuth,
    );

    final requestBody = body != null
        ? (contentType == 'application/json' || contentType == null
              ? json.encode(body)
              : body.toString())
        : null;

    LoggerService.logApiRequest(
      method: 'PATCH',
      url: uri.toString(),
      headers: requestHeaders,
      body: body,
    );

    try {
      final response = await _client
          .patch(
            uri,
            headers: requestHeaders,
            body: requestBody,
          )
          .timeout(_requestTimeout, onTimeout: () {
        LoggerService.error('PATCH request timed out after $_requestTimeout');
        throw ApiException(
          message: 'Request timed out. Please check your internet connection.',
        );
      });
      stopwatch.stop();

      LoggerService.logApiResponse(
        method: 'PATCH',
        url: uri.toString(),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      // Handle 401/403 Unauthorized/Forbidden - token expired
      if ((response.statusCode == 401 || response.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'PATCH request returned ${response.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return patch(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
        // If refresh failed, throw the original error
        return _handleResponse(response);
      }

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();

      // Only retry on ApiException with 401/403 status codes
      if (e is ApiException &&
          (e.statusCode == 401 || e.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'PATCH request failed with ${e.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return patch(
            endpoint,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
      }

      LoggerService.logApiError(
        method: 'PATCH',
        url: uri.toString(),
        error: 'PATCH request failed: $e',
        originalError: e,
      );
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'PATCH request failed: $e', originalError: e);
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool includeAuth = true,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final requestHeaders = await _buildHeaders(
      additionalHeaders: headers,
      includeAuth: includeAuth,
    );

    LoggerService.logApiRequest(
      method: 'DELETE',
      url: uri.toString(),
      headers: requestHeaders,
    );

    try {
      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(_requestTimeout, onTimeout: () {
        LoggerService.error('DELETE request timed out after $_requestTimeout');
        throw ApiException(
          message: 'Request timed out. Please check your internet connection.',
        );
      });
      stopwatch.stop();

      LoggerService.logApiResponse(
        method: 'DELETE',
        url: uri.toString(),
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      // Handle 401/403 Unauthorized/Forbidden - token expired
      if ((response.statusCode == 401 || response.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'DELETE request returned ${response.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return delete(
            endpoint,
            queryParameters: queryParameters,
            headers: headers,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
        // If refresh failed, throw the original error
        return _handleResponse(response);
      }

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();

      // Only retry on ApiException with 401/403 status codes
      if (e is ApiException &&
          (e.statusCode == 401 || e.statusCode == 403) &&
          includeAuth &&
          retryCount == 0) {
        LoggerService.warning(
          'DELETE request failed with ${e.statusCode}, attempting token refresh...',
        );
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return delete(
            endpoint,
            queryParameters: queryParameters,
            headers: headers,
            includeAuth: includeAuth,
            retryCount: 1,
          );
        }
      }

      LoggerService.logApiError(
        method: 'DELETE',
        url: uri.toString(),
        error: 'DELETE request failed: $e',
        originalError: e,
      );
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'DELETE request failed: $e',
        originalError: e,
      );
    }
  }

  // Close the HTTP client (useful for cleanup)
  void close() {
    _client.close();
  }

  // Static instance for easy access throughout the app
  static final ApiService instance = ApiService();
}

// Custom exception class for API errors
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final http.Response? response;
  final dynamic originalError;

  ApiException({
    this.statusCode,
    required this.message,
    this.response,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}
