import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split/user_provider.dart';
import '../utils/currency_utils.dart';

class TransactionPaymentHistoryScreen extends StatefulWidget {
  const TransactionPaymentHistoryScreen({super.key});

  @override
  State<TransactionPaymentHistoryScreen> createState() => _TransactionPaymentHistoryScreenState();
}

class _TransactionPaymentHistoryScreenState extends State<TransactionPaymentHistoryScreen> {
  String selectedFilter = 'Date';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('transaction_payout_history'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'wallet_balance'.tr(),
                        CurrencyUtils.formatPrice(1250.00, userProvider.partnerCountry),
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'earned_income'.tr(),
                        CurrencyUtils.formatPrice(5750.00, userProvider.partnerCountry),
                        colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterRow(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'history'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildTransactionItem(
                          context,
                          'Payment Transaction',
                          'June 15, 2024',
                          '+${CurrencyUtils.formatPrice(50.00, userProvider.partnerCountry)}',
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payout Transaction',
                          'June 10, 2024',
                          '-${CurrencyUtils.formatPrice(500.00, userProvider.partnerCountry)}',
                          Colors.red,
                          Icons.arrow_upward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Subscription Payment',
                          'June 8, 2024',
                          '-${CurrencyUtils.formatPrice(29.99, userProvider.partnerCountry)}',
                          Colors.red,
                          Icons.credit_card,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payment Transaction',
                          'June 5, 2024',
                          '+${CurrencyUtils.formatPrice(75.00, userProvider.partnerCountry)}',
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payment Transaction',
                          'May 20, 2024',
                          '+${CurrencyUtils.formatPrice(100.00, userProvider.partnerCountry)}',
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showRequestPayoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payments),
                    const SizedBox(width: 8),
                    Text(
                      'request_payout'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.grid_view, 'Dashboard', false),
                _buildNavItem(Icons.group, 'Users', false),
                _buildNavItem(Icons.description, 'Plans', false),
                _buildNavItem(Icons.account_balance_wallet, 'Transactions', true),
                _buildNavItem(Icons.router, 'Routers', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Date', true),
          const SizedBox(width: 8),
          _buildFilterChip('Type', false),
          const SizedBox(width: 8),
          _buildFilterChip('Amount', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[400]!),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String date,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected ? colorScheme.primary : Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showRequestPayoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('request_payout'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'amount'.tr(),
                prefixText: CurrencyUtils.getCurrencySymbol(context.read<UserProvider>().partnerCountry),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'payout_method'.tr(),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'bank', child: Text('bank_transfer'.tr())),
                DropdownMenuItem(value: 'mobile', child: Text('mobile_money'.tr())),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('payout_request_submitted'.tr())),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('request'.tr()),
          ),
        ],
      ),
    );
  }
}
