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
      if (kDebugMode) debugPrint('🔄 [SessionRepo] Fetching active sessions from /sessions/active/');
      
      final response = await _dio.get('/sessions/active/');
      final responseData = response.data;
      
      if (kDebugMode) {
        debugPrint('📦 [SessionRepo] Response status: ${response.statusCode}');
        debugPrint('📦 [SessionRepo] Response type: ${responseData.runtimeType}');
      }
      
      List<dynamic> allSessions = [];
      
      // Response structure: { data: [ { router_dns_name, router_ip, active_users: [...] } ] }
      if (responseData is Map && responseData['data'] is List) {
        final routers = responseData['data'] as List;
        if (kDebugMode) debugPrint('✅ [SessionRepo] Found ${routers.length} routers');
        
        // Flatten active_users from all routers
        for (var router in routers) {
          if (router is Map && router['active_users'] is List) {
            final activeUsers = router['active_users'] as List;
            final routerName = router['router_dns_name'] ?? 'Unknown Router';
            final routerIp = router['router_ip'] ?? 'N/A';
            
            if (kDebugMode && activeUsers.isNotEmpty) {
              debugPrint('   📡 Router: $routerName ($routerIp) - ${activeUsers.length} active users');
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
          debugPrint('✅ [SessionRepo] Total active sessions across all routers: ${allSessions.length}');
          if (allSessions.isNotEmpty) {
            debugPrint('   📋 Sample session:');
            debugPrint('   ${allSessions.first}');
          }
        }
      }
      
      return allSessions;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [SessionRepo] Fetch active sessions error: $e');
      rethrow;
    }
  }

  /// Disconnect a session
  Future<bool> disconnectSession(Map<String, dynamic> sessionData) async {
    try {
      // Backend expects only: username, mac_address, ip_address, dns_name
      final payload = {
        'username': sessionData['username'],
        'mac_address': sessionData['mac_address'],
        'ip_address': sessionData['ip_address'],
        'dns_name': sessionData['dns_name'] ?? sessionData['router_name'], // Fallback to router_name if dns_name not present
      };
      
      if (kDebugMode) {
        debugPrint('🔌 [SessionRepo] Disconnecting session for ${payload['username']}');
        debugPrint('   Payload: $payload');
      }
      
      await _dio.post(
        '/sessions/disconnect/',
        data: payload,
      );
      
      if (kDebugMode) debugPrint('✅ [SessionRepo] Session disconnected successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [SessionRepo] Disconnect session error: $e');
      return false;
    }
  }
}
