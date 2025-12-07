import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';

class WalletOverviewScreen extends StatefulWidget {
  const WalletOverviewScreen({super.key});

  @override
  State<WalletOverviewScreen> createState() => _WalletOverviewScreenState();
}

class _WalletOverviewScreenState extends State<WalletOverviewScreen> {
  String _selectedTab = 'Revenue';
  String _selectedPeriod = '30D';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadAllWalletBalances();
      appState.loadAllTransactions();
      appState.loadWithdrawals();
      appState.loadTransactions(); // Load TransactionModel list
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // ... (rest of build method) ...
    
    // ... inside Column ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_transactions'.tr(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transaction-history');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...appState.transactions.take(5).map((transaction) {
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
                subtitle: Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                  style: const TextStyle(fontSize: 12),
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
          }),
          const SizedBox(height: 32),
          Text(
            'Financial Summary',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTabChip('Revenue', _selectedTab == 'Revenue', () {
                setState(() => _selectedTab = 'Revenue');
              }),
              const SizedBox(width: 8),
              _buildTabChip('Payouts', _selectedTab == 'Payouts', () {
                setState(() => _selectedTab = 'Payouts');
              }),
              const SizedBox(width: 8),
              _buildTabChip('Balance', _selectedTab == 'Balance', () {
                setState(() => _selectedTab = 'Balance');
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPeriodChip('7D', _selectedPeriod == '7D', () {
                setState(() => _selectedPeriod = '7D');
              }),
              const SizedBox(width: 8),
              _buildPeriodChip('30D', _selectedPeriod == '30D', () {
                setState(() => _selectedPeriod = '30D');
              }),
              const SizedBox(width: 8),
              _buildPeriodChip('90D', _selectedPeriod == '90D', () {
                setState(() => _selectedPeriod = '90D');
              }),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFinancialSummaryContent(appState, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryContent(AppState appState, ColorScheme colorScheme) {
    switch (_selectedTab) {
      case 'Revenue':
        return Column(
          children: [
            _buildSummaryRow(
              'Total Revenue',
              appState.formatMoney(appState.totalRevenue),
              AppTheme.successGreen,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Online Revenue',
              appState.formatMoney(appState.onlineRevenue),
              colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Assigned Revenue',
              appState.formatMoney(appState.assignedRevenue),
              Colors.blue,
            ),
          ],
        );
      case 'Payouts':
        final payoutTransactions = appState.transactions
            .where((t) => t.type == 'payout' || t.type == 'withdrawal')
            .toList();
        final totalPayouts = payoutTransactions.fold(0.0, (sum, t) => sum + t.amount.abs());
        final pendingPayouts = payoutTransactions
            .where((t) => t.status == 'pending')
            .fold(0.0, (sum, t) => sum + t.amount.abs());
        final completedPayouts = payoutTransactions
            .where((t) => t.status == 'completed' || t.status == 'success')
            .fold(0.0, (sum, t) => sum + t.amount.abs());

        return Column(
          children: [
            _buildSummaryRow(
              'Total Payouts',
              appState.formatMoney(totalPayouts),
              AppTheme.errorRed,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Pending Payouts',
              appState.formatMoney(pendingPayouts),
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Completed Payouts',
              appState.formatMoney(completedPayouts),
              Colors.green,
            ),
          ],
        );
      case 'Balance':
      default:
        return Column(
          children: [
            _buildSummaryRow(
              'Total Balance',
              appState.formatMoney(appState.totalBalance),
              colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Wallet Balance',
              appState.formatMoney(appState.walletBalance),
              Colors.purple,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Assigned Balance',
              appState.formatMoney(appState.assignedWalletBalance),
              Colors.blue,
            ),
          ],
        );
    }
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.primary : AppTheme.textLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
