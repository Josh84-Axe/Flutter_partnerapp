import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for subscription plan operations
class SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of available subscription plans
  Future<List<dynamic>> fetchSubscriptionPlans({String? country}) async {
    try {
      if (kDebugMode) debugPrint('📋 [SubscriptionRepository] Fetching subscription plans${country != null ? ' for $country' : ''}');
      
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;

      final response = await _dio.get(
        '/subscription-plans/list/',
        queryParameters: queryParams,
      );
      if (kDebugMode) debugPrint('✅ [SubscriptionRepository] Response: ${response.data}');
      
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
      
      if (kDebugMode) debugPrint('⚠️ [SubscriptionRepository] No plans found in response');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [SubscriptionRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Check current subscription status
  Future<Map<String, dynamic>?> checkSubscriptionStatus() async {
    try {
      if (kDebugMode) debugPrint('📦 [SubscriptionRepository] Checking subscription status');
      final response = await _dio.get('/subscription-plans/check/');
      if (kDebugMode) debugPrint('✅ [SubscriptionRepository] Subscription status: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [SubscriptionRepository] Check subscription error: $e');
      return null;
    }
  }

  /// Purchase a subscription plan with payment reference
  Future<Map<String, dynamic>?> purchaseSubscription(
    String planId,
    String? priceId,
    String paymentReference,
    String paymentProvider,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('💳 [SubscriptionRepository] Purchasing plan: $planId');
        debugPrint('   Price ID: $priceId');
        debugPrint('   Payment reference: $paymentReference');
        debugPrint('   Payment provider: $paymentProvider');
      }
      
      final payload = <String, dynamic>{
        'payment_reference': paymentReference,
        'payment_provider': paymentProvider,
      };
      
      if (priceId != null && priceId.isNotEmpty) {
        payload['subscription_plan_price_id'] = int.tryParse(priceId) ?? priceId;
      } else {
        payload['subscription_plan_price_id'] = int.tryParse(planId) ?? planId; // Fallback to planId if no priceId is found
      }
      
      final response = await _dio.post(
        '/subscription-plans/purchase/',
        data: payload,
      );
      
      if (kDebugMode) debugPrint('✅ [SubscriptionRepository] Purchase response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [SubscriptionRepository] Purchase error: $e');
      rethrow;
    }
  }

  // Payment initialization removed - using Paystack inline popup instead
  // No backend API call needed, payment handled directly by Paystack popup.js
}
