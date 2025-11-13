import 'package:dio/dio.dart';
import '../services/api/token_storage.dart';

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
      final response = await _dio.post(
        '/partner/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Extract tokens from response
      // API wraps tokens in: {statusCode, error, message, data: {access, refresh}}
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        print('Login error: Response data is null');
        return false;
      }

      // Extract tokens from nested data object
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data == null) {
        print('Login error: No data object in response');
        return false;
      }

      final accessToken = data['access']?.toString();
      final refreshToken = data['refresh']?.toString();

      if (accessToken != null && refreshToken != null) {
        print('Login successful - saving tokens (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        // Verify tokens were saved
        final savedToken = await _tokenStorage.getAccessToken();
        if (savedToken != null) {
          print('Tokens saved successfully (verified: ${savedToken.substring(0, 8)}...)');
        } else {
          print('ERROR: Tokens not saved correctly!');
        }
        
        return true;
      }

      print('Login error: Missing access or refresh token in response');
      return false;
    } catch (e) {
      print('Login error: $e');
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
      final response = await _dio.post(
        '/partner/register/',
        data: {
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
        },
      );

      // Registration may return tokens immediately or require email verification
      // API wraps response in: {statusCode, error, message, data: {...}}
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        print('Registration error: Response data is null');
        return false;
      }

      // Check if registration was successful
      final statusCode = responseData['statusCode'];
      final error = responseData['error'];
      
      if (statusCode == 200 && error == false) {
        print('Registration successful: ${responseData['message']}');
        
        // Extract tokens from nested data object if present
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final accessToken = data['access']?.toString();
          final refreshToken = data['refresh']?.toString();

          if (accessToken != null && refreshToken != null) {
            print('Registration returned tokens - saving (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
            await _tokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            
            // Verify tokens were saved
            final savedToken = await _tokenStorage.getAccessToken();
            if (savedToken != null) {
              print('Tokens saved successfully (verified: ${savedToken.substring(0, 8)}...)');
            } else {
              print('ERROR: Tokens not saved correctly!');
            }
          } else {
            print('Registration requires email verification - no tokens returned');
          }
        }
        
        return true;
      }

      print('Registration failed: ${responseData['message']}');
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  /// Confirm registration with OTP
  Future<Map<String, dynamic>?> confirmRegistration(String email, String code) async {
    try {
      final response = await _dio.post(
        '/partner/register-confirm/',
        data: {'email': email, 'code': code},
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Confirm registration error: $e');
      rethrow;
    }
  }

  /// Verify email with OTP
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      await _dio.post(
        '/partner/verify-email-otp/',
        data: {'email': email, 'otp': otp},
      );
      return true;
    } catch (e) {
      print('Verify email OTP error: $e');
      return false;
    }
  }

  /// Resend verification OTP
  Future<bool> resendVerifyEmailOtp(String email) async {
    try {
      await _dio.post(
        '/partner/resend-verify-email-otp/',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      print('Resend verify email OTP error: $e');
      return false;
    }
  }

  /// Check token validity
  Future<bool> checkToken() async {
    try {
      final response = await _dio.get('/partner/check-token/');
      return response.statusCode == 200;
    } catch (e) {
      print('Check token error: $e');
      return false;
    }
  }
}
