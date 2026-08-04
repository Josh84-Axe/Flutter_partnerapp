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
      final response = await _dio.get('/collaborators/list/');
      final responseData = response.data;
      
      if (responseData is Map) {
         if (responseData['data'] is List) {
           return responseData['data'] as List;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           return responseData['data']['results'] as List;
         }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch collaborators error: $e');
      rethrow;
    }
  }

  /// Create collaborator
  Future<Map<String, dynamic>?> createCollaborator(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/collaborators/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create collaborator error: $e');
      rethrow;
    }
  }

  /// Assign role to collaborator
  Future<bool> assignRole(String username, Map<String, dynamic> roleData) async {
    try {
      await _dio.post(
        '/collaborators/$username/assign-role/',
        data: roleData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Assign role error: $e');
      return false;
    }
  }

  /// Update collaborator role
  Future<bool> updateRole(String username, Map<String, dynamic> roleData) async {
    try {
      await _dio.put(
        '/collaborators/$username/update-role/',
        data: roleData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Update role error: $e');
      return false;
    }
  }

  /// Delete collaborator
  Future<bool> deleteCollaborator(String username) async {
    try {
      await _dio.delete('/collaborators/$username/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete collaborator error: $e');
      return false;
    }
  }

  /// Get collaborator details
  Future<Map<String, dynamic>?> fetchCollaboratorDetails(String username) async {
    try {
      if (kDebugMode) debugPrint('📋 [CollaboratorRepository] Fetching details for: $username');
      final response = await _dio.get('/collaborators/$username/details/');
      if (kDebugMode) debugPrint('✅ [CollaboratorRepository] Details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [CollaboratorRepository] Fetch details error: $e');
      rethrow;
    }
  }

  /// Update collaborator
  Future<Map<String, dynamic>?> updateCollaborator(String username, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) debugPrint('✏️ [CollaboratorRepository] Updating collaborator: $username');
      if (kDebugMode) debugPrint('📦 [CollaboratorRepository] Update data: $data');
      final response = await _dio.put('/collaborators/$username/update/', data: data);
      if (kDebugMode) debugPrint('✅ [CollaboratorRepository] Update response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [CollaboratorRepository] Update error: $e');
      rethrow;
    }
  }

  /// Assign router to collaborator
  Future<bool> assignRouter(String username, Map<String, dynamic> routerData) async {
    try {
      if (kDebugMode) debugPrint('🔗 [CollaboratorRepository] Assigning router to: $username');
      if (kDebugMode) debugPrint('📦 [CollaboratorRepository] Router data: $routerData');
      await _dio.post(
        '/collaborators/$username/assign-router/',
        data: routerData,
      );
      if (kDebugMode) debugPrint('✅ [CollaboratorRepository] Router assigned successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [CollaboratorRepository] Assign router error: $e');
      return false;
    }
  }

  /// Remove router from collaborator
  Future<bool> removeRouter(String username, String routerId) async {
    try {
      if (kDebugMode) debugPrint('🔓 [CollaboratorRepository] Removing router from: $username');
      await _dio.delete('/collaborators/$username/routers/$routerId/');
      if (kDebugMode) debugPrint('✅ [CollaboratorRepository] Router removed successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [CollaboratorRepository] Remove router error: $e');
      return false;
    }
  }

  // ==================== Roles ====================

  /// Fetch list of roles
  Future<List<dynamic>> fetchRoles() async {
    try {
      final response = await _dio.get('/roles/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch roles error: $e');
      rethrow;
    }
  }

  /// Create role
  Future<Map<String, dynamic>?> createRole(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/roles/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create role error: $e');
      rethrow;
    }
  }

  /// Get role details
  Future<Map<String, dynamic>?> getRoleDetails(String slug) async {
    try {
      final response = await _dio.get('/roles/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get role details error: $e');
      rethrow;
    }
  }

  /// Update role
  Future<Map<String, dynamic>?> updateRole2(String slug, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/roles/$slug/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update role error: $e');
      rethrow;
    }
  }

  /// Delete role
  Future<bool> deleteRole(String slug) async {
    try {
      await _dio.delete('/roles/$slug/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete role error: $e');
      return false;
    }
  }
}
