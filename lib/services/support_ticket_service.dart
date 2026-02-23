
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SupportTicketService {
  final Dio _dio;
  Dio get dio => _dio;
  
  // As per instructions
  static const String _baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  static const String _apiKey = 'QNBBRFCO0rfnxFxS9buqx2cMjTbDwQEd3Zwhew_TXMI';

  SupportTicketService({Dio? dio}) : _dio = dio ?? Dio();

  Options _getOptions() {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': _apiKey,
      },
      validateStatus: (status) => status! < 500,
    );
  }

  Future<(bool success, String message, String? ticketId)> createTicket({
    required String subject,
    required String description,
    required String contactName,
    required String contactEmail,
    required String? partnerCountry,
    String priority = 'MEDIUM',
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        options: _getOptions(),
        data: {
          'subject': subject,
          'description': description,
          'contact_name': contactName,
          'contact_email': contactEmail,
          'country': _getCountryIsoCode(partnerCountry),
          'priority': priority,
        },
      );

      if (response.statusCode == 201) {
        if (kDebugMode) print('✅ Ticket created successfully: ${response.data}');
        final ticketId = response.data['id']?.toString() ?? 'ID Unknown';
        return (true, 'Ticket #$ticketId created successfully.', ticketId);
      } else {
        // Parse error response which might be a map of field errors
        String errorMsg = 'Unknown error';
        if (response.data is Map) {
          final errors = response.data as Map;
          // Flatten the error map
          errorMsg = errors.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        } else {
           errorMsg = 'Status: ${response.statusCode} - ${response.data}';
        }
        
        if (kDebugMode) print('❌ Failed to create ticket: $errorMsg');
        return (false, errorMsg, null);
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (kIsWeb && e.type == DioExceptionType.unknown && 
          (e.error.toString().contains('XMLHttpRequest error') || 
           e.error.toString().contains('onError callback'))) {
        errorMessage = 'Network Error (CORS): The request was blocked by the browser. Please check server CORS configuration for api.coleah.com.';
      }
      if (kDebugMode) print('❌ Dio Error creating ticket: $errorMessage');
      
      // We throw specifically for CORS so the UI can catch it and show the special "Likely Created" dialog
      // Or we could return a specific failure code. Raising exception is fine as it's an "Exceptional" network state.
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) print('❌ Error creating ticket: $e');
      rethrow;
    }
  }

  Future<Response> fetchTickets(String email) async {
    try {
      if (kDebugMode) print('📨 [SupportTicketService] Fetching tickets for: $email');
      
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'contact_email': email},
        options: _getOptions(),
      );

      return response;
    } on DioException catch (e) {
      if (kDebugMode) print('❌ Error fetching tickets: ${e.message}');
      rethrow;
    }
  }

  Future<Response> fetchMessages(String ticketId) async {
    try {
      if (kDebugMode) print('📨 [SupportTicketService] Fetching messages for ticket: $ticketId');
      
      final response = await _dio.get(
        '$_baseUrl$ticketId/messages/',
        options: _getOptions(),
      );

      return response;
    } on DioException catch (e) {
      if (kDebugMode) print('❌ Error fetching messages: ${e.message}');
      rethrow;
    }
  }

  Future<Response> replyToTicket(String ticketId, String content) async {
    try {
      if (kDebugMode) print('📨 [SupportTicketService] Replying to ticket: $ticketId');
      
      final response = await _dio.post(
        '$_baseUrl$ticketId/reply/',
        data: {'content': content},
        options: _getOptions(),
      );

      return response;
    } on DioException catch (e) {
      if (kDebugMode) print('❌ Error replying to ticket: ${e.message}');
      rethrow;
    }
  }

  // Convert country names to ISO 3166-1 alpha-2 codes
  String _getCountryIsoCode(String? countryName) {
    if (countryName == null || countryName.isEmpty) return 'SN'; // Default to Senegal
    
    // If it's already 2 chars, assume it's correct (e.g. NG, KE)
    if (countryName.length == 2) return countryName.toUpperCase();

    const countryMap = {
      'nigeria': 'NG',
      'kenya': 'KE',
      'ghana': 'GH',
      'south africa': 'ZA',
      'uganda': 'UG',
      'tanzania': 'TZ',
      'rwanda': 'RW',
      'côte d\'ivoire': 'CI',
      'cote d\'ivoire': 'CI',
      'ivory coast': 'CI',
      'senegal': 'SN',
      'cameroon': 'CM',
      'benin': 'BJ',
      'guinea': 'GN',
      'guinea-bissau': 'GW',
      'guinea bissau': 'GW',
      'mali': 'ML',
      'togo': 'TG',
      'united states': 'US',
      'united kingdom': 'GB',
    };

    return countryMap[countryName.toLowerCase()] ?? countryName; // Default to original if not found
  }
}
