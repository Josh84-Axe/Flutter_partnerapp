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
        '/partner/password/update/',
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
  /// Returns reset_token if successful, null otherwise
  Future<String?> verifyPasswordResetOtp({
    required String otp,
    required String otpId,
  }) async {
    try {
      if (kDebugMode) print('🔐 [PasswordRepository] Verifying OTP with OTP ID: $otpId, Code: $otp');
      final response = await _dio.post(
        '/partner/password-reset/verify-otp/',
        data: {
          'otp_id': otpId,
          'code': otp,
        },
      );
      
      if (kDebugMode) print('✅ [PasswordRepository] OTP verification response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract reset_token from data field
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final resetToken = data['reset_token'] as String?;
        
        if (resetToken != null) {
          if (kDebugMode) print('✅ [PasswordRepository] Reset token received: ${resetToken.substring(0, 20)}...');
          return resetToken;
        }
      }
      
      if (kDebugMode) print('⚠️ [PasswordRepository] No reset token in response');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [PasswordRepository] Verify password reset OTP error: $e');
      return null;
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
