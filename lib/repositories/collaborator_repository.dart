import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for collaborator and role management operations
class CollaboratorRepository {
  final Dio _dio;

  CollaboratorRepository({required Dio dio}) : _dio = dio;

  // ==================== Collaborators ====================

  /// Fetch list of collaborators
  Future<List<dynamic>> fetchCollaborators() async {
    try {
      final response = await _dio.get('/partner/collaborators/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch collaborators error: $e');
      rethrow;
    }
  }

  /// Create collaborator
  Future<Map<String, dynamic>?> createCollaborator(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/collaborators/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create collaborator error: $e');
      rethrow;
    }
  }

  /// Assign role to collaborator
  Future<bool> assignRole(String username, Map<String, dynamic> roleData) async {
    try {
      await _dio.post(
        '/partner/collaborators/$username/assign-role/',
        data: roleData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Assign role error: $e');
      return false;
    }
  }

  /// Update collaborator role
  Future<bool> updateRole(String username, Map<String, dynamic> roleData) async {
    try {
      await _dio.put(
        '/partner/collaborators/$username/update-role/',
        data: roleData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Update role error: $e');
      return false;
    }
  }

  /// Delete collaborator
  Future<bool> deleteCollaborator(String username) async {
    try {
      await _dio.delete('/partner/collaborators/$username/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete collaborator error: $e');
      return false;
    }
  }

  /// Get collaborator details
  Future<Map<String, dynamic>?> fetchCollaboratorDetails(String username) async {
    try {
      if (kDebugMode) print('📋 [CollaboratorRepository] Fetching details for: $username');
      final response = await _dio.get('/partner/collaborators/$username/details/');
      if (kDebugMode) print('✅ [CollaboratorRepository] Details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [CollaboratorRepository] Fetch details error: $e');
      rethrow;
    }
  }

  /// Update collaborator
  Future<Map<String, dynamic>?> updateCollaborator(String username, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('✏️ [CollaboratorRepository] Updating collaborator: $username');
      if (kDebugMode) print('📦 [CollaboratorRepository] Update data: $data');
      final response = await _dio.put('/partner/collaborators/$username/update/', data: data);
      if (kDebugMode) print('✅ [CollaboratorRepository] Update response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [CollaboratorRepository] Update error: $e');
      rethrow;
    }
  }

  /// Assign router to collaborator
  Future<bool> assignRouter(String username, Map<String, dynamic> routerData) async {
    try {
      if (kDebugMode) print('🔗 [CollaboratorRepository] Assigning router to: $username');
      if (kDebugMode) print('📦 [CollaboratorRepository] Router data: $routerData');
      await _dio.post(
        '/partner/collaborators/$username/assign-router/',
        data: routerData,
      );
      if (kDebugMode) print('✅ [CollaboratorRepository] Router assigned successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [CollaboratorRepository] Assign router error: $e');
      return false;
    }
  }

  /// Remove router from collaborator
  Future<bool> removeRouter(String username, String routerId) async {
    try {
      if (kDebugMode) print('🔓 [CollaboratorRepository] Removing router from: $username');
      await _dio.delete('/partner/collaborators/$username/routers/$routerId/');
      if (kDebugMode) print('✅ [CollaboratorRepository] Router removed successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [CollaboratorRepository] Remove router error: $e');
      return false;
    }
  }

  // ==================== Roles ====================

  /// Fetch list of roles
  Future<List<dynamic>> fetchRoles() async {
    try {
      final response = await _dio.get('/partner/roles/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch roles error: $e');
      rethrow;
    }
  }

  /// Create role
  Future<Map<String, dynamic>?> createRole(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/roles/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create role error: $e');
      rethrow;
    }
  }

  /// Get role details
  Future<Map<String, dynamic>?> getRoleDetails(String slug) async {
    try {
      final response = await _dio.get('/partner/roles/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get role details error: $e');
      rethrow;
    }
  }

  /// Update role
  Future<Map<String, dynamic>?> updateRole2(String slug, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/partner/roles/$slug/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Update role error: $e');
      rethrow;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String slug) async {
    try {
      await _dio.delete('/partner/roles/$slug/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete role error: $e');
      return false;
    }
  }
}
