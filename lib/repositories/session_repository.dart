import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for session management operations
class SessionRepository {
  final Dio _dio;

  SessionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of active sessions
  /// API returns data grouped by routers, each with active_users array
  Future<List<dynamic>> fetchActiveSessions() async {
    try {
      if (kDebugMode) print('🔄 [SessionRepo] Fetching active sessions from /partner/sessions/active/');
      
      final response = await _dio.get('/partner/sessions/active/');
      final responseData = response.data;
      
      if (kDebugMode) {
        print('📦 [SessionRepo] Response status: ${response.statusCode}');
        print('📦 [SessionRepo] Response type: ${responseData.runtimeType}');
      }
      
      List<dynamic> allSessions = [];
      
      // Response structure: { data: [ { router_dns_name, router_ip, active_users: [...] } ] }
      if (responseData is Map && responseData['data'] is List) {
        final routers = responseData['data'] as List;
        if (kDebugMode) print('✅ [SessionRepo] Found ${routers.length} routers');
        
        // Flatten active_users from all routers
        for (var router in routers) {
          if (router is Map && router['active_users'] is List) {
            final activeUsers = router['active_users'] as List;
            final routerName = router['router_dns_name'] ?? 'Unknown Router';
            final routerIp = router['router_ip'] ?? 'N/A';
            
            if (kDebugMode && activeUsers.isNotEmpty) {
              print('   📡 Router: $routerName ($routerIp) - ${activeUsers.length} active users');
            }
            
            // Add router info to each session for context
            for (var user in activeUsers) {
              if (user is Map) {
                final enrichedUser = Map<String, dynamic>.from(user);
                enrichedUser['router_name'] = routerName;
                enrichedUser['router_ip'] = routerIp;
                allSessions.add(enrichedUser);
              }
            }
          }
        }
        
        if (kDebugMode) {
          print('✅ [SessionRepo] Total active sessions across all routers: ${allSessions.length}');
          if (allSessions.isNotEmpty) {
            print('   📋 Sample session:');
            print('   ${allSessions.first}');
          }
        }
      }
      
      return allSessions;
    } catch (e) {
      if (kDebugMode) print('❌ [SessionRepo] Fetch active sessions error: $e');
      rethrow;
    }
  }

  /// Disconnect a session
  Future<bool> disconnectSession(Map<String, dynamic> sessionData) async {
    try {
      await _dio.post(
        '/partner/sessions/disconnect/',
        data: sessionData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) print('Disconnect session error: $e');
      return false;
    }
  }
}
