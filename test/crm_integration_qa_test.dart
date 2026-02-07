import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hotspot_partner_app/services/api/api_config.dart';
import 'package:hotspot_partner_app/services/api/crm_service.dart';

void main() {
  test('CRM Integration QA Test', () async {
    print('--- CRM Integration QA Test ---');
    
    final crmService = CrmService();
    
    // Bypass SSL verification for testing
    (crmService.dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    
    final testSubject = 'QA Test Ticket - ${DateTime.now().toIso8601String()}';
    final testDescription = 'This is an automated QA test ticket to verify the integrated Coleah CRM Partner API.';
    final testEmail = 'qa_test@example.com';
    final testName = 'QA Tester';

    try {
      print('Testing Ticket Creation...');
      final response = await crmService.createTicket(
        subject: testSubject,
        description: testDescription,
        email: testEmail,
        name: testName,
        priority: 'LOW',
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${jsonEncode(response.data)}');

      expect(response.statusCode, anyOf(200, 201));
      
      final dynamic data = response.data;
      String? caseId;
      if (data is Map && data.containsKey('id')) {
        caseId = data['id'].toString();
      } else if (data is Map && data.containsKey('case_id')) {
        caseId = data['case_id'].toString();
      }

      if (caseId != null) {
        print('Testing Fetch Messages for Case: $caseId...');
        final msgResponse = await crmService.fetchMessages(caseId);
        print('Messages Response Status: ${msgResponse.statusCode}');
        print('Messages Data: ${jsonEncode(msgResponse.data)}');
        expect(msgResponse.statusCode, 200);
        
        print('Testing Reply to Case: $caseId...');
        final replyResponse = await crmService.replyToTicket(caseId, 'QA Follow-up message');
        print('Reply Response Status: ${replyResponse.statusCode}');
        print('Reply Data: ${jsonEncode(replyResponse.data)}');
        expect(replyResponse.statusCode, anyOf(200, 201));
      } else {
        print('⚠️ No Case ID returned in response data, skipping message/reply tests.');
      }
    } catch (e) {
      print('❌ Error during QA test: $e');
      fail('QA Test failed with exception: $e');
    }
  });
}
