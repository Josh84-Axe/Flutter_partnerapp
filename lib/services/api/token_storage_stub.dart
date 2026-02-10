import 'package:flutter/foundation.dart';


// Default implementation that throws UnimplementedError
// This is used as a fallback but should be overridden by platform implementations
class TokenStorageImpl implements TokenStorage {
  TokenStorageImpl({dynamic storage});

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) {
    throw UnimplementedError('saveTokens() has not been implemented.');
  }

  @override
  Future<String?> getAccessToken() {
    throw UnimplementedError('getAccessToken() has not been implemented.');
  }

  @override
  Future<String?> getRefreshToken() {
    throw UnimplementedError('getRefreshToken() has not been implemented.');
  }

  @override
  Future<bool> hasTokens() {
    throw UnimplementedError('hasTokens() has not been implemented.');
  }

  @override
  Future<void> clearTokens() {
    throw UnimplementedError('clearTokens() has not been implemented.');
  }
}
