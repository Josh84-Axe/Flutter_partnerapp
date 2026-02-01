import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api/api_config.dart';
import '../services/api/crm_service.dart';

class TicketRepository {
  final Dio _dio;
  final CrmService _crmService;

  TicketRepository({
    required Dio dio,
    CrmService? crmService,
  }) : _dio = dio,
       _crmService = crmService ?? CrmService();

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
      
      if (e.response?.statusCode == 530) {
        throw Exception('CRM Server configuration error (530). Please try again later or contact support.');
      }
      
      throw Exception('Failed to create ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Unknown error: $e');
      }
      throw Exception('An unexpected error occurred while creating the ticket.');
    }
  }

  /// Creates a ticket in the external CRM system
  Future<bool> createCrmTicket({
    required String subject,
    required String description,
    required String email,
    required String name,
    String priority = 'HIGH',
  }) async {
    try {
      final response = await _crmService.submitSupportTicket(
        subject: subject,
        description: description,
        email: email,
        name: name,
        priority: priority,
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] CRM Ticket Error: $e');
      }
      rethrow;
    }
  }
}
