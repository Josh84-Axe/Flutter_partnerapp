import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    final totalRevenue = appState.transactions
        .where((t) => t.type == 'revenue')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final activeUsers = appState.users.where((u) => u.isActive).length;
    
    final totalDataUsage = appState.routers
        .fold(0.0, (sum, r) => sum + r.dataUsageGB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadDashboardData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadDashboardData(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Welcome, ${appState.currentUser?.name ?? 'Partner'}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of your hotspot business',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            MetricCard(
              title: 'Total Revenue',
              value: MetricCard.formatCurrency(totalRevenue),
              icon: Icons.attach_money,
              accentColor: AppTheme.deepGreen,
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Active Users',
              value: MetricCard.formatNumber(activeUsers),
              icon: Icons.people,
              accentColor: AppTheme.lightGreen,
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Data Usage',
              value: '${totalDataUsage.toStringAsFixed(1)} GB',
              icon: Icons.data_usage,
              accentColor: AppTheme.softGold,
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...appState.transactions.take(5).map((transaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'revenue'
                        ? AppTheme.deepGreen.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    child: Icon(
                      transaction.type == 'revenue'
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: transaction.type == 'revenue'
                          ? AppTheme.deepGreen
                          : Colors.orange,
                    ),
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(
                    '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                  ),
                  trailing: Text(
                    MetricCard.formatCurrency(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == 'revenue'
                          ? AppTheme.deepGreen
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
