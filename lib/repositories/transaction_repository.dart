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
        '/partner/wallet/transactions/',
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
      final response = await _dio.get('/partner/transactions/assigned/');
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

  /// Get assigned transaction details by ID
  Future<Map<String, dynamic>> getAssignedTransactionDetails(String id) async {
    try {
      if (kDebugMode) print('📄 [TransactionRepository] Fetching assigned transaction details for: $id');
      final response = await _dio.get('/partner/transactions/assigned/$id/details/');
      if (kDebugMode) print('✅ [TransactionRepository] Assigned transaction details fetched');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get assigned transaction details error: $e');
      rethrow;
    }
  }

  /// Get wallet transaction details by ID
  Future<Map<String, dynamic>> getWalletTransactionDetails(String id) async {
    try {
      if (kDebugMode) print('📄 [TransactionRepository] Fetching wallet transaction details for: $id');
      final response = await _dio.get('/partner/transactions/wallet/$id/details/');
      if (kDebugMode) print('✅ [TransactionRepository] Wallet transaction details fetched');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get wallet transaction details error: $e');
      rethrow;
    }
  }

  /// Get assigned wallet balance (for assigned plans)
  Future<Map<String, dynamic>> getAssignedWalletBalance() async {
    try {
      if (kDebugMode) print('💰 [TransactionRepository] Fetching assigned wallet balance');
      final response = await _dio.get('/partner/assigned-wallet/balance/');
      if (kDebugMode) print('✅ [TransactionRepository] Assigned wallet balance: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get assigned wallet balance error: $e');
      rethrow;
    }
  }

  /// Get assigned wallet transactions
  Future<List<dynamic>> getAssignedWalletTransactions() async {
    try {
      if (kDebugMode) print('💳 [TransactionRepository] Fetching assigned wallet transactions');
      final response = await _dio.get('/partner/assigned-wallet/transactions/');
      if (kDebugMode) print('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData is List) {
        return responseData;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get assigned wallet transactions error: $e');
      rethrow;
    }
  }

  /// Get assigned wallet transaction details
  Future<Map<String, dynamic>> getAssignedTransactionDetails(String id) async {
    try {
      if (kDebugMode) print('📄 [TransactionRepository] Fetching assigned transaction details for: $id');
      final response = await _dio.get('/partner/assigned-wallet/transactions/$id/details/');
      if (kDebugMode) print('✅ [TransactionRepository] Transaction details: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get assigned transaction details error: $e');
      rethrow;
    }
  }

  /// Get wallet balance (for online purchases)
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      if (kDebugMode) print('💰 [TransactionRepository] Fetching wallet balance');
      final response = await _dio.get('/partner/wallet/balance/');
      if (kDebugMode) print('✅ [TransactionRepository] Wallet balance: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get wallet balance error: $e');
      rethrow;
    }
  }

  /// Get wallet transactions (online purchases)
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      if (kDebugMode) print('💳 [TransactionRepository] Fetching wallet transactions');
      final response = await _dio.get('/partner/transactions/wallet/');
      if (kDebugMode) print('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData is List) {
        return responseData;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get wallet transactions error: $e');
      rethrow;
    }
  }

  /// Get wallet transaction details
  Future<Map<String, dynamic>> getTransactionDetails(String id) async {
    try {
      if (kDebugMode) print('📄 [TransactionRepository] Fetching transaction details for: $id');
      final response = await _dio.get('/partner/wallet/transactions/$id/details/');
      if (kDebugMode) print('✅ [TransactionRepository] Transaction details: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get transaction details error: $e');
      rethrow;
    }
  }

  /// Get all withdrawals
  Future<List<dynamic>> getWithdrawals() async {
    try {
      if (kDebugMode) print('💸 [TransactionRepository] Fetching withdrawals');
      final response = await _dio.get('/partner/wallet/withdrawls/');
      if (kDebugMode) print('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData is List) {
        return responseData;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Get withdrawals error: $e');
      rethrow;
    }
  }

  /// Create withdrawal request
  Future<Map<String, dynamic>> createWithdrawal(Map<String, dynamic> withdrawalData) async {
    try {
      if (kDebugMode) print('💸 [TransactionRepository] Creating withdrawal: $withdrawalData');
      final response = await _dio.post(
        '/partner/wallet/withdrawls/create/',
        data: withdrawalData,
      );
      if (kDebugMode) print('✅ [TransactionRepository] Withdrawal created: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionRepository] Create withdrawal error: $e');
      rethrow;
    }
  }
}
