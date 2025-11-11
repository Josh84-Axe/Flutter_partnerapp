import 'package:dio/dio.dart';

/// Repository for wallet and transaction operations
class WalletRepository {
  final Dio _dio;

  WalletRepository({required Dio dio}) : _dio = dio;

  /// Fetch wallet balance
  Future<Map<String, dynamic>?> fetchBalance() async {
    try {
      final response = await _dio.get('/partner/wallet/balance/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Fetch balance error: $e');
      rethrow;
    }
  }

  /// Fetch available plans
  Future<List<dynamic>> fetchPlans() async {
    try {
      final response = await _dio.get('/partner/plans/');
      final data = response.data;
      
      if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Fetch plans error: $e');
      rethrow;
    }
  }

  /// Fetch all transactions (no filters)
  Future<List<dynamic>> fetchAllTransactions() async {
    try {
      final response = await _dio.get('/partner/wallet/all-transactions/');
      final data = response.data;
      
      if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Fetch all transactions error: $e');
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

      final response = await _dio.get(
        '/partner/wallet/transactions/',
        queryParameters: queryParams,
      );
      
      final data = response.data;
      
      if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Fetch transactions error: $e');
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

      final response = await _dio.get(
        '/partner/withdrawals/',
        queryParameters: queryParams,
      );
      
      final data = response.data;
      
      if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Fetch withdrawals error: $e');
      rethrow;
    }
  }

  /// Create withdrawal request
  Future<Map<String, dynamic>?> createWithdrawal(Map<String, dynamic> requestData) async {
    try {
      final response = await _dio.post(
        '/partner/withdrawals/create/',
        data: requestData,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Create withdrawal error: $e');
      rethrow;
    }
  }
}
