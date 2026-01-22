import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api/api_config.dart';

class TicketRepository {
  final Dio _dio;

  TicketRepository({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String description,
    String category = 'general',
    String priority = 'medium',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.ticketsUrl,
        data: {
          'subject': subject,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Error creating ticket: ${e.response?.data ?? e.message}');
      }
      throw Exception('Failed to create ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
       if (kDebugMode) {
        print('❌ [TicketRepository] Unknown error: $e');
      }
      throw Exception('An unexpected error occurred while creating the ticket.');
    }
  }
}
