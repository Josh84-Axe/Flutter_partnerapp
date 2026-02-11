
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SupportTicketService {
  final Dio _dio;
  
  // As per instructions
  static const String _baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  static const String _apiKey = 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE';

  SupportTicketService({Dio? dio}) : _dio = dio ?? Dio();

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String contactName,
    required String contactEmail,
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
          'priority': priority,
        },
      );

      if (response.statusCode == 201) {
        if (kDebugMode) print('✅ Ticket created successfully: ${response.data}');
        return true;
      } else {
        final errorMsg = response.data is Map ? response.data.toString() : 'Status: ${response.statusCode}';
        if (kDebugMode) print('❌ Failed to create ticket: $errorMsg');
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (kIsWeb && e.type == DioExceptionType.unknown && e.error.toString().contains('XMLHttpRequest error')) {
        errorMessage = 'Network Error (CORS): The request was blocked by the browser. Please check server CORS configuration.';
      }
      if (kDebugMode) print('❌ Dio Error creating ticket: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) print('❌ Error creating ticket: $e');
      rethrow;
    }
  }
}
