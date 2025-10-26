import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/data_usage_card.dart';
import '../widgets/quick_action_button.dart';

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
        title: Text('dashboard_title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed('/notification-router');
                },
              ),
              if (appState.unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${appState.unreadNotificationCount}',
                      style: const TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
            // "Stay Connected" heading
            Text(
              'stay_connected'.tr(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'welcome_back'.tr(namedArgs: {'name': appState.currentUser?.name ?? 'Joe'}),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            
            // Subscription Plan Card
            SubscriptionPlanCard(
              planName: 'Standard',
              renewalDate: DateTime(2023, 12, 10),
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 16),
            
            // Data Usage Card
            DataUsageCard(
              usedGB: 12.0,
              totalGB: 20.0,
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 24),
            
            // Quick Action Buttons Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                QuickActionButton(
                  icon: Icons.wifi,
                  label: 'internet_plans'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/internet-plan'),
                ),
                QuickActionButton(
                  icon: Icons.people,
                  label: 'hotspot_users'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/hotspot-user'),
                ),
                QuickActionButton(
                  icon: Icons.bar_chart,
                  label: 'reporting'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/reporting'),
                ),
                QuickActionButton(
                  icon: Icons.settings,
                  label: 'settings'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showRevenueDetails(context, appState),
              child: MetricCard(
                title: 'total_revenue'.tr(),
                value: MetricCard.formatCurrency(totalRevenue),
                icon: Icons.paid,
                accentColor: AppTheme.successGreen,
                isLoading: appState.isLoading,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showActiveUsersDetails(context, appState),
              child: MetricCard(
                title: 'active_users'.tr(),
                value: MetricCard.formatNumber(activeUsers),
                icon: Icons.group,
                accentColor: Colors.blue,
                isLoading: appState.isLoading,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showDataUsageDetails(context, appState),
              child: MetricCard(
                title: 'data_usage'.tr(),
                value: '${totalDataUsage.toStringAsFixed(1)} GB',
                icon: Icons.wifi,
                accentColor: AppTheme.errorRed,
                isLoading: appState.isLoading,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'recent_activity'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...appState.transactions.take(5).map((transaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'revenue'
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    child: Icon(
                      transaction.type == 'revenue'
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: transaction.type == 'revenue'
                          ? AppTheme.primaryGreen
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
                          ? AppTheme.primaryGreen
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRevenueDetails(BuildContext context, AppState appState) {
    final currentMonth = DateTime.now().month;
    final revenueTransactions = appState.transactions
        .where((t) => t.type == 'revenue' && t.createdAt.month == currentMonth)
        .toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('revenue_details'.tr(), style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: revenueTransactions.length,
                itemBuilder: (context, index) {
                  final txn = revenueTransactions[index];
                  return ListTile(
                    leading: const Icon(Icons.payment, color: AppTheme.successGreen),
                    title: Text(txn.description),
                    subtitle: Text('${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}'),
                    trailing: Text(
                      MetricCard.formatCurrency(txn.amount),
                      style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveUsersDetails(BuildContext context, AppState appState) {
    final activeUsers = appState.users.where((u) => u.isActive).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('active_users_details'.tr(), style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: activeUsers.length,
                itemBuilder: (context, index) {
                  final user = activeUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unassign ${user.name}\'s plan')),
                        );
                      },
                      child: Text('unassign'.tr()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataUsageDetails(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('data_usage_by_router'.tr(), style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: appState.routers.length,
                itemBuilder: (context, index) {
                  final router = appState.routers[index];
                  return ListTile(
                    leading: const Icon(Icons.router, color: AppTheme.errorRed),
                    title: Text(router.name),
                    subtitle: Text('users_connected'.tr(namedArgs: {'count': router.connectedUsers.toString()})),
                    trailing: Text(
                      '${router.dataUsageGB.toStringAsFixed(1)} GB',
                      style: const TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
