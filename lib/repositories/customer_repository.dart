import 'package:dio/dio.dart';

/// Repository for customer operations
class CustomerRepository {
  final Dio _dio;

  CustomerRepository({required Dio dio}) : _dio = dio;

  /// Fetch paginated list of customers
  /// Supports filtering and pagination
  Future<Map<String, dynamic>?> fetchCustomers({
    int? page,
    int? pageSize,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      print('👥 [CustomerRepository] Fetching customers (page: $page, pageSize: $pageSize, search: $search)');
      final response = await _dio.get(
        '/partner/customers/paginate-list/',
        queryParameters: queryParams,
      );
      
      print('✅ [CustomerRepository] Fetch customers response status: ${response.statusCode}');
      print('📦 [CustomerRepository] Fetch customers response data: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: {...}, exception}
      if (responseData is Map && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final count = data['count'] ?? 0;
        print('✅ [CustomerRepository] Found $count customers');
        return data;
      }
      
      print('⚠️ [CustomerRepository] No customer data found in response');
      return null;
    } catch (e) {
      print('❌ [CustomerRepository] Fetch customers error: $e');
      rethrow;
    }
  }

  /// Fetch all customers (no pagination)
  Future<List<dynamic>> fetchAllCustomers() async {
    try {
      print('👥 [CustomerRepository] Fetching all customers');
      final response = await _dio.get('/partner/customers/all/list/');
      print('✅ [CustomerRepository] Fetch all customers response: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final customers = responseData['data'] as List;
        print('✅ [CustomerRepository] Found ${customers.length} customers');
        return customers;
      }
      
      print('⚠️ [CustomerRepository] No customers found');
      return [];
    } catch (e) {
      print('❌ [CustomerRepository] Fetch all customers error: $e');
      rethrow;
    }
  }

  /// Block or unblock a customer
  Future<bool> blockOrUnblockCustomer(String username, bool block) async {
    try {
      print('🚫 [CustomerRepository] ${block ? "Blocking" : "Unblocking"} customer: $username');
      await _dio.put(
        '/partner/customers/$username/block-or-unblock/',
        data: {'is_blocked': block},
      );
      print('✅ [CustomerRepository] Customer ${block ? "blocked" : "unblocked"} successfully');
      return true;
    } catch (e) {
      print('❌ [CustomerRepository] Block/unblock customer error: $e');
      return false;
    }
  }

  /// Get customer data usage
  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async {
    try {
      print('📊 [CustomerRepository] Fetching data usage for customer: $username');
      final response = await _dio.get('/partner/customers/$username/data-usage/');
      print('✅ [CustomerRepository] Data usage response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('❌ [CustomerRepository] Get customer data usage error: $e');
      rethrow;
    }
  }

  /// Get customer transactions
  Future<List<dynamic>> getCustomerTransactions(String username) async {
    try {
      print('💰 [CustomerRepository] Fetching transactions for customer: $username');
      final response = await _dio.get('/partner/customers/$username/transactions/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final transactions = responseData['data'] as List;
        print('✅ [CustomerRepository] Found ${transactions.length} transactions');
        return transactions;
      }
      
      print('⚠️ [CustomerRepository] No transactions found');
      return [];
    } catch (e) {
      print('❌ [CustomerRepository] Get customer transactions error: $e');
      rethrow;
    }
  }
}
