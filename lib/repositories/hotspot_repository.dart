import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for hotspot operations (profiles and users)
class HotspotRepository {
  final Dio _dio;

  HotspotRepository({required Dio dio}) : _dio = dio;

  // ==================== Hotspot Profiles ====================

  /// Fetch list of hotspot profiles
  Future<List<dynamic>> fetchProfiles() async {
    try {
      if (kDebugMode) print('🔥 [HotspotRepository] Fetching hotspot profiles');
      final response = await _dio.get('/partner/hotspot/profiles/list/');
      if (kDebugMode) print('✅ [HotspotRepository] Fetch profiles response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final profiles = responseData['data']['results'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${profiles.length} profiles (nested)');
          return profiles;
        } else if (responseData['data'] is List) {
          final profiles = responseData['data'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${profiles.length} profiles (flat)');
          return profiles;
        } else if (responseData['results'] is List) {
          final profiles = responseData['results'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${profiles.length} profiles (results)');
          return profiles;
        }
      }
      
      if (kDebugMode) print('⚠️ [HotspotRepository] No profiles found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Fetch hotspot profiles error: $e');
      rethrow;
    }
  }

  /// Fetch list of hotspot users
  Future<List<dynamic>> fetchUsers() async {
    try {
      if (kDebugMode) print('👥 [HotspotRepository] Fetching hotspot users');
      final response = await _dio.get('/partner/hotspot/users/paginate-list/');
      if (kDebugMode) print('✅ [HotspotRepository] Fetch users response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final users = responseData['data']['results'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${users.length} users (nested)');
          return users;
        } else if (responseData['data'] is List) {
          final users = responseData['data'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${users.length} users (flat)');
          return users;
        } else if (responseData['results'] is List) {
          final users = responseData['results'] as List;
          if (kDebugMode) print('✅ [HotspotRepository] Found ${users.length} users (results)');
          return users;
        }
      }
      
      if (kDebugMode) print('⚠️ [HotspotRepository] No users found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Fetch hotspot users error: $e');
      rethrow;
    }
  }

  /// Create hotspot profile
  Future<Map<String, dynamic>?> createProfile(Map<String, dynamic> profileData) async {
    try {
      if (kDebugMode) print('➕ [HotspotRepository] Creating hotspot profile');
      final response = await _dio.post(
        '/partner/hotspot/profiles/create/',
        data: profileData,
      );
      if (kDebugMode) print('✅ [HotspotRepository] Profile created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Create profile error: $e');
      rethrow;
    }
  }

  /// Update hotspot profile
  Future<Map<String, dynamic>?> updateProfile(
    String profileSlug,
    Map<String, dynamic> profileData,
  ) async {
    try {
      if (kDebugMode) print('✏️ [HotspotRepository] Updating hotspot profile: $profileSlug');
      final response = await _dio.put(
        '/partner/hotspot/profiles/$profileSlug/update/',
        data: profileData,
      );
      if (kDebugMode) print('✅ [HotspotRepository] Profile updated successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Update profile error: $e');
      rethrow;
    }
  }

  /// Delete hotspot profile
  Future<Map<String, dynamic>> deleteProfile(String profileSlug) async {
    try {
      if (kDebugMode) print('🗑️ [HotspotRepository] Deleting hotspot profile: $profileSlug');
      final response = await _dio.delete('/partner/hotspot/profiles/$profileSlug/delete/');
      if (kDebugMode) print('✅ [HotspotRepository] Profile deleted successfully');
      return response.data as Map<String, dynamic>? ?? {'message': 'Profile deleted successfully'};
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Delete profile error: $e');
      rethrow;
    }
  }

  // ==================== Hotspot Users ====================

  /// Create hotspot user
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    try {
      if (kDebugMode) print('➕ [HotspotRepository] Creating hotspot user with payload: $userData');
      final response = await _dio.post(
        '/partner/customers/create/',
        data: userData,
      );
      if (kDebugMode) print('✅ [HotspotRepository] User created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Create user error: $e');
      rethrow;
    }
  }

  /// Get hotspot user details
  Future<Map<String, dynamic>?> getUserDetails(String username) async {
    try {
      final response = await _dio.get('/partner/hotspot/users/$username/read/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get user details error: $e');
      rethrow;
    }
  }

  /// Update hotspot user
  Future<Map<String, dynamic>?> updateUser(
    String username,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.put(
        '/partner/hotspot/users/$username/update/',
        data: userData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Update user error: $e');
      rethrow;
    }
  }
  /// Delete hotspot user
  Future<bool> deleteUser(String username) async {
    try {
      if (kDebugMode) print('🗑️ [HotspotRepository] Deleting hotspot user: $username');
      await _dio.delete('/partner/hotspot/users/$username/delete/');
      if (kDebugMode) print('✅ [HotspotRepository] User deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [HotspotRepository] Delete user error: $e');
      rethrow;
    }
  }
}
