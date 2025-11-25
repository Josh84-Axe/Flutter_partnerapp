import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for plan configuration resources (rate limit, data limit, shared users, validity, idle timeout)
class PlanConfigRepository {
  final Dio _dio;

  PlanConfigRepository({required Dio dio}) : _dio = dio;

  // ==================== Rate Limit ====================

  /// Fetch list of rate limits
  Future<List<dynamic>> fetchRateLimits() async {
    try {
      final response = await _dio.get('/partner/rate-limit/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch rate limits error: $e');
      rethrow;
    }
  }

  /// Create rate limit
  Future<Map<String, dynamic>?> createRateLimit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/rate-limit/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create rate limit error: $e');
      rethrow;
    }
  }

  /// Get rate limit details
  Future<Map<String, dynamic>?> getRateLimitDetails(int id) async {
    try {
      final response = await _dio.get('/partner/rate-limit/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get rate limit details error: $e');
      rethrow;
    }
  }

  /// Delete rate limit
  Future<bool> deleteRateLimit(int id) async {
    try {
      await _dio.delete('/partner/rate-limit/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete rate limit error: $e');
      return false;
    }
  }

  // ==================== Data Limit ====================

  /// Fetch list of data limits
  Future<List<dynamic>> fetchDataLimits() async {
    try {
      final response = await _dio.get('/partner/data-limit/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch data limits error: $e');
      rethrow;
    }
  }

  /// Create data limit
  Future<Map<String, dynamic>?> createDataLimit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/data-limit/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create data limit error: $e');
      rethrow;
    }
  }

  /// Get data limit details
  Future<Map<String, dynamic>?> getDataLimitDetails(int id) async {
    try {
      final response = await _dio.get('/partner/data-limit/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get data limit details error: $e');
      rethrow;
    }
  }

  /// Delete data limit
  Future<bool> deleteDataLimit(int id) async {
    try {
      await _dio.delete('/partner/data-limit/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete data limit error: $e');
      return false;
    }
  }

  // ==================== Shared Users ====================

  /// Fetch list of shared users configurations
  Future<List<dynamic>> fetchSharedUsers() async {
    try {
      final response = await _dio.get('/partner/shared-users/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch shared users error: $e');
      rethrow;
    }
  }

  /// Create shared users configuration
  Future<Map<String, dynamic>?> createSharedUsers(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/shared-users/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create shared users error: $e');
      rethrow;
    }
  }

  /// Get shared users details
  Future<Map<String, dynamic>?> getSharedUsersDetails(int id) async {
    try {
      final response = await _dio.get('/partner/shared-users/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get shared users details error: $e');
      rethrow;
    }
  }

  /// Delete shared users configuration
  Future<bool> deleteSharedUsers(int id) async {
    try {
      await _dio.delete('/partner/shared-users/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete shared users error: $e');
      return false;
    }
  }

  // ==================== Validity ====================

  /// Fetch list of validity periods
  Future<List<dynamic>> fetchValidityPeriods() async {
    try {
      final response = await _dio.get('/partner/validity/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch validity periods error: $e');
      rethrow;
    }
  }

  /// Create validity period
  Future<Map<String, dynamic>?> createValidityPeriod(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/validity/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create validity period error: $e');
      rethrow;
    }
  }

  /// Get validity period details
  Future<Map<String, dynamic>?> getValidityPeriodDetails(int id) async {
    try {
      final response = await _dio.get('/partner/validity/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get validity period details error: $e');
      rethrow;
    }
  }

  /// Delete validity period
  Future<bool> deleteValidityPeriod(int id) async {
    try {
      await _dio.delete('/partner/validity/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete validity period error: $e');
      return false;
    }
  }

  // ==================== Idle Timeout ====================

  /// Fetch list of idle timeouts
  Future<List<dynamic>> fetchIdleTimeouts() async {
    try {
      final response = await _dio.get('/partner/idle-timeout/list/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('Fetch idle timeouts error: $e');
      rethrow;
    }
  }

  /// Create idle timeout
  Future<Map<String, dynamic>?> createIdleTimeout(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/idle-timeout/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Create idle timeout error: $e');
      rethrow;
    }
  }

  /// Get idle timeout details
  Future<Map<String, dynamic>?> getIdleTimeoutDetails(int id) async {
    try {
      final response = await _dio.get('/partner/idle-timeout/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Get idle timeout details error: $e');
      rethrow;
    }
  }

  /// Delete idle timeout
  Future<bool> deleteIdleTimeout(int id) async {
    try {
      await _dio.delete('/partner/idle-timeout/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete idle timeout error: $e');
      return false;
    }
  }
}
