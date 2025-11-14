import 'package:dio/dio.dart';

/// Repository for plan management operations
class PlanRepository {
  final Dio _dio;

  PlanRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      print('📋 [PlanRepository] Fetching plans list');
      final response = await _dio.get('/partner/plans/');
      print('✅ [PlanRepository] Fetch plans response status: ${response.statusCode}');
      print('📦 [PlanRepository] Fetch plans response data: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final plans = responseData['data'] as List;
        print('✅ [PlanRepository] Found ${plans.length} plans');
        return plans;
      }
      
      print('⚠️ [PlanRepository] No plans found in response');
      return [];
    } catch (e) {
      print('❌ [PlanRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Create a new plan
  /// Required fields depend on backend schema
  Future<Map<String, dynamic>?> createPlan(Map<String, dynamic> planData) async {
    try {
      print('➕ [PlanRepository] Creating new plan: ${planData['name']}');
      print('📦 [PlanRepository] Plan data: $planData');
      final response = await _dio.post(
        '/partner/plans/create/',
        data: planData,
      );
      print('✅ [PlanRepository] Create plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [PlanRepository] Create plan error: $e');
      rethrow;
    }
  }

  /// Get plan details
  Future<Map<String, dynamic>?> getPlanDetails(String planSlug) async {
    try {
      print('🔍 [PlanRepository] Fetching plan details for: $planSlug');
      final response = await _dio.get('/partner/plans/$planSlug/read/');
      print('✅ [PlanRepository] Plan details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [PlanRepository] Get plan details error: $e');
      rethrow;
    }
  }

  /// Update plan
  Future<Map<String, dynamic>?> updatePlan(
    String planSlug,
    Map<String, dynamic> planData,
  ) async {
    try {
      print('✏️ [PlanRepository] Updating plan: $planSlug');
      print('📦 [PlanRepository] Update data: $planData');
      final response = await _dio.put(
        '/partner/plans/$planSlug/update/',
        data: planData,
      );
      print('✅ [PlanRepository] Update plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [PlanRepository] Update plan error: $e');
      rethrow;
    }
  }

  /// Delete plan
  Future<bool> deletePlan(String planSlug) async {
    try {
      print('🗑️ [PlanRepository] Deleting plan: $planSlug');
      await _dio.delete('/partner/plans/$planSlug/delete/');
      print('✅ [PlanRepository] Plan deleted successfully');
      return true;
    } catch (e) {
      print('❌ [PlanRepository] Delete plan error: $e');
      return false;
    }
  }

  /// Assign plan to customer
  Future<Map<String, dynamic>?> assignPlan(Map<String, dynamic> assignmentData) async {
    try {
      print('🎯 [PlanRepository] Assigning plan to customer');
      print('📦 [PlanRepository] Assignment data: $assignmentData');
      final response = await _dio.post(
        '/partner/assign-plan/',
        data: assignmentData,
      );
      print('✅ [PlanRepository] Assign plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [PlanRepository] Assign plan error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plans
  Future<List<dynamic>> fetchAssignedPlans() async {
    try {
      print('📋 [PlanRepository] Fetching assigned plans');
      final response = await _dio.get('/partner/assigned-plans/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final plans = responseData['data'] as List;
        print('✅ [PlanRepository] Found ${plans.length} assigned plans');
        return plans;
      }
      
      print('⚠️ [PlanRepository] No assigned plans found');
      return [];
    } catch (e) {
      print('❌ [PlanRepository] Fetch assigned plans error: $e');
      rethrow;
    }
  }
}
