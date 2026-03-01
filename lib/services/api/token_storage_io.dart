import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage _secureStorage;

  TokenStorage({FlutterSecureStorage? storage})
      : _secureStorage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    if (kDebugMode) print('TokenStorage (IO): Saving tokens');
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return access != null && refresh != null;
  }

  Future<void> clearTokens() async {
    try {
      await _secureStorage.deleteAll();
      if (kDebugMode) print('TokenStorage (IO): Tokens cleared');
    } catch (e) {
      if (kDebugMode) print('TokenStorage (IO): Error clearing tokens: $e');
    }
  }
}
