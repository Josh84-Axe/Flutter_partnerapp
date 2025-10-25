import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

class ExportSuccessScreen extends StatelessWidget {
  const ExportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final reportType = args?['reportType'] as String? ?? 'Report';
    final format = args?['format'] as String? ?? 'CSV';
    final trackingId = 'RPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.successGreen.withOpacity(0.1),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Export Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your report has been sent to your email',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Report Type',
                      value: reportType,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.insert_drive_file,
                      label: 'Format',
                      value: format,
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, size: 20, color: AppTheme.textLight),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tracking ID',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    trackingId,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: trackingId));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tracking ID copied'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
