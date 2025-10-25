import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final reportType = args?['reportType'] as String? ?? 'User Data Usage';
    final dateRange = args?['dateRange'] as DateTimeRange?;
    final format = args?['format'] as String? ?? 'CSV';

    final sampleData = [
      {
        'userId': 'U001',
        'name': 'Alice Johnson',
        'loginTime': DateTime.now().subtract(const Duration(hours: 2)),
        'ipAddress': '192.168.1.100',
        'status': 'Active',
      },
      {
        'userId': 'U002',
        'name': 'Bob Smith',
        'loginTime': DateTime.now().subtract(const Duration(hours: 5)),
        'ipAddress': '192.168.1.101',
        'status': 'Active',
      },
      {
        'userId': 'U003',
        'name': 'Carol White',
        'loginTime': DateTime.now().subtract(const Duration(hours: 8)),
        'ipAddress': '192.168.1.102',
        'status': 'Inactive',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Report Type', reportType),
                const SizedBox(height: 8),
                if (dateRange != null)
                  _buildDetailRow(
                    'Date Range',
                    '${DateFormat('MMM dd, yyyy').format(dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(dateRange.end)}',
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                    columns: const [
                      DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Login Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('IP Address', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: sampleData.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text(data['userId'] as String)),
                          DataCell(Text(data['name'] as String)),
                          DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(data['loginTime'] as DateTime))),
                          DataCell(Text(data['ipAddress'] as String)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: data['status'] == 'Active'
                                    ? AppTheme.successGreen.withOpacity(0.1)
                                    : AppTheme.textLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data['status'] as String,
                                style: TextStyle(
                                  color: data['status'] == 'Active' ? AppTheme.successGreen : AppTheme.textLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                      child: const Text(
                        'Revise Criteria',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/export-success', arguments: {
                          'reportType': reportType,
                          'format': format,
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Export Report',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
