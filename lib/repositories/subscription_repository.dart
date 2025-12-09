import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for subscription plan operations
class SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of available subscription plans
  Future<List<dynamic>> fetchSubscriptionPlans() async {
    try {
      if (kDebugMode) print('📋 [SubscriptionRepository] Fetching subscription plans');
      final response = await _dio.get('/partner/subscription-plans/list/');
      if (kDebugMode) print('✅ [SubscriptionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested data structure: { data: [...] } or { results: [...] }
      if (responseData is Map) {
        if (responseData['data'] is List) {
          return responseData['data'] as List;
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

  /// Initialize Paystack payment for subscription
  Future<Map<String, dynamic>> initializePayment({
    required String email,
    required double amount,
    required String planId,
    required String planName,
    required String currency, // Dynamic currency based on partner country
  }) async {
    try {
      if (kDebugMode) {
        print('💰 [SubscriptionRepository] Initializing payment');
        print('   Email: $email, Amount: $amount, Plan: $planName, Currency: $currency');
      }
      
      final response = await _dio.post(
        'https://api.paystack.co/transaction/initialize',
        data: {
          'email': email,
          'amount': (amount * 100).toInt(), // Paystack expects amount in kobo/pesewas/cents
          'currency': currency, // GHS for Ghana, NGN for Nigeria, etc.
          'metadata': {
            'plan_id': planId,
            'plan_name': planName,
            'custom_fields': [
              {
                'display_name': 'Subscription Plan',
                'variable_name': 'subscription_plan',
                'value': planName,
              }
            ],
          },
          'callback_url': 'https://your-app.com/payment/callback', // TODO: Update with actual callback URL
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer pk_live_ba6137ee394e83ff5b0cfec596851545e1dea426',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (kDebugMode) print('✅ [SubscriptionRepository] Payment initialized: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [SubscriptionRepository] Payment initialization error: $e');
      rethrow;
    }
  }
}
