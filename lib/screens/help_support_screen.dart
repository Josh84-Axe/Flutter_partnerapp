import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/create_ticket_dialog.dart';
import 'support_ticket_list_screen.dart';
import '../flavors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'assist@tiknetafrica.com';

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Support Request: ${F.name.toUpperCase()} App',
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('support_help'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header Section
          Text(
            'contact_support'.tr(),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'choose_support_method'.tr(),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Support Actions Hub
          _buildActionCard(
            context,
            icon: Icons.add_circle_outline_rounded,
            title: 'create_ticket'.tr(),
            subtitle: 'response_time_msg'.tr(),
            color: scheme.primary,
            onTap: () => _showCreateTicketDialog(context),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.question_answer_outlined,
            title: 'my_support_tickets'.tr(),
            subtitle: 'view_ticket_history'.tr(),
            color: scheme.secondary,
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
            title: 'email_support'.tr(),
            subtitle: _supportEmail,
            color: scheme.tertiary,
            onTap: _launchEmail,
          ),

          const SizedBox(height: 40),

          // FAQ Section Header
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 22, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'frequently_asked_questions'.tr(),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Variant-aware FAQ items
          ..._buildVariantFAQs(context),
        ],
      ),
    );
  }

  List<Widget> _buildVariantFAQs(BuildContext context) {
    if (F.name == 'family') {
      return [
        _buildFAQItem(
          context,
          question: 'faq_family_pause_q'.tr(),
          answer: 'faq_family_pause_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_family_rules_q'.tr(),
          answer: 'faq_family_rules_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_family_wifi_q'.tr(),
          answer: 'faq_family_wifi_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_family_account_q'.tr(),
          answer: 'faq_family_account_a'.tr(),
        ),
      ];
    } else if (F.name == 'campus') {
      return [
        _buildFAQItem(
          context,
          question: 'faq_campus_connect_q'.tr(),
          answer: 'faq_campus_connect_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_campus_focus_q'.tr(),
          answer: 'faq_campus_focus_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_campus_account_q'.tr(),
          answer: 'faq_campus_account_a'.tr(),
        ),
      ];
    } else {
      return [
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
          question: 'faq_reset_password_q'.tr(),
          answer: 'faq_reset_password_a'.tr(),
        ),
        _buildFAQItem(
          context,
          question: 'faq_update_profile_q'.tr(),
          answer: 'faq_update_profile_a'.tr(),
        ),
      ];
    }
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isPrimary 
              ? color.withValues(alpha: 0.4) 
              : scheme.outlineVariant.withValues(alpha: 0.5), 
            width: isPrimary ? 1.5 : 1,
          ),
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
                    color: color.withValues(alpha: 0.12),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5), 
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: scheme.onSurface,
          ),
        ),
        iconColor: scheme.primary,
        collapsedIconColor: scheme.onSurfaceVariant,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
