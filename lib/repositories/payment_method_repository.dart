import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for payment method operations
class PaymentMethodRepository {
  final Dio _dio;

  PaymentMethodRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of payment methods
  Future<List<dynamic>> fetchPaymentMethods() async {
    try {
      final response = await _dio.get('/partner/payment-methods/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch payment methods error: $e');
      rethrow;
    }
  }

  /// Request OTP for creating payment method
  Future<Map<String, dynamic>?> requestCreateOtp(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/payment-methods/create/request-otp/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Request create OTP error: $e');
      rethrow;
    }
  }

  /// Verify OTP and create payment method
  Future<Map<String, dynamic>?> verifyCreateOtp({
    required Map<String, dynamic> data,
    required String otp,
  }) async {
    try {
      final payload = {...data, 'code': otp};
      final response = await _dio.post('/partner/payment-methods/create/verify-otp/', data: payload);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Verify create OTP error: $e');
      rethrow;
    }
  }

  /// Get payment method details
  Future<Map<String, dynamic>?> getPaymentMethodDetails(String slug) async {
    try {
      final response = await _dio.get('/partner/payment-methods/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get payment method details error: $e');
      rethrow;
    }
  }

  /// Request OTP for updating payment method
  Future<Map<String, dynamic>?> requestUpdateOtp(String slug, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/payment-methods/$slug/update/request-otp/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Request update OTP error: $e');
      rethrow;
    }
  }

  /// Verify OTP and update payment method
  Future<Map<String, dynamic>?> verifyUpdateOtp({
    required String slug,
    required Map<String, dynamic> data,
    required String otp,
  }) async {
    try {
      final payload = {...data, 'code': otp};
      final response = await _dio.post('/partner/payment-methods/$slug/update/verify-otp/', data: payload);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Verify update OTP error: $e');
      rethrow;
    }
  }

  /// Delete payment method
  Future<bool> deletePaymentMethod(String slug) async {
    try {
      await _dio.delete('/partner/payment-methods/$slug/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete payment method error: $e');
      return false;
    }
  }
}
