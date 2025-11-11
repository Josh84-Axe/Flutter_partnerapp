import 'package:dio/dio.dart';

/// Repository for router operations
class RouterRepository {
  final Dio _dio;

  RouterRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of routers
  /// Note: Backend doesn't have /partner/routers/ endpoint
  /// Routers are extracted from /partner/plans/ response
  Future<List<dynamic>> fetchRouters() async {
    try {
      // Fetch plans which contain router data
      final response = await _dio.get('/partner/plans/');
      final responseData = response.data;
      
      // Extract routers from plans response
      if (responseData is Map && responseData['data'] is List) {
        final plans = responseData['data'] as List;
        final routersMap = <int, Map<String, dynamic>>{};
        
        // Collect unique routers from all plans
        for (final plan in plans) {
          if (plan is Map && plan['routers'] is List) {
            final routers = plan['routers'] as List;
            for (final router in routers) {
              if (router is Map) {
                final routerId = router['id'];
                if (routerId != null && !routersMap.containsKey(routerId)) {
                  routersMap[routerId] = router as Map<String, dynamic>;
                }
              }
            }
          }
        }
        
        return routersMap.values.toList();
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
  Future<Map<String, dynamic>?> addRouter(Map<String, dynamic> routerData) async {
    try {
      final response = await _dio.post('/partner/routers/add/', data: routerData);
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
