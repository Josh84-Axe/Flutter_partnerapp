
import '../lib/services/support_ticket_service.dart';

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
      priority: 'LOW',
    );
    
    if (result) {
      print('✅ Ticket created successfully!');
    } else {
      print('❌ Failed to create ticket.');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
