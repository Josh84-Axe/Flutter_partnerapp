import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for payment method operations
class PaymentMethodRepository {
  final Dio _dio;

  PaymentMethodRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of payment methods
  Future<List<dynamic>> fetchPaymentMethods() async {
    try {
      final response = await _dio.get('/payment-methods/list/');
      final responseData = response.data;
      
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
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch payment methods error: $e');
      rethrow;
    }
  }

  /// Request OTP for creating payment method
  Future<Map<String, dynamic>?> requestCreateOtp(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/payment-methods/create/request-otp/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Request create OTP error: $e');
      rethrow;
    }
  }

  /// Verify OTP and create payment method
  Future<Map<String, dynamic>?> verifyCreateOtp({
    required Map<String, dynamic> data,
    required String otp,
    required String otpId,
  }) async {
    try {
      final payload = {...data, 'code': otp, 'otp_id': otpId};
      final response = await _dio.post('/payment-methods/create/verify-otp/', data: payload);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Verify create OTP error: $e');
      rethrow;
    }
  }

  /// Get payment method details
  Future<Map<String, dynamic>?> getPaymentMethodDetails(String slug) async {
    try {
      final response = await _dio.get('/payment-methods/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get payment method details error: $e');
      rethrow;
    }
  }

  /// Request OTP for updating payment method
  Future<Map<String, dynamic>?> requestUpdateOtp(String slug, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/payment-methods/$slug/update/request-otp/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Request update OTP error: $e');
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
      final response = await _dio.post('/payment-methods/$slug/update/verify-otp/', data: payload);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Verify update OTP error: $e');
      rethrow;
    }
  }

  /// Delete payment method
  Future<bool> deletePaymentMethod(String slug) async {
    try {
      await _dio.delete('/payment-methods/$slug/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete payment method error: $e');
      return false;
    }
  }
}
