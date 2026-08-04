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

      if (kDebugMode) debugPrint('💳 [TransactionRepository] Fetching transactions with filters: $queryParams');
      final response = await _dio.get(
        '/transactions/wallet/',
        queryParameters: queryParams,
      );
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Fetch transactions response: ${response.data}');
      
      final responseData = response.data;
      
      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          final transactions = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} transactions');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final transactions = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} transactions (nested)');
          return transactions;
        } else if (responseData['results'] is List) {
          final transactions = responseData['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} transactions (results)');
          return transactions;
        }
      } else if (responseData is List) {
        final transactions = responseData;
        if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} transactions (direct)');
        return transactions;
      }
      
      if (kDebugMode) debugPrint('⚠️ [TransactionRepository] No transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Fetch transactions error: $e');
      rethrow;
    }
  }

  /// Fetch additional device transactions
  Future<List<dynamic>> fetchAdditionalDeviceTransactions() async {
    try {
      if (kDebugMode) debugPrint('📱 [TransactionRepository] Fetching additional device transactions');
      final response = await _dio.get('/transactions/additional-devices/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          final transactions = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} device transactions');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final transactions = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} device transactions (nested)');
          return transactions;
        } else if (responseData['results'] is List) {
          final transactions = responseData['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} device transactions (results)');
          return transactions;
        }
      } else if (responseData is List) {
        final transactions = responseData;
        if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} device transactions (direct)');
        return transactions;
      }
      
      if (kDebugMode) debugPrint('⚠️ [TransactionRepository] No device transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Fetch additional device transactions error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plan transactions
  Future<List<dynamic>> fetchAssignedPlanTransactions() async {
    try {
      if (kDebugMode) debugPrint('📋 [TransactionRepository] Fetching assigned plan transactions');
      final response = await _dio.get('/transactions/assigned/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      // Handle nested structure: data.paginate_data
      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          final transactions = responseData['data'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} plan transactions');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final transactions = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} plan transactions (nested)');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['paginate_data'] is List) {
             final transactions = responseData['data']['paginate_data'] as List;
             if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} plan transactions (paginate)');
             return transactions;
        } else if (responseData['results'] is List) {
          final transactions = responseData['results'] as List;
          if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} plan transactions (results)');
          return transactions;
        }
      } else if (responseData is List) {
        final transactions = responseData;
        if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} plan transactions (direct)');
        return transactions;
      }
      
      if (kDebugMode) debugPrint('⚠️ [TransactionRepository] No plan transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Fetch assigned plan transactions error: $e');
      rethrow;
    }
  }

  /// Get assigned transaction details by ID
  Future<Map<String, dynamic>> getAssignedTransactionDetails(String id) async {
    try {
      if (kDebugMode) debugPrint('📄 [TransactionRepository] Fetching assigned transaction details for: $id');
      final response = await _dio.get('/transactions/assigned/$id/details/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Assigned transaction details fetched');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get assigned transaction details error: $e');
      rethrow;
    }
  }

  /// Get wallet transaction details by ID
  Future<Map<String, dynamic>> getWalletTransactionDetails(String id) async {
    try {
      if (kDebugMode) debugPrint('📄 [TransactionRepository] Fetching wallet transaction details for: $id');
      final response = await _dio.get('/transactions/wallet/$id/details/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Wallet transaction details fetched');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get wallet transaction details error: $e');
      rethrow;
    }
  }

  /// Get assigned wallet balance (for assigned plans)
  Future<Map<String, dynamic>> getAssignedWalletBalance() async {
    try {
      if (kDebugMode) debugPrint('💰 [TransactionRepository] Fetching assigned wallet balance');
      final response = await _dio.get('/assigned-wallet/balance/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Assigned wallet balance: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get assigned wallet balance error: $e');
      rethrow;
    }
  }

  /// Get assigned wallet transactions
  Future<List<dynamic>> getAssignedWalletTransactions() async {
    try {
      if (kDebugMode) debugPrint('💳 [TransactionRepository] Fetching assigned wallet transactions');
      final response = await _dio.get('/assigned-wallet/transactions/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Response: ${response.data}');
      
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
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get assigned wallet transactions error: $e');
      rethrow;
    }
  }

  /// Get wallet balance (for online purchases)
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      if (kDebugMode) debugPrint('💰 [TransactionRepository] Fetching wallet balance');
      final response = await _dio.get('/wallet/balance/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Wallet balance: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get wallet balance error: $e');
      rethrow;
    }
  }

  /// Get wallet transactions (online purchases)
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      if (kDebugMode) debugPrint('💳 [TransactionRepository] Fetching wallet transactions');
      final response = await _dio.get('/transactions/wallet/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Response: ${response.data}');
      
      final responseData = response.data;
      
      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          final transactions = responseData['data'] as List;
           if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} wallet transactions');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final transactions = responseData['data']['results'] as List;
           if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} wallet transactions (nested)');
          return transactions;
        } else if (responseData['data'] is Map && responseData['data']['paginate_data'] is List) {
          final transactions = responseData['data']['paginate_data'] as List;
           if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} wallet transactions (paginate)');
          return transactions;
        } else if (responseData['results'] is List) {
          final transactions = responseData['results'] as List;
           if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} wallet transactions (results)');
          return transactions;
        }
      } else if (responseData is List) {
        final transactions = responseData;
         if (kDebugMode) debugPrint('✅ [TransactionRepository] Found ${transactions.length} wallet transactions (direct)');
        return transactions;
      }
      
      if (kDebugMode) debugPrint('⚠️ [TransactionRepository] No wallet transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get wallet transactions error: $e');
      rethrow;
    }
  }

  /// Get wallet transaction details
  Future<Map<String, dynamic>> getTransactionDetails(String id) async {
    try {
      if (kDebugMode) debugPrint('📄 [TransactionRepository] Fetching transaction details for: $id');
      final response = await _dio.get('/transactions/wallet/$id/details/');
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Transaction details: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Get transaction details error: $e');
      rethrow;
    }
  }

  /// Get all withdrawals
  Future<List<dynamic>> getWithdrawals() async {
    try {
      if (kDebugMode) debugPrint('💸 [TransactionRepository] Fetching withdrawals from /partner/wallet/withdrawls/');
      final response = await _dio.get('/wallet/withdrawls/');
      if (kDebugMode) {
        debugPrint('✅ [TransactionRepository] Withdrawals response received');
        debugPrint('   Response type: ${response.data.runtimeType}');
        debugPrint('   Response data: ${response.data}');
      }
      
      final responseData = response.data;
      
      // Handle nested data structure
      // Standardized parsing logic
      if (responseData is Map) {
        if (responseData['data'] is List) {
          final withdrawals = responseData['data'] as List;
          if (kDebugMode) debugPrint('   Found ${withdrawals.length} withdrawals (data)');
          return withdrawals;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          final withdrawals = responseData['data']['results'] as List;
          if (kDebugMode) debugPrint('   Found ${withdrawals.length} withdrawals (nested results)');
          return withdrawals;
        } else if (responseData['data'] is Map && responseData['data']['paginate_data'] is List) {
          final withdrawals = responseData['data']['paginate_data'] as List;
          if (kDebugMode) debugPrint('   Found ${withdrawals.length} withdrawals (nested paginate)');
          return withdrawals;
        } else if (responseData['results'] is List) {
          final withdrawals = responseData['results'] as List;
          if (kDebugMode) debugPrint('   Found ${withdrawals.length} withdrawals (results)');
          return withdrawals;
        }
      } else if (responseData is List) {
        if (kDebugMode) debugPrint('   Found ${responseData.length} withdrawals (direct)');
        return responseData;
      }

      if (kDebugMode) debugPrint('⚠️ [TransactionRepository] No withdrawals found - unexpected response structure');
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TransactionRepository] Get withdrawals error: $e');
        if (e is DioException) {
          debugPrint('   Status code: ${e.response?.statusCode}');
          debugPrint('   Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  /// Create withdrawal request
  Future<Map<String, dynamic>> createWithdrawal(Map<String, dynamic> withdrawalData) async {
    try {
      if (kDebugMode) debugPrint('💸 [TransactionRepository] Creating withdrawal: $withdrawalData');
      final response = await _dio.post(
        '/wallet/withdrawls/create/',
        data: withdrawalData,
      );
      if (kDebugMode) debugPrint('✅ [TransactionRepository] Withdrawal created: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [TransactionRepository] Create withdrawal error: $e');
      rethrow;
    }
  }
}
