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
      final response = await _dio.get('/rate-limit/list/');
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch rate limits error: $e');
      rethrow;
    }
  }

  /// Create rate limit
  Future<Map<String, dynamic>?> createRateLimit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/rate-limit/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create rate limit error: $e');
      rethrow;
    }
  }

  /// Update rate limit
  Future<Map<String, dynamic>?> updateRateLimit(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/rate-limit/$id/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update rate limit error: $e');
      rethrow;
    }
  }

  /// Get rate limit details
  Future<Map<String, dynamic>?> getRateLimitDetails(int id) async {
    try {
      final response = await _dio.get('/rate-limit/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get rate limit details error: $e');
      rethrow;
    }
  }

  /// Delete rate limit
  Future<bool> deleteRateLimit(int id) async {
    try {
      await _dio.delete('/rate-limit/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete rate limit error: $e');
      return false;
    }
  }

  // ==================== Data Limit ====================

  /// Fetch list of data limits
  Future<List<dynamic>> fetchDataLimits() async {
    try {
      final response = await _dio.get('/data-limit/list/');
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch data limits error: $e');
      rethrow;
    }
  }

  /// Create data limit
  Future<Map<String, dynamic>?> createDataLimit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/data-limit/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create data limit error: $e');
      rethrow;
    }
  }

  /// Update data limit
  Future<Map<String, dynamic>?> updateDataLimit(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/data-limit/$id/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update data limit error: $e');
      rethrow;
    }
  }

  /// Get data limit details
  Future<Map<String, dynamic>?> getDataLimitDetails(int id) async {
    try {
      final response = await _dio.get('/data-limit/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get data limit details error: $e');
      rethrow;
    }
  }

  /// Delete data limit
  Future<bool> deleteDataLimit(int id) async {
    try {
      await _dio.delete('/data-limit/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete data limit error: $e');
      return false;
    }
  }

  // ==================== Shared Users ====================

  /// Fetch list of shared users configurations
  Future<List<dynamic>> fetchSharedUsers() async {
    try {
      final response = await _dio.get('/shared-users/list/');
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch shared users error: $e');
      rethrow;
    }
  }

  /// Create shared users configuration
  Future<Map<String, dynamic>?> createSharedUsers(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/shared-users/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create shared users error: $e');
      rethrow;
    }
  }

  /// Update shared users configuration
  Future<Map<String, dynamic>?> updateSharedUsers(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/shared-users/$id/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update shared users error: $e');
      rethrow;
    }
  }

  /// Get shared users details
  Future<Map<String, dynamic>?> getSharedUsersDetails(int id) async {
    try {
      final response = await _dio.get('/shared-users/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get shared users details error: $e');
      rethrow;
    }
  }

  /// Delete shared users configuration
  Future<bool> deleteSharedUsers(int id) async {
    try {
      await _dio.delete('/shared-users/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete shared users error: $e');
      return false;
    }
  }

  // ==================== Validity ====================

  /// Fetch list of validity periods
  Future<List<dynamic>> fetchValidityPeriods() async {
    try {
      final response = await _dio.get('/validity/list/');
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch validity periods error: $e');
      rethrow;
    }
  }

  /// Create validity period
  Future<Map<String, dynamic>?> createValidityPeriod(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/validity/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create validity period error: $e');
      rethrow;
    }
  }

  /// Update validity period
  Future<Map<String, dynamic>?> updateValidityPeriod(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/validity/$id/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update validity period error: $e');
      rethrow;
    }
  }

  /// Get validity period details
  Future<Map<String, dynamic>?> getValidityPeriodDetails(int id) async {
    try {
      final response = await _dio.get('/validity/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get validity period details error: $e');
      rethrow;
    }
  }

  /// Delete validity period
  Future<bool> deleteValidityPeriod(int id) async {
    try {
      await _dio.delete('/validity/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete validity period error: $e');
      return false;
    }
  }

  // ==================== Idle Timeout ====================

  /// Fetch list of idle timeouts
  Future<List<dynamic>> fetchIdleTimeouts() async {
    try {
      final response = await _dio.get('/idle-timeout/list/');
      final responseData = response.data;
      
      // Handle nested data structure
      if (responseData is Map) {
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          return responseData['data']['results'] as List;
        } else if (responseData['data'] is List) {
          return responseData['data'] as List;
        } else if (responseData['results'] is List) {
          return responseData['results'] as List;
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch idle timeouts error: $e');
      rethrow;
    }
  }

  /// Create idle timeout
  Future<Map<String, dynamic>?> createIdleTimeout(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/idle-timeout/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create idle timeout error: $e');
      rethrow;
    }
  }

  /// Update idle timeout
  Future<Map<String, dynamic>?> updateIdleTimeout(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/idle-timeout/$id/update/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update idle timeout error: $e');
      rethrow;
    }
  }

  /// Get idle timeout details
  Future<Map<String, dynamic>?> getIdleTimeoutDetails(int id) async {
    try {
      final response = await _dio.get('/idle-timeout/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get idle timeout details error: $e');
      rethrow;
    }
  }

  /// Delete idle timeout
  Future<bool> deleteIdleTimeout(int id) async {
    try {
      await _dio.delete('/idle-timeout/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete idle timeout error: $e');
      return false;
    }
  }
}
