import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // TODO: Replace with actual support contact details
  static const String _supportEmail = 'support@example.com';
  static const String _supportWhatsApp = '1234567890'; // International format without +

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

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$_supportWhatsApp');
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('support_help'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support Section
          Text(
            'contact_support'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'Get a response within 24h',
                  color: Colors.blue,
                  onTap: _launchEmail,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContactCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'WhatsApp',
                  subtitle: 'Chat with support',
                  color: Colors.green,
                  onTap: _launchWhatsApp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // FAQ Section
          Text(
            'frequently_asked_questions'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            context,
            question: 'How do I reset my password?',
            answer: 'Go to Settings > Security > Change Password. If you forgot your password, use the "Forgot Password" link on the login screen.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I add a new router?',
            answer: 'Currently, routers are assigned by the admin. Please contact support if you need to add a new device to your account.',
          ),
          _buildFAQItem(
            context,
            question: 'When do I get paid?',
            answer: 'Payouts are processed weekly. You can view your transaction history and payout status in the "Reporting" section.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I update my profile?',
            answer: 'Go to Settings > Partner Profile. You can update your contact information there. Some fields may require admin approval.',
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
