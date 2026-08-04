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
      if (kDebugMode) debugPrint('🔥 [HotspotRepository] Fetching hotspot profiles');
      final response = await _dio.get('/hotspot/profiles/list/');
      if (kDebugMode) debugPrint('✅ [HotspotRepository] Fetch profiles response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final profiles = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${profiles.length} profiles (nested)');
          return profiles;
        } else if (responseData['data'] is List) {
          final profiles = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${profiles.length} profiles (flat)');
          return profiles;
        } else if (responseData['results'] is List) {
          final profiles = responseData['results'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${profiles.length} profiles (results)');
          return profiles;
        }
      }
      
      if (kDebugMode) debugPrint('⚠️ [HotspotRepository] No profiles found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Fetch hotspot profiles error: $e');
      rethrow;
    }
  }

  /// Fetch list of hotspot users
  Future<List<dynamic>> fetchUsers() async {
    try {
      if (kDebugMode) debugPrint('👥 [HotspotRepository] Fetching hotspot users');
      final response = await _dio.get('/hotspot/users/paginate-list/');
      if (kDebugMode) debugPrint('✅ [HotspotRepository] Fetch users response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final users = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${users.length} users (nested)');
          return users;
        } else if (responseData['data'] is List) {
          final users = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${users.length} users (flat)');
          return users;
        } else if (responseData['results'] is List) {
          final users = responseData['results'] as List;
          if (kDebugMode) debugPrint('✅ [HotspotRepository] Found ${users.length} users (results)');
          return users;
        }
      }
      
      if (kDebugMode) debugPrint('⚠️ [HotspotRepository] No users found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Fetch hotspot users error: $e');
      rethrow;
    }
  }

  /// Create hotspot profile
  Future<Map<String, dynamic>?> createProfile(Map<String, dynamic> profileData) async {
    try {
      if (kDebugMode) debugPrint('➕ [HotspotRepository] Creating hotspot profile');
      final response = await _dio.post(
        '/hotspot/profiles/create/',
        data: profileData,
      );
      if (kDebugMode) debugPrint('✅ [HotspotRepository] Profile created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Create profile error: $e');
      rethrow;
    }
  }

  /// Update hotspot profile
  Future<Map<String, dynamic>?> updateProfile(
    String profileSlug,
    Map<String, dynamic> profileData,
  ) async {
    try {
      if (kDebugMode) debugPrint('✏️ [HotspotRepository] Updating hotspot profile: $profileSlug');
      final response = await _dio.put(
        '/hotspot/profiles/$profileSlug/update/',
        data: profileData,
      );
      if (kDebugMode) debugPrint('✅ [HotspotRepository] Profile updated successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Update profile error: $e');
      rethrow;
    }
  }

  /// Delete hotspot profile
  Future<Map<String, dynamic>> deleteProfile(String profileSlug) async {
    try {
      if (kDebugMode) debugPrint('🗑️ [HotspotRepository] Deleting hotspot profile: $profileSlug');
      final response = await _dio.delete('/hotspot/profiles/$profileSlug/delete/');
      if (kDebugMode) debugPrint('✅ [HotspotRepository] Profile deleted successfully');
      return response.data as Map<String, dynamic>? ?? {'message': 'Profile deleted successfully'};
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Delete profile error: $e');
      rethrow;
    }
  }

  // ==================== Hotspot Users ====================

  /// Create hotspot user
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    try {
      if (kDebugMode) debugPrint('➕ [HotspotRepository] Creating hotspot user with payload: $userData');
      final response = await _dio.post(
        '/customers/create/',
        data: userData,
      );
      if (kDebugMode) debugPrint('✅ [HotspotRepository] User created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Create user error: $e');
      rethrow;
    }
  }

  /// Get hotspot user details
  Future<Map<String, dynamic>?> getUserDetails(String username) async {
    try {
      final response = await _dio.get('/hotspot/users/$username/read/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get user details error: $e');
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
        '/hotspot/users/$username/update/',
        data: userData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update user error: $e');
      rethrow;
    }
  }
  /// Delete hotspot user
  Future<bool> deleteUser(String username) async {
    try {
      if (kDebugMode) debugPrint('🗑️ [HotspotRepository] Deleting hotspot user: $username');
      await _dio.delete('/hotspot/users/$username/delete/');
      if (kDebugMode) debugPrint('✅ [HotspotRepository] User deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [HotspotRepository] Delete user error: $e');
      rethrow;
    }
  }
}
