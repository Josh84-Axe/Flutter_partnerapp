import 'package:flutter/foundation.dart';

class TokenStorage {
  TokenStorage({dynamic storage});

  Future<void> saveTokens({required String accessToken, required String refreshToken}) {
    throw UnimplementedError('saveTokens() has not been implemented.');
  }

  Future<String?> getAccessToken() {
    throw UnimplementedError('getAccessToken() has not been implemented.');
  }

  Future<String?> getRefreshToken() {
    throw UnimplementedError('getRefreshToken() has not been implemented.');
  }

  Future<bool> hasTokens() {
    throw UnimplementedError('hasTokens() has not been implemented.');
  }

  Future<void> clearTokens() {
    throw UnimplementedError('clearTokens() has not been implemented.');
  }
}
