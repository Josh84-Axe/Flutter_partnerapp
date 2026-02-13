import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for role management operations
class RoleRepository {
  final Dio _dio;

  RoleRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of roles
  Future<List<dynamic>> fetchRoles() async {
    try {
      final response = await _dio.get('/partner/roles/list/');
      final responseData = response.data;
      
      if (kDebugMode) print('📦 [RoleRepository] Fetch roles response: $responseData');

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
      
      if (kDebugMode) print('⚠️ [RoleRepository] Unexpected response format');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [RoleRepository] Fetch roles error: $e');
      rethrow;
    }
  }

  /// Fetch list of available permissions
  Future<List<dynamic>> fetchPermissions() async {
    try {
      final response = await _dio.get('/partner/permissions/list/');
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
      if (kDebugMode) print('❌ [RoleRepository] Fetch permissions error: $e');
      rethrow;
    }
  }

  /// Create role
  Future<Map<String, dynamic>?> createRole(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('📝 [RoleRepository] Creating role: ${data['name']}');
      final response = await _dio.post('/partner/roles/create/', data: data);
      if (kDebugMode) print('✅ [RoleRepository] Role created successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RoleRepository] Create role error: $e');
      rethrow;
    }
  }

  /// Get role details by slug
  Future<Map<String, dynamic>?> getRoleDetails(String slug) async {
    try {
      final response = await _dio.get('/partner/roles/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RoleRepository] Get role details error: $e');
      rethrow;
    }
  }

  /// Update role
  Future<Map<String, dynamic>?> updateRole(String slug, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('📝 [RoleRepository] Updating role: $slug');
      final response = await _dio.put('/partner/roles/$slug/update/', data: data);
      if (kDebugMode) print('✅ [RoleRepository] Role updated successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RoleRepository] Update role error: $e');
      rethrow;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String slug) async {
    try {
      if (kDebugMode) print('🗑️ [RoleRepository] Deleting role: $slug');
      await _dio.delete('/partner/roles/$slug/delete/');
      if (kDebugMode) print('✅ [RoleRepository] Role deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [RoleRepository] Delete role error: $e');
      return false;
    }
  }
}
