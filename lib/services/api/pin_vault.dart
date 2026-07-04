import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class PinVault {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _keyPinHash = 'smart_access_pin_hash';
  static const String _keyEmail = 'smart_access_email';
  static const String _keyPassword = 'smart_access_password';

  /// Hash the PIN before storing it, so we don't store the raw PIN even in secure storage
  static String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a PIN is currently configured
  static Future<bool> isPinConfigured() async {
    try {
      final hash = await _storage.read(key: _keyPinHash);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('PinVault: Error checking PIN: $e');
      return false;
    }
  }

  /// Save the user's email, password, and the newly defined 6-digit PIN
  static Future<void> saveCredentials(String email, String password, String pin) async {
    try {
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: password);
      await _storage.write(key: _keyPinHash, value: _hashPin(pin));
      if (kDebugMode) print('PinVault: Credentials saved successfully.');
    } catch (e) {
      if (kDebugMode) print('PinVault: Error saving credentials: $e');
    }
  }

  /// Verify the entered PIN. If it matches the stored hash, return the {email, password} map.
  static Future<Map<String, String>?> getCredentialsWithPin(String pin) async {
    try {
      final storedHash = await _storage.read(key: _keyPinHash);
      if (storedHash == null || storedHash != _hashPin(pin)) {
        return null; // Invalid PIN
      }
      
      final email = await _storage.read(key: _keyEmail);
      final password = await _storage.read(key: _keyPassword);
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    } catch (e) {
      if (kDebugMode) print('PinVault: Error retrieving credentials: $e');
    }
    return null;
  }

  /// Clear the saved credentials (e.g., on logout or manual disable)
  static Future<void> clearVault() async {
    try {
      await _storage.delete(key: _keyPinHash);
      await _storage.delete(key: _keyEmail);
      await _storage.delete(key: _keyPassword);
      if (kDebugMode) print('PinVault: Vault cleared.');
    } catch (e) {
      if (kDebugMode) print('PinVault: Error clearing vault: $e');
    }
  }
}
