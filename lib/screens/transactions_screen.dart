import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/currency_utils.dart';
import '../widgets/metric_card.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/status_badge_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedType = 'All';
  String _selectedDateRange = 'All Time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadTransactions();
      context.read<AppState>().loadWalletBalance();
    });
  }

  void _showPayoutDialog() {
    final amountController = TextEditingController();
    String selectedMethod = 'bank_transfer';
    final appState = context.read<AppState>();
    final partnerCountry = appState.currentUser?.country;
    final currencySymbol = appState.currencySymbol;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('request_payout'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'amount'.tr(),
                  prefixText: '$currencySymbol ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: InputDecoration(labelText: 'payment_method'.tr()),
                items: [
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: Text('bank_transfer'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'paypal',
                    child: Text('paypal'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'crypto',
                    child: Text('cryptocurrency'.tr()),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  context.read<AppState>().requestPayout(amount, selectedMethod);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('payout_request_submitted'.tr())),
                  );
                }
              },
              child: Text('request'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final partnerCountry = appState.currentUser?.country;
    
    final totalRevenue = appState.transactions
        .where((t) => t.type == 'revenue')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final filteredTransactions = appState.transactions.where((transaction) {
      if (_selectedType != 'All' && transaction.type != _selectedType.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('transactions'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              appState.loadTransactions();
              appState.loadWalletBalance();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wallet_balance'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MetricCard.formatCurrency(appState.walletBalance, partnerCountry),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
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
                        Text(
                          'earned_income'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MetricCard.formatCurrency(totalRevenue, partnerCountry),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget(
                    label: _selectedDateRange,
                    isSelected: true,
                    onTap: () {
                      _showDateRangeSelector();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: _selectedType,
                    isSelected: true,
                    onTap: () {
                      _showTypeSelector();
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _showPayoutDialog,
                    icon: const Icon(Icons.payments, size: 18),
                    label: Text('withdraw'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: appState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'no_transactions_found'.tr(),
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          final isRevenue = transaction.type == 'revenue';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isRevenue
                                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                                    : AppTheme.errorRed.withValues(alpha: 0.1),
                                child: Icon(
                                  isRevenue ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isRevenue ? AppTheme.successGreen : AppTheme.errorRed,
                                  size: 20,
                                ),
                              ),
                              title: Text(transaction.description),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} ${transaction.createdAt.hour}:${transaction.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                                  ),
                                  const SizedBox(height: 4),
                                  StatusBadgeWidget(
                                    label: transaction.status.toUpperCase(),
                                    type: transaction.status == 'completed'
                                        ? BadgeType.success
                                        : BadgeType.pending,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${isRevenue ? '+' : '-'}${appState.formatMoney(transaction.amount.abs())}',
                                style: TextStyle(
                                  color: isRevenue ? AppTheme.successGreen : AppTheme.errorRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showDateRangeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('all_time'.tr()),
              trailing: _selectedDateRange == 'All Time'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedDateRange = 'All Time';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('last_7_days'.tr()),
              trailing: _selectedDateRange == 'Last 7 Days'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedDateRange = 'Last 7 Days';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('last_30_days'.tr()),
              trailing: _selectedDateRange == 'Last 30 Days'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedDateRange = 'Last 30 Days';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('this_month'.tr()),
              trailing: _selectedDateRange == 'This Month'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedDateRange = 'This Month';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('all_transactions'.tr()),
              trailing: _selectedType == 'All'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedType = 'All';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('revenue'.tr()),
              trailing: _selectedType == 'Revenue'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedType = 'Revenue';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('payout'.tr()),
              trailing: _selectedType == 'Payout'
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedType = 'Payout';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
