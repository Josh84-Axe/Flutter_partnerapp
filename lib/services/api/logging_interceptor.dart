import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive logging interceptor for API requests and responses
/// Logs all HTTP traffic with masked sensitive data
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    debugPrint('\n📤 API REQUEST [${options.method}]');
    debugPrint('URL: ${options.uri}');
    
    if (options.queryParameters.isNotEmpty) {
      debugPrint('Query Params: ${options.queryParameters}');
    }
    
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        final masked = value.toString().length > 10 
            ? '${value.toString().substring(0, 10)}...' 
            : '[MASKED]';
        debugPrint('Header: $key: $masked');
      } else {
        debugPrint('Header: $key: $value');
      }
    });
    
    if (options.data != null) {
      final dataStr = options.data.toString();
      debugPrint('Body: ${dataStr.length > 500 ? '${dataStr.substring(0, 500)}...' : dataStr}');
    }
  }

  void _logResponse(Response response) {
    debugPrint('\n📥 API RESPONSE [${response.statusCode}]');
    debugPrint('URL: ${response.requestOptions.uri}');
    
    if (response.data != null) {
      final dataStr = response.data.toString();
      debugPrint('Body: ${dataStr.length > 500 ? '${dataStr.substring(0, 500)}...' : dataStr}');
    }
  }

  void _logError(DioException err) {
    debugPrint('\n❌ API ERROR [${err.type}]');
    debugPrint('URL: ${err.requestOptions.uri}');
    debugPrint('Message: ${err.message}');
    
    if (err.response != null) {
      debugPrint('Status: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        final dataStr = err.response?.data.toString();
        debugPrint('Error Data: ${dataStr != null && dataStr.length > 500 ? '${dataStr.substring(0, 500)}...' : dataStr}');
      }
    }
    
    debugPrint('Stacktrace: ${err.stackTrace.toString().split('\n').take(3).join('\n')}');
    }
}
