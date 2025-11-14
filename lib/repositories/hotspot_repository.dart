import 'package:dio/dio.dart';

/// Repository for hotspot operations (profiles and users)
class HotspotRepository {
  final Dio _dio;

  HotspotRepository({required Dio dio}) : _dio = dio;

  // ==================== Hotspot Profiles ====================

  /// Fetch list of hotspot profiles
  Future<List<dynamic>> fetchProfiles() async {
    try {
      print('🔥 [HotspotRepository] Fetching hotspot profiles');
      final response = await _dio.get('/partner/hotspot/profiles/list/');
      print('✅ [HotspotRepository] Fetch profiles response: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final profiles = responseData['data'] as List;
        print('✅ [HotspotRepository] Found ${profiles.length} profiles');
        return profiles;
      }
      
      print('⚠️ [HotspotRepository] No profiles found');
      return [];
    } catch (e) {
      print('❌ [HotspotRepository] Fetch hotspot profiles error: $e');
      rethrow;
    }
  }

  /// Create a new hotspot profile
  /// Required fields depend on backend schema
  Future<Map<String, dynamic>?> createProfile(Map<String, dynamic> profileData) async {
    try {
      print('➕ [HotspotRepository] Creating hotspot profile');
      print('📦 [HotspotRepository] Profile data: $profileData');
      final response = await _dio.post(
        '/partner/hotspot/profiles/create/',
        data: profileData,
      );
      print('✅ [HotspotRepository] Create profile response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [HotspotRepository] Create hotspot profile error: $e');
      rethrow;
    }
  }

  /// Get hotspot profile details
  Future<Map<String, dynamic>?> getProfileDetails(String profileSlug) async {
    try {
      final response = await _dio.get('/partner/hotspot/profiles/$profileSlug/detail/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get profile details error: $e');
      rethrow;
    }
  }

  /// Update hotspot profile
  Future<Map<String, dynamic>?> updateProfile(
    String profileSlug,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _dio.put(
        '/partner/hotspot/profiles/$profileSlug/update/',
        data: profileData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  /// Delete hotspot profile
  Future<bool> deleteProfile(String profileSlug) async {
    try {
      await _dio.delete('/partner/hotspot/profiles/$profileSlug/delete/');
      return true;
    } catch (e) {
      print('Delete profile error: $e');
      return false;
    }
  }

  // ==================== Hotspot Users ====================

  /// Fetch list of hotspot users
  Future<List<dynamic>> fetchUsers() async {
    try {
      print('👥 [HotspotRepository] Fetching hotspot users');
      final response = await _dio.get('/partner/hotspot/users/list/');
      print('✅ [HotspotRepository] Fetch users response: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final users = responseData['data'] as List;
        print('✅ [HotspotRepository] Found ${users.length} users');
        return users;
      }
      
      print('⚠️ [HotspotRepository] No users found');
      return [];
    } catch (e) {
      print('❌ [HotspotRepository] Fetch hotspot users error: $e');
      rethrow;
    }
  }

  /// Create a new hotspot user
  /// Required fields: username, password, and router association
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    try {
      print('➕ [HotspotRepository] Creating hotspot user');
      print('📦 [HotspotRepository] User data: $userData');
      final response = await _dio.post(
        '/partner/hotspot/users/create/',
        data: userData,
      );
      print('✅ [HotspotRepository] Create user response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [HotspotRepository] Create hotspot user error: $e');
      rethrow;
    }
  }

  /// Get hotspot user details
  Future<Map<String, dynamic>?> getUserDetails(String username) async {
    try {
      final response = await _dio.get('/partner/hotspot/users/$username/read/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get user details error: $e');
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
      print('Update user error: $e');
      rethrow;
    }
  }
}
