import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive logging interceptor for API requests and responses
/// Logs all HTTP traffic with masked sensitive data
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 API REQUEST');
      print('═══════════════════════════════════════════════════════════');
      print('Method: ${options.method}');
      print('URL: ${options.uri}');
      
      if (options.queryParameters.isNotEmpty) {
        print('Query Parameters: ${options.queryParameters}');
      }
      
      print('Headers:');
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          // Mask token - show only first 8 characters
          final maskedValue = value.toString().length > 8 
              ? '${value.toString().substring(0, 8)}...[MASKED]'
              : '[MASKED]';
          print('  $key: $maskedValue');
        } else {
          print('  $key: $value');
        }
      });
      
      if (options.data != null) {
        final dataStr = options.data.toString();
        final truncated = dataStr.length > 300 
            ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
            : dataStr;
        print('Request Body: $truncated');
      }
      
      print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 API RESPONSE');
      print('═══════════════════════════════════════════════════════════');
      print('Status Code: ${response.statusCode}');
      print('URL: ${response.requestOptions.uri}');
      
      if (response.headers.map.isNotEmpty) {
        print('Response Headers:');
        response.headers.map.forEach((key, value) {
          print('  $key: ${value.join(", ")}');
        });
      }
      
      if (response.data != null) {
        final dataStr = response.data.toString();
        final truncated = dataStr.length > 300 
            ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
            : dataStr;
        print('Response Body: $truncated');
      }
      
      print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ API ERROR');
      print('═══════════════════════════════════════════════════════════');
      print('Error Type: ${err.type}');
      print('Error Message: ${err.message}');
      print('URL: ${err.requestOptions.uri}');
      print('Method: ${err.requestOptions.method}');
      
      if (err.response != null) {
        print('Status Code: ${err.response?.statusCode}');
        
        if (err.response?.data != null) {
          final dataStr = err.response?.data.toString() ?? '';
          final truncated = dataStr.length > 300 
              ? '${dataStr.substring(0, 300)}...[TRUNCATED]'
              : dataStr;
          print('Error Response: $truncated');
        }
        
        // Log CORS-related errors
        if (err.type == DioExceptionType.connectionError || 
            err.type == DioExceptionType.unknown) {
          print('⚠️  Possible CORS issue - check browser console for details');
        }
      }
      
      print('Stack Trace: ${err.stackTrace?.toString().split('\n').take(5).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
    }
    
    handler.next(err);
  }
}
