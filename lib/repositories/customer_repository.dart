import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      
      if (kDebugMode) print('👥 [CustomerRepository] Fetching customers with params: $queryParams');
      final response = await _dio.get(
        '/partner/customers/list/',
        queryParameters: queryParams,
      );
      
      if (kDebugMode) print('✅ [CustomerRepository] Fetch customers response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Fetch customers error: $e');
      rethrow;
    }
  }

  /// Get customer transactions
  Future<List<dynamic>> getCustomerTransactions(String username) async {
    try {
      if (kDebugMode) print('💰 [CustomerRepository] Fetching transactions for customer: $username');
      final response = await _dio.get('/partner/customers/$username/transactions/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        final transactions = responseData['data'] as List;
        if (kDebugMode) print('✅ [CustomerRepository] Found ${transactions.length} transactions');
        return transactions;
      }
      
      if (kDebugMode) print('⚠️ [CustomerRepository] No transactions found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get customer transactions error: $e');
      rethrow;
    }
  }

  /// Create a new customer
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    try {
      if (kDebugMode) print('➕ [CustomerRepository] Creating customer with payload: $customerData');
      final response = await _dio.post(
        '/partner/customers/create/',
        data: customerData,
      );
      if (kDebugMode) print('✅ [CustomerRepository] Customer created successfully');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return responseData as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Create customer error: $e');
      rethrow;
    }
  }

  /// Update an existing customer
  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> customerData) async {
    try {
      if (kDebugMode) print('✏️ [CustomerRepository] Updating customer: $id');
      final response = await _dio.put(
        '/partner/customers/$id/',
        data: customerData,
      );
      if (kDebugMode) print('✅ [CustomerRepository] Customer updated successfully');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
      
      return responseData as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Update customer error: $e');
      rethrow;
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String id) async {
    try {
      if (kDebugMode) print('🗑️ [CustomerRepository] Deleting customer: $id');
      await _dio.delete('/partner/customers/$id/');
      if (kDebugMode) print('✅ [CustomerRepository] Customer deleted successfully');
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Delete customer error: $e');
      rethrow;
    }
  }

  /// Block a customer
  Future<void> blockCustomer(String id) async {
    try {
      if (kDebugMode) print('🚫 [CustomerRepository] Blocking customer: $id');
      await _dio.put(
        '/partner/customers/$id/block-or-unblock/',
        data: {'is_blocked': true},
      );
      if (kDebugMode) print('✅ [CustomerRepository] Customer blocked successfully');
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Block customer error: $e');
      rethrow;
    }
  }

  /// Unblock a customer
  Future<void> unblockCustomer(String id) async {
    try {
      if (kDebugMode) print('✅ [CustomerRepository] Unblocking customer: $id');
      await _dio.put(
        '/partner/customers/$id/block-or-unblock/',
        data: {'is_blocked': false},
      );
      if (kDebugMode) print('✅ [CustomerRepository] Customer unblocked successfully');
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Unblock customer error: $e');
      rethrow;
    }
  }

  /// Fetch active sessions to determine online status
  Future<List<String>> getActiveSessions() async {
    try {
      if (kDebugMode) print('🌐 [CustomerRepository] Fetching active sessions');
      final response = await _dio.get('/partner/sessions/active/');
      
      final responseData = response.data;
      final activeUsernames = <String>[];
      
      if (responseData is Map && responseData['data'] is List) {
        final routers = responseData['data'] as List;
        for (var router in routers) {
          if (router is Map && router['active_users'] is List) {
            final users = router['active_users'] as List;
            activeUsernames.addAll(users.map((u) {
              if (u is Map) {
                return u['username']?.toString() ?? '';
              }
              return u.toString();
            }).where((s) => s.isNotEmpty));
          }
        }
      }
      
      if (kDebugMode) print('✅ [CustomerRepository] Found ${activeUsernames.length} active users');
      return activeUsernames;
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get active sessions error: $e');
      return [];
    }
  }

  /// Get customer assigned transactions
  Future<List<dynamic>> getCustomerAssignedTransactions(String username) async {
    try {
      if (kDebugMode) print('💳 [CustomerRepository] Fetching assigned transactions for: $username');
      final response = await _dio.get('/partner/customers/$username/transactions/assigned/');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get assigned transactions error: $e');
      return [];
    }
  }

  /// Get customer wallet transactions
  Future<List<dynamic>> getCustomerWalletTransactions(String username) async {
    try {
      if (kDebugMode) print('💰 [CustomerRepository] Fetching wallet transactions for: $username');
      final response = await _dio.get('/partner/customers/$username/transactions/wallet/');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get wallet transactions error: $e');
      return [];
    }
  }

  /// Fetch purchased plans (Gateway/Online)
  Future<List<dynamic>> fetchPurchasedPlans() async {
    try {
      if (kDebugMode) print('🛒 [CustomerRepository] Fetching purchased plans');
      final response = await _dio.get('/partner/purchased-plans/');
      final responseData = response.data;

      if (responseData is Map) {
         // Handle both nested 'results' (pagination) and direct list
         if (responseData['data'] is Map && responseData['data']['results'] is List) {
            return responseData['data']['results'] as List;
         } else if (responseData['data'] is List) {
            return responseData['data'] as List;
         }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Fetch purchased plans error: $e');
      rethrow;
    }
  }

  /// Fetch assigned plans (Partner assigned)
  Future<List<dynamic>> fetchAssignedPlans() async {
    try {
      if (kDebugMode) print('📋 [CustomerRepository] Fetching assigned plans');
      final response = await _dio.get('/partner/assigned-plans/');
      final responseData = response.data;

      if (responseData is Map) {
         if (responseData['data'] is Map && responseData['data']['results'] is List) {
            return responseData['data']['results'] as List;
         } else if (responseData['data'] is List) {
            return responseData['data'] as List;
         }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Fetch assigned plans error: $e');
      rethrow;
    }
  }

  /// Fetch data usage for a specific customer
  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async {
    try {
      if (kDebugMode) print('📊 [CustomerRepository] Fetching data usage for: $username');
      final response = await _dio.get('/partner/customers/$username/data-usage/');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get data usage error: $e');
      rethrow;
    }
  }

  /// Get customer assigned plans
  Future<List<dynamic>> getCustomerAssignedPlans(String username) async {
    try {
      if (kDebugMode) print('📋 [CustomerRepository] Fetching assigned plans for: $username');
      final response = await _dio.get('/partner/customers/$username/plans/assigned/');
      
      final responseData = response.data;
      if (responseData is Map) {
         if (responseData['data'] is List) {
           return responseData['data'] as List;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           return responseData['data']['results'] as List;
         }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get assigned plans error: $e');
      return [];
    }
  }

  /// Get customer purchased plans
  Future<List<dynamic>> getCustomerPurchasedPlans(String username) async {
    try {
      if (kDebugMode) print('🛒 [CustomerRepository] Fetching purchased plans for: $username');
      final response = await _dio.get('/partner/customers/$username/plans/purchased/');
      
      final responseData = response.data;
      if (responseData is Map) {
         if (responseData['data'] is List) {
           return responseData['data'] as List;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           return responseData['data']['results'] as List;
         }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [CustomerRepository] Get purchased plans error: $e');
      return [];
    }
  }
}
