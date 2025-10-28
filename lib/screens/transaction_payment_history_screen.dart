import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TransactionPaymentHistoryScreen extends StatefulWidget {
  const TransactionPaymentHistoryScreen({super.key});

  @override
  State<TransactionPaymentHistoryScreen> createState() => _TransactionPaymentHistoryScreenState();
}

class _TransactionPaymentHistoryScreenState extends State<TransactionPaymentHistoryScreen> {
  String selectedFilter = 'Date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction & Payout History'),
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
                        'Wallet Balance',
                        '\$1,250.00',
                        AppTheme.deepGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Earned Income',
                        '\$5,750.00',
                        AppTheme.lightGreen,
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
                    'History',
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
                          '+\$50.00',
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payout Transaction',
                          'June 10, 2024',
                          '-\$500.00',
                          Colors.red,
                          Icons.arrow_upward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Subscription Payment',
                          'June 8, 2024',
                          '-\$29.99',
                          Colors.red,
                          Icons.credit_card,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payment Transaction',
                          'June 5, 2024',
                          '+\$75.00',
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                        _buildTransactionItem(
                          context,
                          'Payment Transaction',
                          'May 20, 2024',
                          '+\$100.00',
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
                  backgroundColor: AppTheme.deepGreen,
                  foregroundColor: Colors.white,
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
                    const Text(
                      'Request Payout',
                      style: TextStyle(
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      selectedColor: AppTheme.deepGreen.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.deepGreen,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepGreen.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppTheme.deepGreen : Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.deepGreen : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showRequestPayoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Payout Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payout request submitted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
