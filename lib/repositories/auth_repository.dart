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
      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return false;
      }

      final accessToken = data['access']?.toString();
      final refreshToken = data['refresh']?.toString();

      if (accessToken != null && refreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      }

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
    String? address,
    String? city,
    String? country,
    int? numberOfRouters,
  }) async {
    try {
      final response = await _dio.post(
        '/partner/register-init/',
        data: {
          'first_name': firstName,
          'email': email,
          'password': password,
          'password2': password, // Confirm password with same value
          if (phone != null) 'phone': phone,
          if (address != null) 'addresse': address, // Note: API uses 'addresse' (with 'e')
          if (city != null) 'city': city,
          if (country != null) 'country': country,
          if (numberOfRouters != null) 'number_of_router': numberOfRouters,
        },
      );

      // Registration may return tokens immediately or require email verification
      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return false;
      }

      // If tokens are provided, save them
      final accessToken = data['access']?.toString();
      final refreshToken = data['refresh']?.toString();

      if (accessToken != null && refreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
}
