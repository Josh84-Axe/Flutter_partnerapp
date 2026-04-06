import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/split/billing_provider.dart';
import '../providers/split/auth_provider.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../utils/file_handler/file_handler.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  String _selectedReportType = 'report_transaction_history'.tr();
  String _selectedFormat = 'CSV';
  DateTimeRange? _dateRange;
  bool _isGenerating = false;
  String? _selectedCollaborator;
  List<String> _collaboratorOptions = [];
  String? _selectedRouterFilter;
  List<String> _routerOptions = [];

  final List<String> _reportTypes = [
    'report_user_data_usage'.tr(),
    'report_transaction_history'.tr(),
    'report_router_performance'.tr(),
    'report_revenue'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _loadCollaborators();
    _loadRouterOptions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateReportTypes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCollaborators() async {
    try {
      final userProvider = context.read<UserProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // Ensure workers are loaded
      await userProvider.loadWorkers();
      
      if (!mounted) return;

      final List<String> options = [];
      
      // 1. Add All (default)
      options.add('all'.tr());
      
      // 2. Add Voucher
      options.add('voucher'.tr());

      // 3. Add Partner (currentUser)
      final partnerName = authProvider.currentUser?.name ?? 'Partner';
      options.add(partnerName);

      // 4. Add Workers/Managers
      for (var worker in userProvider.workers) {
        if (worker.fullName.isNotEmpty && !options.contains(worker.fullName)) {
          options.add(worker.fullName);
        }
      }

      setState(() {
        _collaboratorOptions = options;
        _selectedCollaborator = options.first; // Default to 'All'
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading collaborators for filter: $e');
    }
  }

  Future<void> _loadRouterOptions() async {
    try {
      final networkProvider = context.read<NetworkProvider>();
      
      // Load plans/routers if needed
      await networkProvider.loadPlans();
      
      if (!mounted) return;

      // Extract unique router names from plans
      final routerNames = networkProvider.plans
          .expand((plan) => plan.routers.map((r) => r.name))
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _routerOptions = ['all'.tr(), ...routerNames];
        _selectedRouterFilter = _routerOptions.first;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading routers for report filter: $e');
    }
  }

  void _updateReportTypes() {
    // Update list with translated strings
    _reportTypes.clear();
    _reportTypes.addAll([
      'report_user_data_usage'.tr(),
      'report_transaction_history'.tr(),
      'report_router_performance'.tr(),
      'report_revenue'.tr(),
    ]);
    
    // Reset selection if needed, or keep it if valid
    if (!_reportTypes.contains(_selectedReportType)) {
      _selectedReportType = 'report_transaction_history'.tr();
    }
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
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

  Future<void> _generateReport() async {
    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('msg_select_date_range'.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Only transaction history is supported for now
    if (_selectedReportType != 'report_transaction_history'.tr()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('msg_only_transaction_history'.tr())),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final billingProvider = context.read<BillingProvider>();
      final bytes = await billingProvider.generateReport(
        dateRange: _dateRange!,
        format: _selectedFormat,
        assignedBy: (_selectedCollaborator == null || _selectedCollaborator == 'all'.tr()) 
            ? null 
            : _selectedCollaborator,
        routerName: (_selectedRouterFilter == null || _selectedRouterFilter == 'all'.tr())
            ? null
            : _selectedRouterFilter,
      );
      
      if (!mounted) return;
      
      if (bytes != null) {
        final fileName = 'transactions_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.${_selectedFormat.toLowerCase()}';
        await FileHandler.saveAndLaunchFile(bytes, fileName);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('msg_report_generated_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('msg_failed_generate_report'.tr(args: [e.toString()])),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('data_export_reporting'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'generate_new_report'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'report_type'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Simple dropdown or radio list for report types
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReportType,
                isExpanded: true,
                items: _reportTypes.map((String type) {
                  // We need to map the display name back to the internal key or just use localized list
                  // For simplicity, let's localize the display
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReportType = newValue!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'date_range'.tr(),
            style: const TextStyle(
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
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRange == null
                          ? 'select_date_range'.tr()
                          : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                      style: TextStyle(
                        color: _dateRange == null ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_selectedReportType == 'report_transaction_history'.tr()) ...[
            Text(
              'filter_by_assigned_by'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCollaborator,
                  isExpanded: true,
                  hint: Text('select_item'.tr(namedArgs: {'item': 'assigned_by'.tr()})),
                  items: _collaboratorOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCollaborator = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'filter_by_router'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRouterFilter,
                  isExpanded: true,
                  hint: Text('select_item'.tr(namedArgs: {'item': 'router'.tr()})),
                  items: _routerOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRouterFilter = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          Text(
            'export_format'.tr(),
            style: const TextStyle(
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
              onPressed: _isGenerating ? null : _generateReport,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'generate_report'.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFormat == format;
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              format,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
