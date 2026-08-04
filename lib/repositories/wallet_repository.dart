import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for wallet and transaction operations
class WalletRepository {
  final Dio _dio;

  WalletRepository({required Dio dio}) : _dio = dio;

  /// Fetch wallet balance
  Future<Map<String, dynamic>?> fetchBalance() async {
    try {
      if (kDebugMode) debugPrint('💰 [WalletRepository] Fetching wallet balance');
      final response = await _dio.get('/wallet/balance/');
      if (kDebugMode) debugPrint('✅ [WalletRepository] Fetch balance response status: ${response.statusCode}');
      if (kDebugMode) debugPrint('📦 [WalletRepository] Fetch balance response data: ${response.data}');
      
      final responseData = response.data;
      
      // API wraps data in {statusCode, error, message, data: {...}}
      if (responseData is Map && responseData['data'] is Map) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return responseData as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch balance error: $e');
      rethrow;
    }
  }

  /// Fetch counters balance (Total, Online, Assigned Revenue)
  Future<Map<String, dynamic>?> fetchCounters() async {
    try {
      if (kDebugMode) debugPrint('💰 [WalletRepository] Fetching counters balance');
      final response = await _dio.get('/counters/balance/');
      if (kDebugMode) debugPrint('✅ [WalletRepository] Fetch counters response: ${response.data}');
      
      final responseData = response.data;
      
      // API wraps data in {statusCode, error, message, data: {...}}
      if (responseData is Map && responseData['data'] is Map) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return responseData as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch counters error: $e');
      rethrow;
    }
  }

  /// Fetch available plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      if (kDebugMode) debugPrint('📋 [WalletRepository] Fetching plans');
      final response = await _dio.get('/plans/');
      if (kDebugMode) debugPrint('✅ [WalletRepository] Fetch plans response: ${response.data}');
      
      final responseData = response.data;
      
      // API wraps data in {statusCode, error, message, data: [...]}
      if (responseData is Map && responseData['data'] is List) {
        final plans = responseData['data'] as List;
        if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${plans.length} plans');
        return plans;
      }
      
      if (responseData is List) {
        if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${responseData.length} plans');
        return responseData;
      }
      
      if (kDebugMode) debugPrint('⚠️ [WalletRepository] No plans found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch plans error: $e');
      rethrow;
    }
  }

  /// Fetch all transactions (no filters)
  Future<List<dynamic>> fetchAllTransactions() async {
    try {
      if (kDebugMode) debugPrint('💳 [WalletRepository] Fetching all transactions');
      final response = await _dio.get('/wallet/all-transactions/');
      final data = response.data;
      
      if (data is List) {
        if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${data.length} transactions');
        return data;
      }
      
      if (kDebugMode) debugPrint('⚠️ [WalletRepository] No transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch all transactions error: $e');
      rethrow;
    }
  }

  /// Fetch transactions with filters
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

      if (kDebugMode) debugPrint('💳 [WalletRepository] Fetching transactions with filters: $queryParams');
      final response = await _dio.get(
        '/transactions/wallet/',
        queryParameters: queryParams,
      );
      if (kDebugMode) debugPrint('✅ [WalletRepository] Fetch transactions response: ${response.data}');
      
      final responseData = response.data;
      
      // API wraps data in {statusCode, error, message, data: {paginate_data: [...]}}
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['paginate_data'] is List) {
          final transactions = responseData['data']['paginate_data'] as List;
          if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${transactions.length} transactions');
          return transactions;
        }
        if (responseData['data'] is List) {
          final transactions = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${transactions.length} transactions');
          return transactions;
        }
      }
      
      if (responseData is List) {
        if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${responseData.length} transactions');
        return responseData;
      }
      
      if (kDebugMode) debugPrint('⚠️ [WalletRepository] No transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch transactions error: $e');
      rethrow;
    }
  }

  /// Fetch withdrawal requests
  Future<List<dynamic>> fetchWithdrawals({
    String? search,
    String? status,
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      if (kDebugMode) debugPrint('💸 [WalletRepository] Fetching withdrawals with filters: $queryParams');
      final response = await _dio.get(
        '/wallet/withdrawls/',
        queryParameters: queryParams,
      );
      if (kDebugMode) debugPrint('✅ [WalletRepository] Fetch withdrawals response: ${response.data}');
      
      final data = response.data;
      
      if (data is List) {
        if (kDebugMode) debugPrint('✅ [WalletRepository] Found ${data.length} withdrawals');
        return data;
      }
      
      if (kDebugMode) debugPrint('⚠️ [WalletRepository] No withdrawals found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch withdrawals error: $e');
      rethrow;
    }
  }

  /// Create withdrawal request
  Future<Map<String, dynamic>?> createWithdrawal(Map<String, dynamic> requestData) async {
    try {
      if (kDebugMode) debugPrint('💸 [WalletRepository] Creating withdrawal request');
      if (kDebugMode) debugPrint('📦 [WalletRepository] Withdrawal data: $requestData');
      final response = await _dio.post(
        '/wallet/withdrawls/create/',
        data: requestData,
      );
      if (kDebugMode) debugPrint('✅ [WalletRepository] Create withdrawal response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Create withdrawal error: $e');
      rethrow;
    }
  }

  /// Fetch transaction details by ID
  Future<Map<String, dynamic>?> fetchTransactionDetails(String transactionId) async {
    try {
      if (kDebugMode) debugPrint('💳 [WalletRepository] Fetching transaction details for ID: $transactionId');
      final response = await _dio.get('/transactions/wallet/$transactionId/details/');
      if (kDebugMode) debugPrint('✅ [WalletRepository] Transaction details response: ${response.data}');
      
      final responseData = response.data;
      
      // API wraps data in {statusCode, error, message, data: {...}}
      if (responseData is Map && responseData['data'] is Map) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return responseData as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [WalletRepository] Fetch transaction details error: $e');
      rethrow;
    }
  }
}
