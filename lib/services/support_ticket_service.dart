
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SupportTicketService {
  final Dio _dio;
  
  // As per instructions
  static const String _baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  static const String _apiKey = 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE';

  SupportTicketService({Dio? dio}) : _dio = dio ?? Dio();

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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Api-Key': _apiKey,
          },
          validateStatus: (status) => status! < 500, // Handle 400s manually
        ),
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

  // Convert country names to ISO 3166-1 alpha-2 codes
  String? _getCountryIsoCode(String? countryName) {
    if (countryName == null || countryName.isEmpty) return null;
    
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
