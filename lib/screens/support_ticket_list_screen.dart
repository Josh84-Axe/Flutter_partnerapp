import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import '../providers/split/auth_provider.dart';
import 'support_ticket_chat_screen.dart';

class SupportTicketListScreen extends StatefulWidget {
  const SupportTicketListScreen({super.key});

  @override
  State<SupportTicketListScreen> createState() => _SupportTicketListScreenState();
}

class _SupportTicketListScreenState extends State<SupportTicketListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchTickets());
  }

  void _fetchTickets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.currentUser?.email;
    if (email != null) {
      context.read<TicketProvider>().fetchTickets(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('my_support_tickets'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTickets,
          ),
        ],
      ),
      body: ticketProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ticketProvider.tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, 
                          size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('no_tickets_found'.tr()),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ticketProvider.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = ticketProvider.tickets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                        title: Text(
                          ticket.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${ticket.status ?? 'NEW'}',
                              style: TextStyle(
                                color: _getStatusColor(ticket.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (ticket.createdAt != null)
                              Text(
                                'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(ticket.createdAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupportTicketChatScreen(
                                ticketId: ticket.id,
                                subject: ticket.subject,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'CLOSED':
        return Colors.green;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
