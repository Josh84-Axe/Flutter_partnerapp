import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

      if (kDebugMode) print('💳 [TransactionRepository] Fetching transactions with filters: $queryParams');
      final response = await _dio.get(
        '/partner/transactions/',
        queryParameters: queryParams,
      );
      if (kDebugMode) print('✅ [TransactionRepository] Fetch transactions response: ${response.data}');
      
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final transactions = responseData['data'] as List;
        if (kDebugMode) print('✅ [TransactionRepository] Found ${transactions.length} transactions');
        return transactions;
      }
      
      if (kDebugMode) print('⚠️ [TransactionRepository] No transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Fetch transactions error: $e');
      rethrow;
    }
  }

  /// Fetch additional device transactions
  Future<List<dynamic>> fetchAdditionalDeviceTransactions() async {
    try {
      if (kDebugMode) print('📱 [TransactionRepository] Fetching additional device transactions');
      final response = await _dio.get('/partner/transactions/additional-devices/');
      if (kDebugMode) print('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final transactions = responseData['data'] as List;
        if (kDebugMode) print('✅ [TransactionRepository] Found ${transactions.length} device transactions');
        return transactions;
      }
      
      if (kDebugMode) print('⚠️ [TransactionRepository] No device transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Fetch additional device transactions error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plan transactions
  Future<List<dynamic>> fetchAssignedPlanTransactions() async {
    try {
      if (kDebugMode) print('📋 [TransactionRepository] Fetching assigned plan transactions');
      final response = await _dio.get('/partner/transactions/assigned-plans/');
      if (kDebugMode) print('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final transactions = responseData['data'] as List;
        if (kDebugMode) print('✅ [TransactionRepository] Found ${transactions.length} plan transactions');
        return transactions;
      }
      
      if (kDebugMode) print('⚠️ [TransactionRepository] No plan transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Fetch assigned plan transactions error: $e');
      rethrow;
    }
  }
}
