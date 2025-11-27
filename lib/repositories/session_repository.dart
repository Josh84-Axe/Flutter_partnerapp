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
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        final sessions = responseData['data'] as List;
        if (kDebugMode) print('✅ [SessionRepo] Found ${sessions.length} active sessions');
        if (kDebugMode && sessions.isNotEmpty) print('   Sample session: ${sessions.first}');
        return sessions;
      }
      
      if (kDebugMode) print('⚠️  [SessionRepo] No data array found in response');
      return [];
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
