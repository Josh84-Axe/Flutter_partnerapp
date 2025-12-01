import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utility class for IP-based geolocation
class IpGeolocation {
  /// Detect user's country code from their IP address
  /// Returns ISO country code (e.g., 'GH', 'US', 'NG')
  /// Falls back to 'GH' (Ghana) if detection fails
  static Future<String> detectCountryCode() async {
    try {
      // Use ip-api.com free service (no API key required)
      // Limit: 45 requests per minute from single IP
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/?fields=countryCode'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) print('⏱️ [IpGeolocation] Request timeout');
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['countryCode'] as String?;
        
        if (countryCode != null && countryCode.isNotEmpty) {
          if (kDebugMode) print('🌍 [IpGeolocation] Detected country: $countryCode');
          return countryCode;
        }
      }
      
      if (kDebugMode) print('⚠️ [IpGeolocation] Failed to detect country, using fallback');
      return 'GH'; // Fallback to Ghana
    } catch (e) {
      if (kDebugMode) print('❌ [IpGeolocation] Error: $e, using fallback');
      return 'GH'; // Fallback to Ghana on any error
    }
  }
}
