import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for caching dashboard data locally
/// Uses SharedPreferences for persistence
class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'timestamp_';
  
  // Cache expiry durations
  static const Duration criticalDataExpiry = Duration(minutes: 5);
  static const Duration nonCriticalDataExpiry = Duration(minutes: 15);
  
  /// Save data to cache with timestamp
  Future<void> saveData(String key, dynamic data, {bool isCritical = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // Convert data to JSON string
      final jsonString = jsonEncode(data);
      
      // Save data and timestamp
      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      if (kDebugMode) print('💾 [CacheService] Saved $key to cache');
    } catch (e) {
      if (kDebugMode) print('❌ [CacheService] Error saving $key: $e');
    }
  }
  
  /// Get data from cache if valid
  Future<dynamic> getData(String key, {bool isCritical = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';
      
      // Check if cache exists
      if (!prefs.containsKey(cacheKey) || !prefs.containsKey(timestampKey)) {
        if (kDebugMode) print('ℹ️ [CacheService] No cache found for $key');
        return null;
      }
      
      // Check if cache is still valid
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) return null;
      
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = isCritical 
          ? criticalDataExpiry.inMilliseconds 
          : nonCriticalDataExpiry.inMilliseconds;
      
      if (cacheAge > maxAge) {
        if (kDebugMode) print('⏰ [CacheService] Cache expired for $key (age: ${cacheAge}ms)');
        return null;
      }
      
      // Get cached data
      final jsonString = prefs.getString(cacheKey);
      if (jsonString == null) return null;
      
      final data = jsonDecode(jsonString);
      if (kDebugMode) print('✅ [CacheService] Retrieved $key from cache (age: ${cacheAge}ms)');
      return data;
    } catch (e) {
      if (kDebugMode) print('❌ [CacheService] Error reading $key: $e');
      return null;
    }
  }
  
  /// Check if cache is valid without retrieving data
  Future<bool> isCacheValid(String key, {bool isCritical = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_timestampPrefix$key';
      
      if (!prefs.containsKey(timestampKey)) return false;
      
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) return false;
      
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = isCritical 
          ? criticalDataExpiry.inMilliseconds 
          : nonCriticalDataExpiry.inMilliseconds;
      
      return cacheAge <= maxAge;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear specific cache entry
  Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_timestampPrefix$key');
      if (kDebugMode) print('🗑️ [CacheService] Cleared cache for $key');
    } catch (e) {
      if (kDebugMode) print('❌ [CacheService] Error clearing $key: $e');
    }
  }
  
  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
      
      if (kDebugMode) print('🗑️ [CacheService] Cleared all cache');
    } catch (e) {
      if (kDebugMode) print('❌ [CacheService] Error clearing all cache: $e');
    }
  }
}
