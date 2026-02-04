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
    required String email,
    required String name,
    String category = 'general',
    String priority = 'medium',
  }) async {
    try {
      final success = await createCrmTicket(
        subject: subject,
        description: description,
        email: email,
        name: name,
        priority: priority.toUpperCase(),
      );
      
      return {'success': success};
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Error creating ticket: $e');
      }
      throw Exception('Failed to create ticket: $e');
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
