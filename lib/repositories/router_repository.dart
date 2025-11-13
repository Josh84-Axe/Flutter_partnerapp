import 'package:dio/dio.dart';

/// Repository for router operations
class RouterRepository {
  final Dio _dio;

  RouterRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of routers
  /// Uses /partner/routers/list/ endpoint
  Future<List<dynamic>> fetchRouters() async {
    try {
      final response = await _dio.get('/partner/routers/list/');
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch routers error: $e');
      rethrow;
    }
  }

  /// Fetch router details by slug
  Future<Map<String, dynamic>?> fetchRouterDetails(String routerSlug) async {
    try {
      final response = await _dio.get('/partner/routers/$routerSlug/details/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Fetch router details error: $e');
      rethrow;
    }
  }

  /// Fetch active users on a router
  Future<List<dynamic>> fetchActiveUsers(String slug) async {
    try {
      final response = await _dio.get('/partner/routers/$slug/active-users/');
      final data = response.data;
      
      if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Fetch active users error: $e');
      rethrow;
    }
  }

  /// Fetch router resources
  Future<Map<String, dynamic>?> fetchRouterResources(String slug) async {
    try {
      final response = await _dio.get('/partner/routers/$slug/resources/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Fetch router resources error: $e');
      rethrow;
    }
  }

  /// Add a new router
  /// Required fields: name, ip_address, username, password
  /// Optional fields: secret, dns_name, api_port, coa_port
  Future<Map<String, dynamic>?> addRouter(Map<String, dynamic> routerData) async {
    try {
      final response = await _dio.post('/partner/routers-add/', data: routerData);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Add router error: $e');
      rethrow;
    }
  }

  /// Update router
  Future<Map<String, dynamic>?> updateRouter(String routerSlug, Map<String, dynamic> routerData) async {
    try {
      final response = await _dio.put('/partner/routers/$routerSlug/update/', data: routerData);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Update router error: $e');
      rethrow;
    }
  }

  /// Delete router
  Future<bool> deleteRouter(String routerId) async {
    try {
      await _dio.delete('/partner/routers/$routerId/delete/');
      return true;
    } catch (e) {
      print('Delete router error: $e');
      return false;
    }
  }

  /// Reboot router
  Future<bool> rebootRouter(String slug) async {
    try {
      await _dio.post('/partner/routers/$slug/reboot/');
      return true;
    } catch (e) {
      print('Reboot router error: $e');
      return false;
    }
  }

  /// Restart hotspot on router
  Future<bool> restartHotspot(String slug) async {
    try {
      await _dio.post('/partner/routers/$slug/hotspots/restart/');
      return true;
    } catch (e) {
      print('Restart hotspot error: $e');
      return false;
    }
  }
}
