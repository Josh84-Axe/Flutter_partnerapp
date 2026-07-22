import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for plan management operations
class PlanRepository {
  final Dio _dio;

  PlanRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      if (kDebugMode) print('📋 [PlanRepository] Fetching plans list');
      final response = await _dio.get('/partner/plans/');
      if (kDebugMode) print('✅ [PlanRepository] Fetch plans response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [PlanRepository] Fetch plans response data: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception} or data: {results: [...]}
      if (responseData is Map) {
         if (responseData['data'] is List) {
           final plans = responseData['data'] as List;
           if (kDebugMode) print('✅ [PlanRepository] Found ${plans.length} plans');
           return plans;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           final plans = responseData['data']['results'] as List;
           if (kDebugMode) print('✅ [PlanRepository] Found ${plans.length} plans');
           return plans;
         }
      }
      
      if (kDebugMode) print('⚠️ [PlanRepository] No plans found in response');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Create a new plan
  /// Required fields depend on backend schema
  Future<Map<String, dynamic>?> createPlan(Map<String, dynamic> planData) async {
    try {
      if (kDebugMode) print('➕ [PlanRepository] Creating new plan: ${planData['name']}');
      if (kDebugMode) print('📦 [PlanRepository] Plan data: $planData');
      final response = await _dio.post(
        '/partner/plans/create/',
        data: planData,
      );
      if (kDebugMode) print('✅ [PlanRepository] Create plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Create plan error: $e');
      rethrow;
    }
  }

  /// Get plan details
  Future<Map<String, dynamic>?> getPlanDetails(String planSlug) async {
    try {
      if (kDebugMode) print('🔍 [PlanRepository] Fetching plan details for: $planSlug');
      final response = await _dio.get('/partner/plans/$planSlug/read/');
      if (kDebugMode) print('✅ [PlanRepository] Plan details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Get plan details error: $e');
      rethrow;
    }
  }

  /// Update plan
  Future<Map<String, dynamic>?> updatePlan(
    String planSlug,
    Map<String, dynamic> planData,
  ) async {
    try {
      if (kDebugMode) print('✏️ [PlanRepository] Updating plan: $planSlug');
      if (kDebugMode) print('📦 [PlanRepository] Update data: $planData');
      final response = await _dio.put(
        '/partner/plans/$planSlug/update/',
        data: planData,
      );
      if (kDebugMode) print('✅ [PlanRepository] Update plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Update plan error: $e');
      rethrow;
    }
  }

  /// Delete plan
  Future<bool> deletePlan(String planSlug) async {
    try {
      if (kDebugMode) print('🗑️ [PlanRepository] Deleting plan: $planSlug');
      await _dio.delete('/partner/plans/$planSlug/delete/');
      if (kDebugMode) print('✅ [PlanRepository] Plan deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Delete plan error: $e');
      return false;
    }
  }

  /// Assign plan to customer
  Future<Map<String, dynamic>?> assignPlan(Map<String, dynamic> assignmentData) async {
    try {
      if (kDebugMode) print('🎯 [PlanRepository] Assigning plan to customer');
      if (kDebugMode) print('📦 [PlanRepository] Assignment data: $assignmentData');
      final response = await _dio.post(
        '/partner/assign-plan/',
        data: assignmentData,
      );
      if (kDebugMode) print('✅ [PlanRepository] Assign plan response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Assign plan error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plans
  Future<List<dynamic>> fetchAssignedPlans() async {
    try {
      if (kDebugMode) print('📋 [PlanRepository] Fetching assigned plans');
      final response = await _dio.get('/partner/assigned-plans/');
      final responseData = response.data;
      
      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map && data.containsKey('results')) {
           final results = data['results'] as List;
           if (kDebugMode) print('✅ [PlanRepository] Found ${results.length} assigned plans');
           return results;
        } else if (data is List) {
           if (kDebugMode) print('✅ [PlanRepository] Found ${data.length} assigned plans');
           return data;
        }
      }
      
      if (kDebugMode) print('⚠️ [PlanRepository] No assigned plans found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Fetch assigned plans error: $e');
      rethrow;
    }
  }

  /// Fetch purchased plans
  Future<List<dynamic>> fetchPurchasedPlans() async {
    try {
      if (kDebugMode) print('📋 [PlanRepository] Fetching purchased plans');
      final response = await _dio.get('/partner/purchased-plans/');
      final responseData = response.data;
      
      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map && data.containsKey('results')) {
           final results = data['results'] as List;
           if (kDebugMode) print('✅ [PlanRepository] Found ${results.length} purchased plans');
           return results;
        } else if (data is List) {
           if (kDebugMode) print('✅ [PlanRepository] Found ${data.length} purchased plans');
           return data;
        }
      }
      
      if (kDebugMode) print('⚠️ [PlanRepository] No purchased plans found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Fetch purchased plans error: $e');
      rethrow;
    }
  }
  /// Fetch network policies
  Future<List<dynamic>> fetchNetworkPolicies() async {
    try {
      if (kDebugMode) print('📋 [PlanRepository] Fetching network policies');
      final response = await _dio.get('/partner/network-policies/list/');
      
      final responseData = response.data;
      if (responseData is List) {
        if (kDebugMode) print('✅ [PlanRepository] Found ${responseData.length} network policies');
        return responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        final policies = responseData['data'] as List;
        if (kDebugMode) print('✅ [PlanRepository] Found ${policies.length} network policies');
        return policies;
      }
      
      if (kDebugMode) print('⚠️ [PlanRepository] No network policies found in response');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [PlanRepository] Fetch network policies error: $e');
      return [];
    }
  }
}
