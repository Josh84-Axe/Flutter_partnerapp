import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class PinVault {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _vaultKey = 'smart_access_vault';
  static const int _maxStrikes = 5;

  /// Derive a 256-bit AES key from the 6-digit PIN and a Salt using iterative hashing
  static String _deriveKey(String pin, String salt) {
    List<int> bytes = utf8.encode(pin + salt);
    // 10,000 iterations for key stretching
    for (var i = 0; i < 10000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Encode(bytes);
  }

  /// Generate a cryptographically secure random salt
  static String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  /// Check if a PIN is currently configured
  static Future<bool> isPinConfigured() async {
    try {
      final vaultData = await _storage.read(key: _vaultKey);
      return vaultData != null && vaultData.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('PinVault: Error checking PIN: $e');
      return false;
    }
  }

  /// Save the user's email and password, mathematically encrypted using the PIN
  static Future<void> saveCredentials(String email, String password, String pin) async {
    try {
      final salt = _generateSalt();
      final keyString = _deriveKey(pin, salt);
      final key = encrypt.Key.fromBase64(keyString);
      final iv = encrypt.IV.fromSecureRandom(16);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      
      final payload = jsonEncode({'email': email, 'password': password});
      final encrypted = encrypter.encrypt(payload, iv: iv);
      
      final vaultMap = {
        'salt': salt,
        'iv': iv.base64,
        'data': encrypted.base64,
        'strikes': 0,
      };
      
      await _storage.write(key: _vaultKey, value: jsonEncode(vaultMap));
      if (kDebugMode) print('PinVault: Credentials encrypted and saved successfully.');
    } catch (e) {
      if (kDebugMode) print('PinVault: Error saving credentials: $e');
    }
  }

  /// Verify the entered PIN by attempting to decrypt the vault. Return {email, password} on success.
  static Future<Map<String, String>?> getCredentialsWithPin(String pin) async {
    try {
      final vaultString = await _storage.read(key: _vaultKey);
      if (vaultString == null) return null;
      
      final vaultMap = jsonDecode(vaultString) as Map<String, dynamic>;
      final salt = vaultMap['salt'] as String;
      final ivBase64 = vaultMap['iv'] as String;
      final encryptedBase64 = vaultMap['data'] as String;
      int strikes = vaultMap['strikes'] as int? ?? 0;
      
      if (strikes >= _maxStrikes) {
        if (kDebugMode) print('PinVault: Maximum strikes reached. Vault is locked/cleared.');
        await clearVault();
        return null;
      }

      final keyString = _deriveKey(pin, salt);
      final key = encrypt.Key.fromBase64(keyString);
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      
      try {
        final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
        final payload = jsonDecode(decrypted) as Map<String, dynamic>;
        
        // Reset strikes on successful decryption
        if (strikes > 0) {
          vaultMap['strikes'] = 0;
          await _storage.write(key: _vaultKey, value: jsonEncode(vaultMap));
        }
        
        return {
          'email': payload['email'].toString(),
          'password': payload['password'].toString(),
        };
      } catch (e) {
        // Decryption failed -> Wrong PIN
        strikes++;
        vaultMap['strikes'] = strikes;
        
        if (strikes >= _maxStrikes) {
          if (kDebugMode) print('PinVault: Too many incorrect PIN attempts. Clearing vault.');
          await clearVault();
        } else {
          if (kDebugMode) print('PinVault: Incorrect PIN. Strike $strikes of $_maxStrikes.');
          await _storage.write(key: _vaultKey, value: jsonEncode(vaultMap));
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('PinVault: Error retrieving credentials: $e');
    }
    return null;
  }

  /// Clear the saved credentials (e.g., on logout or after 5 incorrect PIN attempts)
  static Future<void> clearVault() async {
    try {
      await _storage.delete(key: _vaultKey);
      // Clean up legacy keys if they exist
      await _storage.delete(key: 'smart_access_pin_hash');
      await _storage.delete(key: 'smart_access_email');
      await _storage.delete(key: 'smart_access_password');
      if (kDebugMode) print('PinVault: Vault cleared.');
    } catch (e) {
      if (kDebugMode) print('PinVault: Error clearing vault: $e');
    }
  }
}
