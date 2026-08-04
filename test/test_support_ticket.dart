
import 'package:hotspot_partner_app/services/support_ticket_service.dart';

void main() async {
  print('🧪 Testing SupportTicketService...');
  
  final service = SupportTicketService();
  
  try {
    print('🚀 Sending test ticket...');
    final result = await service.createTicket(
      subject: 'Test Ticket from Automated Script',
      description: 'This is a test ticket to verify the API integration.',
      contactName: 'Antigravity Test User',
      contactEmail: 'antigravity_test@tiknetafrica.com',
      partnerCountry: 'GN',
      priority: 'LOW',
    );
    
    if (result.$1) {
      print('✅ Ticket created successfully! ID: ${result.$3}');
    } else {
      print('❌ Failed to create ticket: ${result.$2}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
