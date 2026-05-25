import 'dart:convert';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggerService {
  static LogLevel _logLevel = LogLevel.debug;
  static bool _enabled = true;

  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void _log(LogLevel level, String message, {Map<String, dynamic>? data}) {
    if (!_enabled || level.index < _logLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    final prefix = '[$timestamp] [$levelName]';

    if (data != null) {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      print('$prefix $message\n$prettyJson');
    } else {
      print('$prefix $message');
    }
  }

  static void debug(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, data: data);
  }

  static void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data: data);
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, data: data);
  }

  static void error(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.error, message, data: data);
  }

  static void logApiRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!_enabled || _logLevel.index > LogLevel.debug.index) {
      return;
    }

    final requestData = <String, dynamic>{
      'method': method,
      'url': url,
    };

    if (headers != null && headers.isNotEmpty) {
      // Mask sensitive headers
      final safeHeaders = Map<String, String>.from(headers);
      if (safeHeaders.containsKey('Authorization')) {
        final auth = safeHeaders['Authorization']!;
        if (auth.startsWith('Bearer ')) {
          safeHeaders['Authorization'] = 'Bearer ***';
        } else {
          safeHeaders['Authorization'] = '***';
        }
      }
      requestData['headers'] = safeHeaders;
    }

    if (body != null) {
      if (body is Map) {
        // Mask sensitive fields in body
        final safeBody = Map<String, dynamic>.from(body);
        if (safeBody.containsKey('password')) {
          safeBody['password'] = '***';
        }
        requestData['body'] = safeBody;
      } else if (body is String) {
        try {
          final parsed = json.decode(body) as Map<String, dynamic>;
          final safeBody = Map<String, dynamic>.from(parsed);
          if (safeBody.containsKey('password')) {
            safeBody['password'] = '***';
          }
          requestData['body'] = safeBody;
        } catch (e) {
          requestData['body'] = body;
        }
      } else {
        requestData['body'] = body.toString();
      }
    }

    info('API Request', data: requestData);
  }

  static void logApiResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    Duration? duration,
  }) {
    if (!_enabled || _logLevel.index > LogLevel.debug.index) {
      return;
    }

    final responseData = <String, dynamic>{
      'method': method,
      'url': url,
      'statusCode': statusCode,
    };

    if (duration != null) {
      responseData['duration'] = '${duration.inMilliseconds}ms';
    }

    if (headers != null && headers.isNotEmpty) {
      responseData['headers'] = headers;
    }

    if (body != null) {
      if (body is Map) {
        responseData['body'] = body;
      } else if (body is String) {
        try {
          responseData['body'] = json.decode(body);
        } catch (e) {
          responseData['body'] = body;
        }
      } else {
        responseData['body'] = body.toString();
      }
    }

    final level = statusCode >= 200 && statusCode < 300
        ? LogLevel.info
        : statusCode >= 400
            ? LogLevel.error
            : LogLevel.warning;

    _log(level, 'API Response', data: responseData);
  }

  static void logApiError({
    required String method,
    required String url,
    required String error,
    dynamic originalError,
  }) {
    final errorData = <String, dynamic>{
      'method': method,
      'url': url,
      'error': error,
    };

    if (originalError != null) {
      errorData['originalError'] = originalError.toString();
    }

    LoggerService.error('API Error', data: errorData);
  }
}

