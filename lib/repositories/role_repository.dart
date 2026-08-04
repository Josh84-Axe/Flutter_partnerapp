import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for role management operations
class RoleRepository {
  final Dio _dio;

  RoleRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of roles
  Future<List<dynamic>> fetchRoles() async {
    try {
      final response = await _dio.get('/roles/list/');
      final responseData = response.data;
      
      if (kDebugMode) debugPrint('📦 [RoleRepository] Fetch roles response: $responseData');

      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      } else if (responseData is List) {
        return responseData;
      }
      
      if (kDebugMode) debugPrint('⚠️ [RoleRepository] Unexpected response format');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Fetch roles error: $e');
      rethrow;
    }
  }

  /// Fetch list of available permissions
  Future<List<dynamic>> fetchPermissions() async {
    try {
      final response = await _dio.get('/permissions/list/');
      final responseData = response.data;
      
      if (responseData is Map) {
         if (responseData['data'] is List) {
           return responseData['data'] as List;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           return responseData['data']['results'] as List;
         } else if (responseData['results'] is List) {
           return responseData['results'] as List;
         }
      } else if (responseData is List) {
         return responseData;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Fetch permissions error: $e');
      rethrow;
    }
  }

  /// Create role
  Future<Map<String, dynamic>?> createRole(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) debugPrint('📝 [RoleRepository] Creating role: ${data['name']}');
      final response = await _dio.post('/roles/create/', data: data);
      if (kDebugMode) debugPrint('✅ [RoleRepository] Role created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Create role error: $e');
      rethrow;
    }
  }

  /// Get role details by slug
  Future<Map<String, dynamic>?> getRoleDetails(String slug) async {
    try {
      final response = await _dio.get('/roles/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Get role details error: $e');
      rethrow;
    }
  }

  /// Update role
  Future<Map<String, dynamic>?> updateRole(String slug, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) debugPrint('📝 [RoleRepository] Updating role: $slug');
      final response = await _dio.put('/roles/$slug/update/', data: data);
      if (kDebugMode) debugPrint('✅ [RoleRepository] Role updated successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Update role error: $e');
      rethrow;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String slug) async {
    try {
      if (kDebugMode) debugPrint('🗑️ [RoleRepository] Deleting role: $slug');
      await _dio.delete('/roles/$slug/delete/');
      if (kDebugMode) debugPrint('✅ [RoleRepository] Role deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [RoleRepository] Delete role error: $e');
      return false;
    }
  }
}
