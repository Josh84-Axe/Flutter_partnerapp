import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for session management operations
class SessionRepository {
  final Dio _dio;

  SessionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of active sessions
  Future<List<dynamic>> fetchActiveSessions() async {
    try {
      if (kDebugMode) print('🔄 [SessionRepo] Fetching active sessions from /partner/sessions/active/');
      
      final response = await _dio.get('/partner/sessions/active/');
      final responseData = response.data;
      
      if (kDebugMode) {
        print('📦 [SessionRepo] Response status: ${response.statusCode}');
        print('📦 [SessionRepo] Response type: ${responseData.runtimeType}');
        print('📦 [SessionRepo] Full response: $responseData');
      }
      
      List<dynamic> sessions = [];
      
      // Try different response structures
      if (responseData is Map) {
        // Check for data.results (nested structure)
        if (responseData['data'] is Map && responseData['data']['results'] is List) {
          sessions = responseData['data']['results'] as List;
          if (kDebugMode) print('✅ [SessionRepo] Found data in nested structure: data.results');
        }
        // Check for data array (flat structure)
        else if (responseData['data'] is List) {
          sessions = responseData['data'] as List;
          if (kDebugMode) print('✅ [SessionRepo] Found data in flat structure: data');
        }
        // Check for results array (direct structure)
        else if (responseData['results'] is List) {
          sessions = responseData['results'] as List;
          if (kDebugMode) print('✅ [SessionRepo] Found data in direct structure: results');
        }
      }
      // Response is directly a list
      else if (responseData is List) {
        sessions = responseData;
        if (kDebugMode) print('✅ [SessionRepo] Response is directly a list');
      }
      
      if (kDebugMode) {
        print('✅ [SessionRepo] Found ${sessions.length} active sessions');
        if (sessions.isNotEmpty) {
          print('   📋 First session structure:');
          print('   ${sessions.first}');
          if (sessions.first is Map) {
            final keys = (sessions.first as Map).keys.toList();
            print('   🔑 Available keys: $keys');
            
            // Check for customer_id specifically
            final firstSession = sessions.first as Map;
            if (firstSession.containsKey('customer_id')) {
              print('   ✅ Found customer_id: ${firstSession['customer_id']}');
            }
            if (firstSession.containsKey('username')) {
              print('   ✅ Found username: ${firstSession['username']}');
            }
          }
        }
      }
      
      return sessions;
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
