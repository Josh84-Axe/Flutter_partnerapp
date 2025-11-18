import 'package:dio/dio.dart';
import '../services/api/token_storage.dart';
import 'package:flutter/foundation.dart';

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

  /// Login with email and password
  /// Returns true if login successful, false otherwise
  Future<bool> login({
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
        if (kDebugMode) print('❌ [AuthRepository] Login error: Response data is null');
        return false;
      }

      // Extract tokens from nested data object
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        if (kDebugMode) print('❌ [AuthRepository] Login error: No data object in response');
        return false;
      }

      final accessToken = data['access']?.toString();
      final refreshToken = data['refresh']?.toString();

      if (accessToken != null && refreshToken != null) {
        if (kDebugMode) print('✅ [AuthRepository] Login successful - saving tokens (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
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
        
        return true;
      }

      if (kDebugMode) print('❌ [AuthRepository] Login error: Missing access or refresh token in response');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Login error: $e');
      return false;
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
  /// Returns true if registration successful, false otherwise
  Future<bool> register({
    required String firstName,
    required String email,
    required String password,
    String? phone,
    String? businessName,
    String? address,
    String? city,
    String? country,
    int? numberOfRouters,
  }) async {
    try {
      if (kDebugMode) print('📝 [AuthRepository] Register request for: $email');
      final requestData = {
        'first_name': firstName,
        'email': email,
        'password': password,
        'password2': password, // Confirm password with same value
        if (phone != null) 'phone': phone,
        if (businessName != null) 'entreprise_name': businessName,
        if (address != null) 'addresse': address, // Note: API uses 'addresse' (with 'e')
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (numberOfRouters != null) 'number_of_router': numberOfRouters,
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
        return false;
      }

      // Check if registration was successful
      final statusCode = responseData['statusCode'];
      final error = responseData['error'];
      
      if (statusCode == 200 && error == false) {
        if (kDebugMode) print('✅ [AuthRepository] Registration successful: ${responseData['message']}');
        
        // Extract tokens from nested data object if present
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final accessToken = data['access']?.toString();
          final refreshToken = data['refresh']?.toString();

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
          } else {
            if (kDebugMode) print('ℹ️ [AuthRepository] Registration requires email verification - no tokens returned');
          }
        }
        
        return true;
      }

      if (kDebugMode) print('❌ [AuthRepository] Registration failed: ${responseData['message']}');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthRepository] Registration error: $e');
      return false;
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
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      if (kDebugMode) print('✉️ [AuthRepository] Verify email OTP for: $email');
      final response = await _dio.post(
        '/partner/verify-email-otp/',
        data: {'email': email, 'code': otp}, // Backend expects 'code' field, not 'otp'
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
        '/partner/change-password/',
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
}
