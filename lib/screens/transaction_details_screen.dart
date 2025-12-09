import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/currency_utils.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Map<String, dynamic>? _transactionDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (kDebugMode) {
      print('🔍 [TransactionDetails] Loading transaction details...');
      print('   Arguments: $args');
    }
    
    if (args == null) {
      if (kDebugMode) print('❌ [TransactionDetails] No arguments provided');
      setState(() {
        _error = 'No transaction ID provided';
        _isLoading = false;
      });
      return;
    }

    final id = args['id']?.toString();
    final type = args['type']?.toString() ?? 'wallet';

    if (kDebugMode) {
      print('   Transaction ID: $id');
      print('   Transaction Type: $type');
    }

    if (id == null || id == 'null' || id.isEmpty) {
      if (kDebugMode) print('❌ [TransactionDetails] Invalid transaction ID: $id');
      setState(() {
        _error = 'Invalid transaction ID';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) print('📡 [TransactionDetails] Fetching details from API...');
      final appState = context.read<AppState>();
      final details = await appState.getTransactionDetails(id, type);
      
      if (kDebugMode) {
        print('✅ [TransactionDetails] Details received:');
        print('   Response: $details');
      }
      
      setState(() {
        _transactionDetails = details['data'] as Map<String, dynamic>?;
        _isLoading = false;
      });
      
      if (kDebugMode) print('✅ [TransactionDetails] Details loaded successfully');
    } catch (e) {
      if (kDebugMode) print('❌ [TransactionDetails] Error loading details: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('transaction_details'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'error_occurred'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTransactionDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _transactionDetails == null
                  ? Center(child: Text('no_data_available'.tr()))
                  : RefreshIndicator(
                      onRefresh: _loadTransactionDetails,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Status Badge
                          Center(
                            child: _buildStatusBadge(_transactionDetails!['status'] ?? 'pending'),
                          ),
                          
                          // Payout Status Stepper
                          if ((_transactionDetails!['type'] ?? '').toString().toLowerCase().contains('payout') ||
                              (_transactionDetails!['type'] ?? '').toString().toLowerCase().contains('withdrawal'))
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: _buildPayoutStatusStepper(_transactionDetails!['status'] ?? 'pending'),
                            ),
                          
                          const SizedBox(height: 24),

                          // Amount Card
                          Card(
                            elevation: 0,
                            color: colorScheme.primaryContainer.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    'amount'.tr(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    CurrencyUtils.formatPrice(
                                      double.tryParse(_transactionDetails!['amount_paid']?.toString() ?? '0') ?? 0,
                                      appState.partnerCountry,
                                    ),
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Transaction Details Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'transaction_details'.tr(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow('Transaction ID', _transactionDetails!['id']?.toString() ?? 'N/A'),
                                  _buildDetailRow('Payment Reference', _transactionDetails!['payment_reference'] ?? 'N/A'),
                                  _buildDetailRow('Type', _transactionDetails!['type'] ?? 'N/A'),
                                  _buildDetailRow('Date', _transactionDetails!['formatted_created_at'] ?? 'N/A'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Customer Details Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'customer_details'.tr(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow('Username', _transactionDetails!['customer_username'] ?? 'N/A'),
                                  _buildDetailRow('Name', _transactionDetails!['customer_firstname'] ?? 'N/A'),
                                  _buildDetailRow('Email', _transactionDetails!['customer_email'] ?? 'N/A'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Related Plan Card (if available)
                          if (_transactionDetails!['related_model'] != null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'related_plan'.tr(),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      'Plan',
                                      (_transactionDetails!['related_model'] as Map)['display'] ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      'Model Type',
                                      (_transactionDetails!['related_model'] as Map)['model_name'] ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildPayoutStatusStepper(String status) {
    final steps = [
      {'title': 'Requested', 'isActive': true, 'isCompleted': true},
      {
        'title': 'Processing',
        'isActive': true,
        'isCompleted': status.toLowerCase() != 'pending'
      },
      {
        'title': status.toLowerCase() == 'failed' ? 'Failed' : 'Completed',
        'isActive': status.toLowerCase() == 'completed' ||
            status.toLowerCase() == 'success' ||
            status.toLowerCase() == 'failed',
        'isCompleted': status.toLowerCase() == 'completed' ||
            status.toLowerCase() == 'success' ||
            status.toLowerCase() == 'failed'
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              // Step Circle
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (steps[i]['isActive'] as bool)
                            ? ((steps[i]['title'] == 'Failed')
                                ? Colors.red
                                : colorScheme.primary)
                            : Colors.grey[300],
                      ),
                      child: (steps[i]['isCompleted'] as bool)
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: (steps[i]['isActive'] as bool)
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[i]['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: (steps[i]['isActive'] as bool)
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
                        fontWeight: (steps[i]['isActive'] as bool)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Connector Line
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: (steps[i + 1]['isActive'] as bool)
                        ? colorScheme.primary
                        : Colors.grey[300],
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        color = colorScheme.primary;
        icon = Icons.check_circle;
        label = 'Success';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        label = 'Pending';
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        label = 'Failed';
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
