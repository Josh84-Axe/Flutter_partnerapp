import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api/api_config.dart';
import '../services/api/crm_service.dart';
import '../models/crm_ticket_model.dart';

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
    String priority = 'LOW',
  }) async {
    try {
      final response = await _crmService.createTicket(
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

  /// Fetches all tickets for a specific email
  Future<List<CrmTicket>> fetchTickets(String email) async {
    try {
      final response = await _crmService.fetchTickets(email);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CrmTicket.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Error fetching tickets: $e');
      }
      rethrow;
    }
  }

  /// Fetches conversation history for a specific ticket
  Future<List<CrmMessage>> fetchTicketMessages(String caseId) async {
    try {
      final response = await _crmService.fetchMessages(caseId);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CrmMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Error fetching messages: $e');
      }
      rethrow;
    }
  }

  /// Sends a reply to an existing ticket
  Future<bool> replyToTicket(String caseId, String content) async {
    try {
      final response = await _crmService.replyToTicket(caseId, content);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [TicketRepository] Error replying to ticket: $e');
      }
      rethrow;
    }
  }
}
