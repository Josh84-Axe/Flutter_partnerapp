import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for subscription plan operations
class SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of available subscription plans
  Future<List<dynamic>> fetchSubscriptionPlans({String? country}) async {
    try {
      if (kDebugMode) print('📋 [SubscriptionRepository] Fetching subscription plans${country != null ? ' for $country' : ''}');
      
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;

      final response = await _dio.get(
        '/partner/subscription-plans/list/',
        queryParameters: queryParams,
      );
      if (kDebugMode) print('✅ [SubscriptionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
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
      
      if (kDebugMode) print('⚠️ [SubscriptionRepository] No plans found in response');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [SubscriptionRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Check current subscription status
  Future<Map<String, dynamic>?> checkSubscriptionStatus() async {
    try {
      if (kDebugMode) print('📦 [SubscriptionRepository] Checking subscription status');
      final response = await _dio.get('/partner/subscription-plans/check/');
      if (kDebugMode) print('✅ [SubscriptionRepository] Subscription status: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [SubscriptionRepository] Check subscription error: $e');
      return null;
    }
  }

  /// Purchase a subscription plan with payment reference
  Future<Map<String, dynamic>?> purchaseSubscription(
    String planId,
    String paymentReference,
  ) async {
    try {
      if (kDebugMode) {
        print('💳 [SubscriptionRepository] Purchasing plan: $planId');
        print('   Payment reference: $paymentReference');
      }
      
      final response = await _dio.post(
        '/partner/subscription-plans/purchase/',
        data: {
          'subscription_plan_id': planId,
          'payment_reference': paymentReference,
        },
      );
      
      if (kDebugMode) print('✅ [SubscriptionRepository] Purchase response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [SubscriptionRepository] Purchase error: $e');
      rethrow;
    }
  }

  // Payment initialization removed - using Paystack inline popup instead
  // No backend API call needed, payment handled directly by Paystack popup.js
}
