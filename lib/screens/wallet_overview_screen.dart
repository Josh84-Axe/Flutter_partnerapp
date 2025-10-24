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
      context.read<AppState>().loadWalletBalance();
      context.read<AppState>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    final revenueTransactions = appState.transactions
        .where((t) => t.type == 'revenue')
        .toList();
    
    final payoutTransactions = appState.transactions
        .where((t) => t.type == 'payout')
        .toList();
    
    final totalRevenue = revenueTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalPayouts = payoutTransactions.fold(0.0, (sum, t) => sum + t.amount.abs());

    return Scaffold(
      appBar: AppBar(
        title: Text('wallet_payout'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              appState.loadWalletBalance();
              appState.loadTransactions();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_balance'.tr(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  MetricCard.formatCurrency(appState.walletBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.payments_outlined,
                  label: 'request_payout'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/payout-request'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.history,
                  label: 'full_history'.tr(),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.trending_up,
                  label: 'Revenue',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_transactions'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {},
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
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.errorRed.withOpacity(0.1),
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
                  '${isRevenue ? '+' : '-'}${MetricCard.formatCurrency(transaction.amount.abs())}',
                  style: TextStyle(
                    color: isRevenue ? AppTheme.successGreen : AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
          Text(
            'Financial Summary',
            style: Theme.of(context).textTheme.titleLarge,
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
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Total Revenue',
                    MetricCard.formatCurrency(totalRevenue),
                    AppTheme.successGreen,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total Payouts',
                    MetricCard.formatCurrency(totalPayouts),
                    AppTheme.errorRed,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Current Balance',
                    MetricCard.formatCurrency(appState.walletBalance),
                    AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
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
