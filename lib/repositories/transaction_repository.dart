import 'package:dio/dio.dart';

/// Repository for transaction operations
class TransactionRepository {
  final Dio _dio;

  TransactionRepository({required Dio dio}) : _dio = dio;

  /// Fetch partner transactions
  Future<List<dynamic>> fetchTransactions({
    String? search,
    String? status,
    String? type,
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/partner/transactions/',
        queryParameters: queryParams,
      );
      
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch transactions error: $e');
      rethrow;
    }
  }

  /// Fetch additional device transactions
  Future<List<dynamic>> fetchAdditionalDeviceTransactions() async {
    try {
      final response = await _dio.get('/partner/transactions/additional-devices/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch additional device transactions error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plan transactions
  Future<List<dynamic>> fetchAssignedPlanTransactions() async {
    try {
      final response = await _dio.get('/partner/transactions/assigned-plans/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch assigned plan transactions error: $e');
      rethrow;
    }
  }
}
