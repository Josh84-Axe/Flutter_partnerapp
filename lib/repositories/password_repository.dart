import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for password management operations
class PasswordRepository {
  final Dio _dio;

  PasswordRepository({required Dio dio}) : _dio = dio;

  /// Change password
  Future<bool> changePassword(Map<String, dynamic> passwordData) async {
    try {
      await _dio.post(
        '/partner/change-password/',
        data: passwordData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Change password error: $e');
      return false;
    }
  }

  /// Request password reset OTP
  Future<bool> requestPasswordResetOtp(String email) async {
    try {
      await _dio.post(
        '/partner/password-reset/request-otp/',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Request password reset OTP error: $e');
      return false;
    }
  }

  /// Verify password reset OTP
  Future<bool> verifyPasswordResetOtp(String email, String otp) async {
    try {
      await _dio.post(
        '/partner/password-reset/verify-otp/',
        data: {'email': email, 'otp': otp},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Verify password reset OTP error: $e');
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(Map<String, dynamic> resetData) async {
    try {
      await _dio.post(
        '/partner/password-reset/update-password/',
        data: resetData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Reset password error: $e');
      return false;
    }
  }
  
  /// Resend password reset OTP
  Future<bool> resendPasswordResetOtp(String email) async {
    try {
      await _dio.post(
        '/partner/password-reset/resend-request-otp/',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Resend password reset OTP error: $e');
      return false;
    }
  }
}
