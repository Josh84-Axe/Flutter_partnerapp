import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for JWT access and refresh tokens
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    print('TokenStorage: Saving tokens (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    print('TokenStorage: Tokens saved successfully');
  }

  /// Get the access token
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      print('TokenStorage: Retrieved access token (${token.substring(0, 8)}...)');
    } else {
      print('TokenStorage: No access token found');
    }
    return token;
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    if (token != null) {
      print('TokenStorage: Retrieved refresh token (${token.substring(0, 8)}...)');
    } else {
      print('TokenStorage: No refresh token found');
    }
    return token;
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null && refresh != null;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
