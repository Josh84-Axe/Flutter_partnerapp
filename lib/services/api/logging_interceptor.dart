import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive logging interceptor for API requests and responses
/// Logs all HTTP traffic with masked sensitive data
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('📤 API REQUEST');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('Method: ${options.method}');
      if (kDebugMode) print('URL: ${options.uri}');
      
      if (options.queryParameters.isNotEmpty) {
        if (kDebugMode) print('Query Parameters: ${options.queryParameters}');
      }
      
      if (kDebugMode) print('Headers:');
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          // Mask token - show only first 8 characters
          final maskedValue = value.toString().length > 8 
              ? '${value.toString().substring(0, 8)}...[MASKED]'
              : '[MASKED]';
          if (kDebugMode) print('  $key: $maskedValue');
        } else {
          if (kDebugMode) print('  $key: $value');
        }
      });
      
      if (options.data != null) {
        final dataStr = options.data.toString();
        final truncated = dataStr.length > 300 
            ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
            : dataStr;
        if (kDebugMode) print('Request Body: $truncated');
      }
      
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('📥 API RESPONSE');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('Status Code: ${response.statusCode}');
      if (kDebugMode) print('URL: ${response.requestOptions.uri}');
      
      if (response.headers.map.isNotEmpty) {
        if (kDebugMode) print('Response Headers:');
        response.headers.map.forEach((key, value) {
          if (kDebugMode) print('  $key: ${value.join(", ")}');
        });
      }
      
      if (response.data != null) {
        final dataStr = response.data.toString();
        final truncated = dataStr.length > 300 
            ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
            : dataStr;
        if (kDebugMode) print('Response Body: $truncated');
      }
      
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('❌ API ERROR');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
      if (kDebugMode) print('Error Type: ${err.type}');
      if (kDebugMode) print('Error Message: ${err.message}');
      if (kDebugMode) print('URL: ${err.requestOptions.uri}');
      if (kDebugMode) print('Method: ${err.requestOptions.method}');
      
      if (err.response != null) {
        if (kDebugMode) print('Status Code: ${err.response?.statusCode}');
        
        if (err.response?.data != null) {
          final dataStr = err.response?.data.toString() ?? '';
          final truncated = dataStr.length > 300 
              ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
              : dataStr;
          if (kDebugMode) print('Error Response: $truncated');
        }
        
        // Log CORS-related errors
        if (err.type == DioExceptionType.connectionError || 
            err.type == DioExceptionType.unknown) {
          if (kDebugMode) print('⚠️  Possible CORS issue - check browser console for details');
        }
      }
      
      if (kDebugMode) print('Stack Trace: ${err.stackTrace?.toString().split('\n').take(5).join('\n')}');
      if (kDebugMode) print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(err);
  }
}
