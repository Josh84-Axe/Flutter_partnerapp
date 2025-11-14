import 'package:dio/dio.dart';

/// Repository for plan management operations
class PlanRepository {
  final Dio _dio;

  PlanRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      final response = await _dio.get('/partner/plans/');
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch plans error: $e');
      rethrow;
    }
  }

  /// Create a new plan
  /// Required fields depend on backend schema
  Future<Map<String, dynamic>?> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _dio.post(
        '/partner/plans/create/',
        data: planData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Create plan error: $e');
      rethrow;
    }
  }

  /// Get plan details
  Future<Map<String, dynamic>?> getPlanDetails(String planSlug) async {
    try {
      final response = await _dio.get('/partner/plans/$planSlug/read/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get plan details error: $e');
      rethrow;
    }
  }

  /// Update plan
  Future<Map<String, dynamic>?> updatePlan(
    String planSlug,
    Map<String, dynamic> planData,
  ) async {
    try {
      final response = await _dio.put(
        '/partner/plans/$planSlug/update/',
        data: planData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Update plan error: $e');
      rethrow;
    }
  }

  /// Delete plan
  Future<bool> deletePlan(String planSlug) async {
    try {
      await _dio.delete('/partner/plans/$planSlug/delete/');
      return true;
    } catch (e) {
      print('Delete plan error: $e');
      return false;
    }
  }

  /// Assign plan to customer
  Future<Map<String, dynamic>?> assignPlan(Map<String, dynamic> assignmentData) async {
    try {
      final response = await _dio.post(
        '/partner/assign-plan/',
        data: assignmentData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Assign plan error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plans
  Future<List<dynamic>> fetchAssignedPlans() async {
    try {
      final response = await _dio.get('/partner/assigned-plans/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch assigned plans error: $e');
      rethrow;
    }
  }
}
