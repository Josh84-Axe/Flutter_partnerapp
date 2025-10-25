import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  String _selectedReportType = 'User Data Usage';
  String _selectedFormat = 'CSV';
  DateTimeRange? _dateRange;

  final List<String> _reportTypes = [
    'User Data Usage',
    'Transaction History',
    'Router Performance',
    'Revenue Report',
  ];

  final List<Map<String, dynamic>> _generatedReports = [
    {
      'type': 'Transaction History',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'format': 'PDF',
    },
    {
      'type': 'User Data Usage',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'format': 'CSV',
    },
  ];

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _generateReport() {
    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed('/report-preview', arguments: {
      'reportType': _selectedReportType,
      'dateRange': _dateRange,
      'format': _selectedFormat,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Export & Reporting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Generate New Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Report Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._reportTypes.map((type) {
            return RadioListTile<String>(
              value: type,
              groupValue: _selectedReportType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedReportType = value);
                }
              },
              title: Text(type),
              activeColor: AppTheme.primaryGreen,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
          const SizedBox(height: 20),
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRange == null
                          ? 'Select date range'
                          : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                      style: TextStyle(
                        color: _dateRange == null ? AppTheme.textLight : AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Export Format',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormatOption('CSV', Icons.table_chart),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormatOption('PDF', Icons.picture_as_pdf),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _generateReport,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Generate Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Generated Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._generatedReports.map((report) => _buildReportCard(report)).toList(),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, IconData icon) {
    final isSelected = _selectedFormat == format;
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              format,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Icon(
                report['format'] == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['type'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generated on ${DateFormat('MMM dd, yyyy').format(report['date'])}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report['format'],
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: () {},
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
