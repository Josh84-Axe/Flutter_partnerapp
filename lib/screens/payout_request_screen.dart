import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';

class PayoutRequestScreen extends StatefulWidget {
  const PayoutRequestScreen({super.key});

  @override
  State<PayoutRequestScreen> createState() => _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends State<PayoutRequestScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = '';
  double _requestedAmount = 0.0;
  double _feeAmount = 0.0;
  double _finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateFees);
    // Load payment methods when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadPaymentMethods().then((_) {
        if (mounted && appState.paymentMethods.isNotEmpty && _selectedMethod.isEmpty) {
          setState(() {
            // Select first method by default
            final firstMethod = appState.paymentMethods.first;
            _selectedMethod = firstMethod['id']?.toString() ?? '';
            _calculateFees();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateFees() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    // Find the selected method type
    String methodType = 'mobile_money'; // Default fallback
    
    if (_selectedMethod.isNotEmpty) {
      final appState = context.read<AppState>();
      // Find the method object that matches the selected slug
      final selectedMethodObj = appState.paymentMethods.firstWhere(
        (m) => m['id']?.toString() == _selectedMethod,
        orElse: () => null,
      );
      
      if (selectedMethodObj != null) {
        methodType = selectedMethodObj['method_type']?.toString() ?? 'mobile_money';
      }
    }

    setState(() {
      _requestedAmount = amount;
      _feeAmount = methodType == 'mobile_money' ? amount * 0.02 : amount * 0.015;
      _finalAmount = amount - _feeAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('request_payout'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Withdrawable Balance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.formatMoney(appState.totalBalance),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Online: ${appState.formatMoney(appState.walletBalance)} • Assigned: ${appState.formatMoney(appState.assignedWalletBalance)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payout Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          prefixText: '${appState.currencySymbol} ',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        _amountController.text = appState.totalBalance.toStringAsFixed(2);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Max'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).pushNamed('/add-payout-method');
                        if (result == true && context.mounted) {
                          // Reload payment methods after adding new one
                          context.read<AppState>().loadPaymentMethods();
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Dynamic payment methods list
                appState.paymentMethods.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No payment methods added',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a payment method to request payouts',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.of(context).pushNamed('/add-payout-method');
                                  if (result == true && context.mounted) {
                                    context.read<AppState>().loadPaymentMethods();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Payment Method'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: appState.paymentMethods.map((method) {
                          final methodType = method['method_type']?.toString() ?? '';
                          final provider = method['provider']?.toString() ?? '';
                          final accountNumber = method['account_number']?.toString() ?? '';
                          final id = method['id']?.toString() ?? '';
                          
                          return _buildMethodCard(
                            provider,
                            accountNumber,
                            methodType,
                            id,
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fee Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Applicable Fee',
                              style: TextStyle(color: AppTheme.textLight),
                            ),
                            Text(
                              _selectedMethod == 'mobile_money' ? '2%' : '1.5%',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Processing Time',
                              style: TextStyle(color: AppTheme.textLight),
                            ),
                            Text(
                              _selectedMethod == 'mobile_money' ? '1-2 hours' : '2-3 days',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Amount Requested', _requestedAmount),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Fees', _feeAmount, isNegative: true),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'You Will Receive',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              appState.formatMoney(_finalAmount),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
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
                  onPressed: _requestedAmount > 0 && _selectedMethod.isNotEmpty ? () async {
                    final success = await context.read<AppState>().requestPayout(_requestedAmount, _selectedMethod);
                    if (!mounted) return;
                    
                    if (success) {
                      Navigator.of(context).pushReplacementNamed('/payout-submitted');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to submit payout request. Please try again.'),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                    }
                  } : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'request_payout'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
          _calculateFees();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : AppTheme.textLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : AppTheme.textLight,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isNegative = false}) {
    final appState = context.read<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textLight),
        ),
        Text(
          '${isNegative ? '-' : ''}${appState.formatMoney(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isNegative ? AppTheme.errorRed : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMethodCard(String provider, String accountNumber, String methodType, String id) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedMethod == id;
    final icon = methodType == 'mobile_money' ? Icons.phone_android : Icons.account_balance;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : AppTheme.textLight.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = id;
            _calculateFees();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : AppTheme.textLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isSelected ? colorScheme.primary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountNumber,
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
