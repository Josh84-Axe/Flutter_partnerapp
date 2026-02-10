import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  SharedPreferences? _prefs;

  TokenStorage({dynamic storage}); // Ignore storage arg on web

  Future<void> _ensurePrefsInitialized() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    if (kDebugMode) print('TokenStorage (Web): Saving tokens');
    await _ensurePrefsInitialized();
    await Future.wait([
      _prefs!.setString(_accessTokenKey, accessToken),
      _prefs!.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    await _ensurePrefsInitialized();
    return _prefs!.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    await _ensurePrefsInitialized();
    return _prefs!.getString(_refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    await _ensurePrefsInitialized();
    final access = _prefs!.getString(_accessTokenKey);
    final refresh = _prefs!.getString(_refreshTokenKey);
    return access != null && refresh != null;
  }

  Future<void> clearTokens() async {
    await _ensurePrefsInitialized();
    await Future.wait([
      _prefs!.remove(_accessTokenKey),
      _prefs!.remove(_refreshTokenKey),
    ]);
    if (kDebugMode) print('TokenStorage (Web): Tokens cleared');
  }
}
