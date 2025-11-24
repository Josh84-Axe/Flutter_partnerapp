import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for router operations
class RouterRepository {
  final Dio _dio;

  RouterRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of routers
  /// Uses /partner/routers/list/ endpoint
  Future<List<dynamic>> fetchRouters() async {
    try {
      if (kDebugMode) print('🌐 [RouterRepository] Fetching routers list');
      final response = await _dio.get('/partner/routers/list/');
      if (kDebugMode) print('✅ [RouterRepository] Fetch routers response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [RouterRepository] Fetch routers response data: ${response.data}');
      
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final routers = responseData['data'] as List;
        if (kDebugMode) print('✅ [RouterRepository] Found ${routers.length} routers');
        return routers;
      }
      
      if (kDebugMode) print('⚠️ [RouterRepository] No routers found in response');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Fetch routers error: $e');
      rethrow;
    }
  }

  /// Fetch router details by slug
  Future<Map<String, dynamic>?> fetchRouterDetails(String routerSlug) async {
    try {
      if (kDebugMode) print('🔍 [RouterRepository] Fetching router details for: $routerSlug');
      final response = await _dio.get('/partner/routers/$routerSlug/details/');
      if (kDebugMode) print('✅ [RouterRepository] Router details response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Fetch router details error: $e');
      rethrow;
    }
  }

  /// Fetch active users on a router
  Future<List<dynamic>> fetchActiveUsers(String slug) async {
    try {
      if (kDebugMode) print('👥 [RouterRepository] Fetching active users for router: $slug');
      final response = await _dio.get('/partner/routers/$slug/active-users/');
      final data = response.data;
      
      if (data is List) {
        if (kDebugMode) print('✅ [RouterRepository] Found ${data.length} active users');
        return data;
      }
      
      if (kDebugMode) print('⚠️ [RouterRepository] No active users found');
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Fetch active users error: $e');
      rethrow;
    }
  }

  /// Fetch router resources
  Future<Map<String, dynamic>?> fetchRouterResources(String slug) async {
    try {
      if (kDebugMode) print('📊 [RouterRepository] Fetching router resources for: $slug');
      final response = await _dio.get('/partner/routers/$slug/resources/');
      if (kDebugMode) print('✅ [RouterRepository] Router resources response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Fetch router resources error: $e');
      rethrow;
    }
  }

  /// Add a new router
  /// Required fields: name, ip_address, username, password
  /// Optional fields: secret, dns_name, api_port, coa_port
  Future<Map<String, dynamic>?> addRouter(Map<String, dynamic> routerData) async {
    try {
      if (kDebugMode) print('➕ [RouterRepository] Adding new router: ${routerData['name']}');
      if (kDebugMode) print('📦 [RouterRepository] Router data: $routerData');
      final response = await _dio.post('/partner/routers-add/', data: routerData);
      if (kDebugMode) print('✅ [RouterRepository] Add router response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [RouterRepository] Add router response data: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Add router error: $e');
      rethrow;
    }
  }

  /// Update router
  Future<Map<String, dynamic>?> updateRouter(String routerSlug, Map<String, dynamic> routerData) async {
    try {
      if (kDebugMode) print('✏️ [RouterRepository] Updating router: $routerSlug');
      if (kDebugMode) print('📦 [RouterRepository] Update data: $routerData');
      final response = await _dio.put('/partner/routers/$routerSlug/update/', data: routerData);
      if (kDebugMode) print('✅ [RouterRepository] Update router response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Update router error: $e');
      rethrow;
    }
  }

  /// Delete router
  Future<bool> deleteRouter(String routerId) async {
    try {
      if (kDebugMode) print('🗑️ [RouterRepository] Deleting router: $routerId');
      await _dio.delete('/partner/routers/$routerId/delete/');
      if (kDebugMode) print('✅ [RouterRepository] Router deleted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Delete router error: $e');
      return false;
    }
  }

  /// Reboot router
  Future<bool> rebootRouter(String slug) async {
    try {
      if (kDebugMode) print('🔄 [RouterRepository] Rebooting router: $slug');
      await _dio.post('/partner/routers/$slug/reboot/');
      if (kDebugMode) print('✅ [RouterRepository] Router reboot initiated');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Reboot router error: $e');
      return false;
    }
  }

  /// Restart hotspot on router
  Future<bool> restartHotspot(String slug) async {
    try {
      if (kDebugMode) print('🔄 [RouterRepository] Restarting hotspot on router: $slug');
      await _dio.post('/partner/routers/$slug/hotspots/restart/');
      if (kDebugMode) print('✅ [RouterRepository] Hotspot restart initiated');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [RouterRepository] Restart hotspot error: $e');
      return false;
    }
  }
}
