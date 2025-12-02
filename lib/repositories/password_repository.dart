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
  /// Returns data containing otp_id if successful
  Future<Map<String, dynamic>?> requestPasswordResetOtp(String email) async {
    try {
      if (kDebugMode) print('🔐 [PasswordRepository] Requesting password reset OTP for: $email');
      final response = await _dio.post(
        '/partner/password-reset/request-otp/',
        data: {'email': email},
      );
      
      if (kDebugMode) print('✅ [PasswordRepository] OTP request response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract data field if wrapped
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (kDebugMode) print('✅ [PasswordRepository] Extracted OTP data: $data');
        return data;
      }
      
      return responseData;
    } catch (e) {
      if (kDebugMode) print('❌ [PasswordRepository] Request password reset OTP error: $e');
      return null;
    }
  }

  /// Verify password reset OTP
  /// Requires otp_id from the request response
  Future<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
    required String otpId,
  }) async {
    try {
      if (kDebugMode) print('🔐 [PasswordRepository] Verifying OTP for: $email with OTP ID: $otpId');
      await _dio.post(
        '/partner/password-reset/verify-otp/',
        data: {
          'email': email,
          'otp': otp,
          'otp_id': otpId,
        },
      );
      if (kDebugMode) print('✅ [PasswordRepository] OTP verified successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [PasswordRepository] Verify password reset OTP error: $e');
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
