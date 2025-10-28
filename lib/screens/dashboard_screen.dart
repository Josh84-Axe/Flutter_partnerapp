import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';
import 'subscription_management_screen.dart';

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

    final totalDataUsage = appState.routers.fold(
      0.0,
      (sum, r) => sum + r.dataUsageGB,
    );

    final dataUsagePercentage = totalDataUsage > 0
        ? (totalDataUsage / 20.0 * 100).clamp(0.0, 100.0).toDouble()
        : 60.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
              'Welcome back, ${appState.currentUser?.name ?? 'John Partner'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            _buildSubscriptionPlanCard(context, appState),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Revenue',
                    value: MetricCard.formatCurrency(totalRevenue),
                    icon: Icons.attach_money,
                    accentColor: AppTheme.deepGreen,
                    isLoading: appState.isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: 'Active Users',
                    value: MetricCard.formatNumber(activeUsers),
                    icon: Icons.people,
                    accentColor: AppTheme.lightGreen,
                    isLoading: appState.isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildQuickActions(context),
            const SizedBox(height: 24),

            _buildDataUsageCard(context, totalDataUsage, dataUsagePercentage),
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
                        ? AppTheme.deepGreen.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
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

  Widget _buildSubscriptionPlanCard(BuildContext context, AppState appState) {
    final subscription = appState.subscription;
    final tier = subscription?.tier ?? 'Standard';
    final renewalDate = subscription?.renewalDate ?? DateTime(2023, 12, 10);
    final formattedDate =
        '${renewalDate.month}/${renewalDate.day}/${renewalDate.year}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionManagementScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Plan',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tier,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Renews $formattedDate',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wifi, size: 32, color: AppTheme.deepGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(context, Icons.wifi, 'Internet\nPlans'),
        _buildQuickActionButton(context, Icons.people, 'Hotspot\nUsers'),
        _buildQuickActionButton(context, Icons.bar_chart, 'reporting'),
        _buildQuickActionButton(context, Icons.settings, 'Settings'),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDataUsageCard(
    BuildContext context,
    double totalDataUsage,
    double percentage,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.lightGreen.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${percentage.toInt()}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalDataUsage.toStringAsFixed(1)} GB of',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '20.0 GB used',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.deepGreen,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${percentage.toInt()}%',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Data Usage',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
