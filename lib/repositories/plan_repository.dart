import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for plan management operations
class PlanRepository {
  final Dio _dio;

  PlanRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      if (kDebugMode) debugPrint('📋 [PlanRepository] Fetching plans list');
      final response = await _dio.get('/plans/');
      if (kDebugMode) debugPrint('✅ [PlanRepository] Fetch plans response status: ${response.statusCode}');
      if (kDebugMode) debugPrint('📦 [PlanRepository] Fetch plans response data: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception} or data: {results: [...]}
      if (responseData is Map) {
         if (responseData['data'] is List) {
           final plans = responseData['data'] as List;
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${plans.length} plans');
           return plans;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           final plans = responseData['data']['results'] as List;
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${plans.length} plans');
           return plans;
         }
      }
      
      if (kDebugMode) debugPrint('⚠️ [PlanRepository] No plans found in response');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Create a new plan
  /// Required fields depend on backend schema
  Future<Map<String, dynamic>?> createPlan(Map<String, dynamic> planData) async {
    try {
      if (kDebugMode) debugPrint('➕ [PlanRepository] Creating new plan: ${planData['name']}');
      if (kDebugMode) debugPrint('📦 [PlanRepository] Plan data: $planData');
      final response = await _dio.post(
        '/plans/create/',
        data: planData,
      );
      if (kDebugMode) debugPrint('✅ [PlanRepository] Create plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Create plan error: $e');
      rethrow;
    }
  }

  /// Get plan details
  Future<Map<String, dynamic>?> getPlanDetails(String planSlug) async {
    try {
      if (kDebugMode) debugPrint('🔍 [PlanRepository] Fetching plan details for: $planSlug');
      final response = await _dio.get('/plans/$planSlug/read/');
      if (kDebugMode) debugPrint('✅ [PlanRepository] Plan details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Get plan details error: $e');
      rethrow;
    }
  }

  /// Update plan
  Future<Map<String, dynamic>?> updatePlan(
    String planSlug,
    Map<String, dynamic> planData,
  ) async {
    try {
      if (kDebugMode) debugPrint('✏️ [PlanRepository] Updating plan: $planSlug');
      if (kDebugMode) debugPrint('📦 [PlanRepository] Update data: $planData');
      final response = await _dio.put(
        '/plans/$planSlug/update/',
        data: planData,
      );
      if (kDebugMode) debugPrint('✅ [PlanRepository] Update plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Update plan error: $e');
      rethrow;
    }
  }

  /// Delete plan
  Future<bool> deletePlan(String planSlug) async {
    try {
      if (kDebugMode) debugPrint('🗑️ [PlanRepository] Deleting plan: $planSlug');
      await _dio.delete('/plans/$planSlug/delete/');
      if (kDebugMode) debugPrint('✅ [PlanRepository] Plan deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Delete plan error: $e');
      return false;
    }
  }

  /// Assign plan to customer
  Future<Map<String, dynamic>?> assignPlan(Map<String, dynamic> assignmentData) async {
    try {
      if (kDebugMode) debugPrint('🎯 [PlanRepository] Assigning plan to customer');
      if (kDebugMode) debugPrint('📦 [PlanRepository] Assignment data: $assignmentData');
      final response = await _dio.post(
        '/assign-plan/',
        data: assignmentData,
      );
      if (kDebugMode) debugPrint('✅ [PlanRepository] Assign plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Assign plan error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plans
  Future<List<dynamic>> fetchAssignedPlans() async {
    try {
      if (kDebugMode) debugPrint('📋 [PlanRepository] Fetching assigned plans');
      final response = await _dio.get('/assigned-plans/');
      final responseData = response.data;
      
      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map && data.containsKey('results')) {
           final results = data['results'] as List;
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${results.length} assigned plans');
           return results;
        } else if (data is List) {
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${data.length} assigned plans');
           return data;
        }
      }
      
      if (kDebugMode) debugPrint('⚠️ [PlanRepository] No assigned plans found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Fetch assigned plans error: $e');
      rethrow;
    }
  }

  /// Fetch purchased plans
  Future<List<dynamic>> fetchPurchasedPlans() async {
    try {
      if (kDebugMode) debugPrint('📋 [PlanRepository] Fetching purchased plans');
      final response = await _dio.get('/purchased-plans/');
      final responseData = response.data;
      
      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map && data.containsKey('results')) {
           final results = data['results'] as List;
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${results.length} purchased plans');
           return results;
        } else if (data is List) {
           if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${data.length} purchased plans');
           return data;
        }
      }
      
      if (kDebugMode) debugPrint('⚠️ [PlanRepository] No purchased plans found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Fetch purchased plans error: $e');
      rethrow;
    }
  }
  /// Fetch network policies
  Future<List<dynamic>> fetchNetworkPolicies() async {
    try {
      if (kDebugMode) debugPrint('📋 [PlanRepository] Fetching network policies');
      final response = await _dio.get('/network-policies/list/');
      
      final responseData = response.data;
      if (responseData is List) {
        if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${responseData.length} network policies');
        return responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        final policies = responseData['data'] as List;
        if (kDebugMode) debugPrint('✅ [PlanRepository] Found ${policies.length} network policies');
        return policies;
      }
      
      if (kDebugMode) debugPrint('⚠️ [PlanRepository] No network policies found in response');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PlanRepository] Fetch network policies error: $e');
      return [];
    }
  }
}
