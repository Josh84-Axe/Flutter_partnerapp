import 'package:dio/dio.dart';

/// Repository for payment method operations
class PaymentMethodRepository {
  final Dio _dio;

  PaymentMethodRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of payment methods
  Future<List<dynamic>> fetchPaymentMethods() async {
    try {
      final response = await _dio.get('/partner/payment-methods/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch payment methods error: $e');
      rethrow;
    }
  }

  /// Create payment method
  Future<Map<String, dynamic>?> createPaymentMethod(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/payment-methods/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Create payment method error: $e');
      rethrow;
    }
  }

  /// Get payment method details
  Future<Map<String, dynamic>?> getPaymentMethodDetails(String slug) async {
    try {
      final response = await _dio.get('/partner/payment-methods/$slug/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get payment method details error: $e');
      rethrow;
    }
  }

  /// Update payment method
  Future<Map<String, dynamic>?> updatePaymentMethod(String slug, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/partner/payment-methods/$slug/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Update payment method error: $e');
      rethrow;
    }
  }

  /// Delete payment method
  Future<bool> deletePaymentMethod(String slug) async {
    try {
      await _dio.delete('/partner/payment-methods/$slug/delete/');
      return true;
    } catch (e) {
      print('Delete payment method error: $e');
      return false;
    }
  }
}
