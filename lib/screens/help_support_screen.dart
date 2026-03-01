import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/create_ticket_dialog.dart';
import 'support_ticket_list_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Support contact details
  static const String _supportEmail = 'assist@tiknetafrica.com';

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Support Request: Partner App',
      }),
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showCreateTicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTicketDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support_help'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header Section
          Text(
            'contact_support'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'choose_support_method'.tr(), // Make sure this exists or use a fallback
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),

          // Support Actions Hub
          _buildActionCard(
            context,
            icon: Icons.add_circle_outline_rounded,
            title: 'create_ticket'.tr(),
            subtitle: 'response_time_msg'.tr(),
            color: AppTheme.brandGreen,
            onTap: () => _showCreateTicketDialog(context),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.question_answer_outlined,
            title: 'my_support_tickets'.tr(),
            subtitle: 'view_ticket_history'.tr(),
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportTicketListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: _supportEmail,
            color: Colors.blueGrey,
            onTap: _launchEmail,
          ),

          const SizedBox(height: 48),

          // FAQ Section
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'frequently_asked_questions'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            context,
            question: 'faq_reset_password_q'.tr(),
            answer: 'faq_reset_password_a'.tr(),
          ),
          _buildFAQItem(
            context,
            question: 'faq_add_router_q'.tr(),
            answer: 'faq_add_router_a'.tr(),
          ),
          _buildFAQItem(
            context,
            question: 'faq_payout_q'.tr(),
            answer: 'faq_payout_a'.tr(),
          ),
          _buildFAQItem(
            context,
            question: 'faq_update_profile_q'.tr(),
            answer: 'faq_update_profile_a'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary 
            ? BorderSide(color: color.withValues(alpha: 0.3), width: 1)
            : BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: Colors.grey.withValues(alpha: 0.5), 
                  size: 16
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
