import 'package:dio/dio.dart';

/// Helper class to convert technical errors to user-friendly messages
class ErrorMessageHelper {
  /// Convert backend/technical errors to user-friendly messages
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Unable to connect. Please check your internet connection.';
    }
    
    // Timeout
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Server errors (500+)
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error. Our team has been notified. Please try again later.';
    }
    
    // Authentication errors
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Session expired. Please log in again.';
    }
    
    // Permission errors
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    // Not found
    if (errorString.contains('not found') || errorString.contains('404')) {
      return context != null 
          ? '$context not found.'
          : 'The requested resource was not found.';
    }
    
    // Validation errors
    if (errorString.contains('validation')) {
      return 'Please check your input and try again.';
    }
    
    // Email exists
    if (errorString.contains('email') && errorString.contains('exists')) {
      return 'This email is already registered. Please use a different email or try logging in.';
    }
    
    // Generic fallback
    return 'Something went wrong. Please try again or contact support if the problem persists.';
  }
  
  /// Extract specific error details from DioException
  static String getDetailedError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        
        // Try to extract message from common response formats
        if (data is Map) {
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
        }
      }
    }
    
    // Generic catch for raw exceptions and technical errors
    if (errorString.startsWith('exception:') || 
        errorString.startsWith('error:') ||
        errorString.contains('dioexception') ||
        errorString.contains('http status') ||
        errorString.contains('invalid type') ||
        errorString.contains('null check') ||
        errorString.contains('type \'')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return getUserFriendlyMessage(error);
  }
}
