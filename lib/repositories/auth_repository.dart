import 'package:dio/dio.dart';
import '../services/api/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

/// Repository for authentication operations
/// Uses Dio directly for API calls
class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  TokenStorage get tokenStorage => _tokenStorage;

  /// Login with email and password
  /// Returns true if login successful, false otherwise
  /// Login with email and password
  /// Returns Map with success status and optional message/data
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) print('🔐 [AuthRepository] Login request for: $email');
      final response = await _dio.post(
        '/partner/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (kDebugMode) print('✅ [AuthRepository] Login response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [AuthRepository] Login response data: ${response.data}');

      // Extract tokens from response
      // API wraps tokens in: {statusCode, error, message, data: {access, refresh}}
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        return {'success': false, 'message': 'error_empty_response'.tr()};
      }

      // Check API-level error
      if (responseData['error'] == true) {
        return {
          'success': false, 
          'message': responseData['message'] ?? 'error_login_failed'.tr(),
        };
      }

      // Extract tokens from nested data object
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        return {'success': false, 'message': 'error_invalid_format'.tr()};
      }

      final accessToken = data['access']?.toString();
      final refreshToken = data['refresh']?.toString();

      if (accessToken != null && refreshToken != null) {
        if (kDebugMode) print('✅ [AuthRepository] Login successful - saving tokens');
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'error_missing_tokens'.tr()};
    } on DioException catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Login DioError: ${e.message}');
      String errorMessage = 'error_connection'.tr();
      
      if (e.response != null) {
        // Try to extract message from error response
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? e.response?.data['detail'] ?? 'error_server'.tr(namedArgs: {'code': e.response?.statusCode.toString() ?? 'Unknown'});
        } else {
          errorMessage = 'error_server'.tr(namedArgs: {'code': e.response?.statusCode.toString() ?? 'Unknown'});
        }
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Login error: $e');
      return {'success': false, 'message': 'error_unexpected'.tr(namedArgs: {'error': e.toString()})};
    }
  }

  /// Update partner profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      if (kDebugMode) print('✏️ [AuthRepository] Updating partner profile');
      final response = await _dio.put(
        '/partner/profile/update/',
        data: profileData,
      );

      if (kDebugMode) print('✅ [AuthRepository] Update profile response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map) {
        if (responseData['error'] == true) {
           return {'success': false, 'message': responseData['message'] ?? 'Failed to update profile'};
        }
        return {'success': true, 'data': responseData['data'] ?? responseData};
      }
      
      return {'success': true, 'data': responseData};
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Update profile error: $e');
      if (e is DioException) {
         final message = e.response?.data['message'] ?? e.message ?? 'Unknown error';
         return {'success': false, 'message': message};
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Logout - clear all tokens
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasTokens();
  }

  /// Register a new partner account
  /// Returns map with 'success' (bool) and 'message' (String) for user feedback
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String email,
    required String password,
    required String password2,
    required String phone,
    required String businessName,
    required String address,
    required String city,
    required String country,
    required int numberOfRouters,
  }) async {
    try {
      if (kDebugMode) print('📝 [AuthRepository] Register request for: $email');
      final requestData = {
        'first_name': firstName,
        'email': email,
        'password': password,
        'password2': password2,
        'phone': phone,
        'entreprise_name': businessName,
        'addresse': address, // Note: API uses 'addresse' (with 'e')
        'city': city,
        'country': country,
        'number_of_router': numberOfRouters,
      };
      if (kDebugMode) print('📦 [AuthRepository] Register request data: $requestData');
      
      final response = await _dio.post('/partner/register/', data: requestData);

      if (kDebugMode) print('✅ [AuthRepository] Register response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [AuthRepository] Register response data: ${response.data}');

      // Registration may return tokens immediately or require email verification
      // API wraps response in: {statusCode, error, message, data: {...}}
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        if (kDebugMode) print('❌ [AuthRepository] Registration error: Response data is null');
        return {'success': false, 'message': 'Registration failed. Please try again.'};
      }

      // Check if registration was successful
      final statusCode = responseData['statusCode'];
      final error = responseData['error'];
      
      if (statusCode == 200 && error == false) {
        if (kDebugMode) print('✅ [AuthRepository] Registration successful: ${responseData['message']}');
        
        // Extract tokens and otp_id from nested data object if present
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final accessToken = data['access']?.toString();
          final refreshToken = data['refresh']?.toString();
          final otpId = data['otp_id']?.toString();

          if (accessToken != null && refreshToken != null) {
            if (kDebugMode) print('✅ [AuthRepository] Registration returned tokens - saving (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
            await _tokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            
            // Verify tokens were saved
            final savedToken = await _tokenStorage.getAccessToken();
            if (savedToken != null) {
              if (kDebugMode) print('✅ [AuthRepository] Tokens saved successfully (verified: ${savedToken.substring(0, 8)}...)');
            } else {
              if (kDebugMode) print('❌ [AuthRepository] ERROR: Tokens not saved correctly!');
            }
            return {'success': true, 'message': responseData['message'] ?? 'Registration successful!'};
          } else if (otpId != null) {
            if (kDebugMode) print('ℹ️ [AuthRepository] Registration requires email verification - OTP ID: $otpId');
            return {
              'success': true, 
              'message': responseData['message'] ?? 'Registration successful!',
              'otp_id': otpId
            };
          } else {
            if (kDebugMode) print('ℹ️ [AuthRepository] Registration requires email verification - no tokens or otp_id returned');
          }
        }
        
        return {'success': true, 'message': responseData['message'] ?? 'Registration successful!'};
      }

      if (kDebugMode) print('❌ [AuthRepository] Registration failed: ${responseData['message']}');
      return {'success': false, 'message': responseData['message'] ?? 'Registration failed. Please try again.'};
    } on DioException catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Registration DioException: ${e.response?.data}');
      
      // Handle validation errors from backend (400 Bad Request)
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        final errorData = e.response!.data;
        
        // Parse validation errors
        if (errorData is Map<String, dynamic>) {
          final errors = <String>[];
          
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((e) => '$key: ${e.toString()}'));
            } else {
              errors.add('$key: ${value.toString()}');
            }
          });
          
          final errorMessage = errors.join('\n');
          if (kDebugMode) print('❌ [AuthRepository] Validation errors: $errorMessage');
          return {'success': false, 'message': errorMessage};
        }
      }
      
      return {'success': false, 'message': 'Registration failed: ${e.message}'};
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Registration error: $e');
      return {'success': false, 'message': 'Registration error: ${e.toString()}'};
    }
  }

  /// Confirm registration with OTP
  Future<Map<String, dynamic>?> confirmRegistration(String email, String code) async {
    try {
      if (kDebugMode) print('✉️ [AuthRepository] Confirm registration for: $email');
      final response = await _dio.post(
        '/partner/register-confirm/',
        data: {'email': email, 'code': code},
      );
      if (kDebugMode) print('✅ [AuthRepository] Confirm registration response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Confirm registration error: $e');
      rethrow;
    }
  }

  /// Verify email with OTP
  Future<bool> verifyEmailOtp({
    required String email, 
    required String otp,
    required String otpId,
  }) async {
    try {
      if (kDebugMode) print('✉️ [AuthRepository] Verify email OTP for: $email with OTP ID: $otpId');
      final response = await _dio.post(
        '/partner/verify-email-otp/',
        data: {
          'email': email, 
          'code': otp,
          'otp_id': otpId,
        },
      );
      if (kDebugMode) print('✅ [AuthRepository] Verify email OTP response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Verify email OTP error: $e');
      return false;
    }
  }

  /// Resend verification OTP
  Future<bool> resendVerifyEmailOtp(String email) async {
    try {
      if (kDebugMode) print('✉️ [AuthRepository] Resend verify email OTP for: $email');
      final response = await _dio.post(
        '/partner/resend-verify-email-otp/',
        data: {'email': email},
      );
      if (kDebugMode) print('✅ [AuthRepository] Resend verify email OTP response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Resend verify email OTP error: $e');
      return false;
    }
  }

  /// Check token validity
  Future<bool> checkToken() async {
    try {
      if (kDebugMode) print('🔑 [AuthRepository] Checking token validity');
      final response = await _dio.get('/partner/check-token/');
      if (kDebugMode) print('✅ [AuthRepository] Token check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Check token error: $e');
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      if (kDebugMode) print('🔑 [AuthRepository] Request password reset for: $email');
      final response = await _dio.post(
        '/partner/password-reset/',
        data: {'email': email},
      );
      if (kDebugMode) print('✅ [AuthRepository] Password reset request response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Request password reset error: $e');
      return false;
    }
  }

  /// Confirm password reset with OTP
  Future<bool> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) print('🔑 [AuthRepository] Confirm password reset for: $email');
      final response = await _dio.post(
        '/partner/password-reset-confirm/',
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );
      if (kDebugMode) print('✅ [AuthRepository] Password reset confirm response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Confirm password reset error: $e');
      return false;
    }
  }

  /// Change password (for authenticated users)
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) print('🔑 [AuthRepository] Change password request');
      final response = await _dio.post(
        '/partner/password/update/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      if (kDebugMode) print('✅ [AuthRepository] Change password response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Change password error: $e');
      return false;
    }
  }

  /// Get 2FA status
  Future<bool> getTwoFactorStatus() async {
    try {
      if (kDebugMode) print('🔐 [AuthRepository] Get 2FA status');
      final response = await _dio.get('/partner/security/2fa/status/');
      if (kDebugMode) print('✅ [AuthRepository] Get 2FA status response: ${response.data}');
      
      final data = response.data;
      if (data is Map && data['data'] != null) {
        return data['data']['is_enabled'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Get 2FA status error: $e');
      return false;
    }
  }

  /// Enable 2FA
  Future<Map<String, dynamic>> enableTwoFactor() async {
    try {
      if (kDebugMode) print('🔐 [AuthRepository] Enable 2FA');
      final response = await _dio.post('/partner/security/2fa/enable/');
      if (kDebugMode) print('✅ [AuthRepository] Enable 2FA response: ${response.data}');
      
      return response.data;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Enable 2FA error: $e');
      rethrow;
    }
  }

  /// Disable 2FA
  Future<bool> disableTwoFactor() async {
    try {
      if (kDebugMode) print('🔐 [AuthRepository] Disable 2FA');
      final response = await _dio.post('/partner/security/2fa/disable/');
      if (kDebugMode) print('✅ [AuthRepository] Disable 2FA response: ${response.data}');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Disable 2FA error: $e');
      return false;
    }
  }
}
