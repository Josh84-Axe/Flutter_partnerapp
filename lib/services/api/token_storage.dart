import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for JWT access and refresh tokens
/// Uses SharedPreferences for web (reliable) and FlutterSecureStorage for mobile (secure)
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage? _secureStorage;
  SharedPreferences? _prefs;

  TokenStorage({FlutterSecureStorage? storage})
      : _secureStorage = kIsWeb ? null : (storage ?? const FlutterSecureStorage());

  /// Initialize SharedPreferences for web
  Future<void> _ensurePrefsInitialized() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kDebugMode) print('TokenStorage: Saving tokens (access: ${accessToken.substring(0, 8)}..., refresh: ${refreshToken.substring(0, 8)}...)');
    
    if (kIsWeb) {
      await _ensurePrefsInitialized();
      await Future.wait([
        _prefs!.setString(_accessTokenKey, accessToken),
        _prefs!.setString(_refreshTokenKey, refreshToken),
      ]);
    } else {
      await Future.wait([
        _secureStorage!.write(key: _accessTokenKey, value: accessToken),
        _secureStorage!.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      // Add a small delay to ensure tokens are persisted on desktop platforms
      // FlutterSecureStorage on Windows/Linux/macOS has async write issues
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (kDebugMode) print('TokenStorage: Tokens saved successfully');
  }

  /// Get the access token
  Future<String?> getAccessToken() async {
    String? token;
    
    if (kIsWeb) {
      await _ensurePrefsInitialized();
      token = _prefs!.getString(_accessTokenKey);
    } else {
      token = await _secureStorage!.read(key: _accessTokenKey);
    }
    
    if (token != null) {
      if (kDebugMode) print('TokenStorage: Retrieved access token (${token.substring(0, 8)}...)');
    } else {
      if (kDebugMode) print('TokenStorage: No access token found');
    }
    return token;
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    String? token;
    
    if (kIsWeb) {
      await _ensurePrefsInitialized();
      token = _prefs!.getString(_refreshTokenKey);
    } else {
      token = await _secureStorage!.read(key: _refreshTokenKey);
    }
    
    if (token != null) {
      if (kDebugMode) print('TokenStorage: Retrieved refresh token (${token.substring(0, 8)}...)');
    } else {
      if (kDebugMode) print('TokenStorage: No refresh token found');
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
    if (kIsWeb) {
      await _ensurePrefsInitialized();
      await Future.wait([
        _prefs!.remove(_accessTokenKey),
        _prefs!.remove(_refreshTokenKey),
      ]);
    } else {
      await _secureStorage!.deleteAll();
    }
  }
}
