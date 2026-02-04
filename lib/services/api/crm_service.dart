import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class CrmService {
  late final Dio _dio;

  CrmService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiHost, // Use apiHost as base for the new endpoint
      headers: {
        'X-API-KEY': ApiConfig.crmApiKey,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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

  Future<Response> submitSupportTicket({
    required String subject,
    required String description,
    required String email,
    required String name,
    String priority = 'HIGH',
  }) async {
    try {
      if (kDebugMode) print('📨 [CrmService] Submitting ticket to CRM: $subject');
      
      // Use the new endpoint relative to apiHost
      final response = await _dio.post('api/comms/external/messages/', data: {
        'contact_email': email,
        'contact_name': name,
        'content': 'Subject: $subject\n\n$description',
        // Note: priority is not expected by the new endpoint but kept in the method signature for compatibility
      });

      if (kDebugMode) print('✅ [CrmService] Ticket created: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [CrmService] Error submitting ticket: ${e.response?.data ?? e.message}');
      }
      rethrow;
    }
  }
}
