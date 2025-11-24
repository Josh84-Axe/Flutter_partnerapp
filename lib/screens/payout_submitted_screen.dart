import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/app_state.dart';

class PayoutSubmittedScreen extends StatelessWidget {
  const PayoutSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingRef = context.read<AppState>().lastWithdrawalId ?? 'TXN${DateTime.now().millisecondsSinceEpoch}';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('payout_submitted'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Your Payout is Being Processed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You will receive a confirmation email once the payout is complete.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tracking Reference',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      trackingRef,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: trackingRef));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Tracking reference copied'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'processing_time'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                const Text(
                                  '1-2 business days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'View Transaction History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
