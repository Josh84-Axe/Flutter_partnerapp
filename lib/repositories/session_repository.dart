import 'package:dio/dio.dart';

/// Repository for session management operations
class SessionRepository {
  final Dio _dio;

  SessionRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of active sessions
  Future<List<dynamic>> fetchActiveSessions() async {
    try {
      final response = await _dio.get('/partner/sessions/active/');
      final responseData = response.data;
      
      // API returns: {statusCode, error, message, data: [...], exception}
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch active sessions error: $e');
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
      print('Disconnect session error: $e');
      return false;
    }
  }
}
