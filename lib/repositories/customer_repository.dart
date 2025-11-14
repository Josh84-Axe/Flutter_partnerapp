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

      final response = await _dio.get(
        '/partner/customers/paginate-list/',
        queryParameters: queryParams,
      );
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: {...}, exception}
      if (responseData is Map && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('Fetch customers error: $e');
      rethrow;
    }
  }

  /// Fetch all customers (no pagination)
  Future<List<dynamic>> fetchAllCustomers() async {
    try {
      final response = await _dio.get('/partner/customers/all/list/');
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch all customers error: $e');
      rethrow;
    }
  }

  /// Block or unblock a customer
  Future<bool> blockOrUnblockCustomer(String username, bool block) async {
    try {
      await _dio.put(
        '/partner/customers/$username/block-or-unblock/',
        data: {'is_blocked': block},
      );
      return true;
    } catch (e) {
      print('Block/unblock customer error: $e');
      return false;
    }
  }

  /// Get customer data usage
  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async {
    try {
      final response = await _dio.get('/partner/customers/$username/data-usage/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get customer data usage error: $e');
      rethrow;
    }
  }

  /// Get customer transactions
  Future<List<dynamic>> getCustomerTransactions(String username) async {
    try {
      final response = await _dio.get('/partner/customers/$username/transactions/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Get customer transactions error: $e');
      rethrow;
    }
  }
}
