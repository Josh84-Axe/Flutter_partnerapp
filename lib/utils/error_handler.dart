import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorHandler {
  /// Converts any exception into a user-friendly localized string.
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'error_generic_fallback'.tr();
    }

    // 1. Handle Dio Exceptions (Network & API Errors)
    if (error is DioException) {
      return _handleDioException(error);
    }

    // 2. Handle standard Dart Exceptions
    if (error is FormatException) {
      return 'error_data_parsing'.tr();
    }

    if (error is SocketException) {
      return 'error_connection'.tr();
    }

    if (error is TypeError) {
      return 'error_data_parsing'.tr();
    }

    // 3. Fallback to generic exception string parsing
    String errorString = error.toString();
    
    // Clean up standard Dart Exception formatting if present
    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.replaceFirst('Exception: ', '').trim();
    }
    
    // If it's a known non-localized string, we could try to localize it here,
    // otherwise just return the cleaned up string (often from the backend).
    if (errorString.isEmpty) {
      return 'error_generic_fallback'.tr();
    }
    
    return errorString;
  }

  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'error_connection_timeout'.tr();
      case DioExceptionType.badResponse:
        return _extractServerMessage(error.response) ?? 
               'error_server'.tr(namedArgs: {'code': error.response?.statusCode?.toString() ?? 'Unknown'});
      case DioExceptionType.cancel:
        return 'error_request_cancelled'.tr();
      case DioExceptionType.connectionError:
        return 'error_connection'.tr();
      default:
        return 'error_network_generic'.tr();
    }
  }

  static String? _extractServerMessage(Response<dynamic>? response) {
    if (response == null || response.data == null) return null;
    
    try {
      final data = response.data;
      if (data is Map) {
        // Try common API error formats
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }
        if (data.containsKey('error') && data['error'] != null) {
          return data['error'].toString();
        }
        if (data.containsKey('detail') && data['detail'] != null) {
          return data['detail'].toString();
        }
      }
    } catch (_) {
      // If parsing fails, fall back to default logic
    }
    return null;
  }
}
