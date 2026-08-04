import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot_partner_app/services/support_ticket_service.dart';

void main() {
  const String testEmail = 'sientey@hotmail.com';
  const String testName = 'QA Bot';

  test('SupportTicketService Dynamic Feedback QA', () async {
    print('\n--- Starting Dynamic Ticket Feedback QA ---');
    
    final service = SupportTicketService();
    
    // 1. Success Case
    print('\n1. Testing SUCCESS case...');
    try {
      final (success, message, ticketId) = await service.createTicket(
        subject: 'QA Test: Dynamic Feedback Verification',
        description: 'Verifying that the API returns a Ticket ID and success message.',
        contactName: testName,
        contactEmail: testEmail,
        partnerCountry: 'Guinea-Bissau', // Test routing
        priority: 'LOW',
      );

      print('Result: success=$success');
      print('Message: "$message"');
      print('Ticket ID: $ticketId');
      
      if (success && ticketId != null && message.contains(ticketId)) {
        print('✅ SUCCESS VERIFIED: Message contains the Ticket ID.');
      } else {
        print('❌ FAILURE: Message format incorrect or ID missing.');
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
    }

    // 2. Failure Case (Missing Subject)
    print('\n2. Testing FAILURE case (Missing Fields)...');
    try {
      // Intentionally passing empty subject to trigger validation error
      final (success, message, ticketId) = await service.createTicket(
        subject: '', 
        description: 'This should fail validation.',
        contactName: testName,
        contactEmail: testEmail,
        partnerCountry: 'Guinea-Bissau',
      );

      print('Result: success=$success');
      print('Message: "$message"');
      
      if (!success && message.toLowerCase().contains('required')) {
        print('✅ FAILURE VERIFIED: Message contains validation error details.');
      } else {
        print('❌ FAILURE: Did not receive expected validation error.');
      }
    } catch (e) {
        // DioExceptions might wrap the error so catch generic
      print('❌ EXCEPTION caught: $e');
    }
  });
}
