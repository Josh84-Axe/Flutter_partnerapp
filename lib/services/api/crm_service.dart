import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class CrmService {
  late final Dio _dio;
  Dio get dio => _dio;

  CrmService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.crmBaseUrl,
      headers: {
        'X-API-KEY': ApiConfig.crmApiKey,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // Optional: Add logging if in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
    }
  }

  /// List tickets for a specific contact email
  Future<Response> fetchTickets(String email) async {
    try {
      if (kDebugMode) print('📨 [CrmService] Fetching tickets for: $email');
      
      final response = await _dio.get('', queryParameters: {
        'contact_email': email,
      });

      if (kDebugMode) print('✅ [CrmService] Tickets fetched: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'Fetching Tickets');
      rethrow;
    }
  }

  /// Create a new ticket in Coleah CRM
  Future<Response> createTicket({
    required String subject,
    required String description,
    required String email,
    required String name,
    String priority = 'LOW',
  }) async {
    try {
      if (kDebugMode) print('📨 [CrmService] Creating ticket in Coleah CRM: $subject');
      
      final response = await _dio.post('', data: {
        'subject': subject,
        'description': description,
        'contact_email': email,
        'contact_name': name,
        'priority': priority,
      });

      if (kDebugMode) print('✅ [CrmService] Ticket created: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'Creating Ticket');
      rethrow;
    }
  }

  /// Fetch message history for a specific case
  Future<Response> fetchMessages(String caseId) async {
    try {
      if (kDebugMode) print('📨 [CrmService] Fetching messages for case: $caseId');
      
      final response = await _dio.get('$caseId/messages/');
      
      if (kDebugMode) print('✅ [CrmService] Messages fetched: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'Fetching Messages');
      rethrow;
    }
  }

  /// Reply to an existing ticket
  Future<Response> replyToTicket(String caseId, String content) async {
    try {
      if (kDebugMode) print('📨 [CrmService] Replying to case: $caseId');
      
      final response = await _dio.post('$caseId/reply/', data: {
        'content': content,
      });

      if (kDebugMode) print('✅ [CrmService] Reply sent: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'Replying to Ticket');
      rethrow;
    }
  }

  /// Centralized error handling for CRM API
  void _handleDioError(DioException e, String action) {
    if (e.response?.statusCode == 401) {
      if (kDebugMode) print('❌ [CrmService] 401 Unauthorized: Invalid CRM API Key');
      // Potential to notify AuthProvider or similar if centralized session management is needed
    } else if (e.response?.statusCode == 400) {
      if (kDebugMode) print('❌ [CrmService] 400 Bad Request: Invalid payload format during $action');
    } else {
      if (kDebugMode) {
        print('❌ [CrmService] Error during $action: ${e.response?.data ?? e.message}');
      }
    }
  }

  /// Legacy method kept for compatibility if needed during transition
  Future<Response> submitSupportTicket({
    required String subject,
    required String description,
    required String email,
    required String name,
    String priority = 'HIGH',
  }) async {
    return createTicket(
      subject: subject,
      description: description,
      email: email,
      name: name,
      priority: priority,
    );
  }
}
