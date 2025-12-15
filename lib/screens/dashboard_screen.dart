import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/guest_mode_banner.dart';
import '../widgets/guest_mode_banner.dart';
import '../widgets/data_usage_card.dart';
import '../services/update_service.dart';

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
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateService();
    final updateInfo = await updateService.checkUpdate();

    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    final bool forceUpdate = updateInfo['forceUpdate'] == true;
    final String downloadUrl = updateInfo['downloadUrl'];
    
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text('New Update Available'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A new version (${updateInfo['latestVersion']}) is available.'),
                const SizedBox(height: 8),
                Text('Release Notes:'),
                Text(updateInfo['releaseNotes'] ?? '', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Later'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _performUpdate(downloadUrl);
                },
                child: Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _performUpdate(String url) async {
    if (!mounted) return;
    
    // Show a snackbar to indicate start
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting download... Check your notification panel.'))
    );
    
    try {
      final updateService = UpdateService();
      await updateService.performUpdate(url);
    } catch (error) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: $error'))
         );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    final totalRevenue = appState.totalRevenue;
    
    final activeUsers = appState.users.where((u) => u.isActive).length;

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
                  Navigator.of(context).pushNamed('/notification-center');
                },
              ),
              if (appState.localUnreadCount > 0)
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
                      '${appState.localUnreadCount}',
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
            const SizedBox(height: 16),
            
            // Guest mode banner
            if (appState.isGuestMode)
              GuestModeBanner(
                onRegister: () {
                  Navigator.of(context).pushReplacementNamed('/register');
                },
              ),
            
            const SizedBox(height: 8),
            
            // Subscription Plan Card - load from API
            SubscriptionPlanCard(
              planName: appState.subscription?.tier ?? 'Free Plan',
              renewalDate: appState.subscription?.renewalDate ?? DateTime.now().add(const Duration(days: 30)),
              isLoading: appState.isLoading,
            ),
            const SizedBox(height: 16),
            
            // Task 1: Total Revenue and Active Users moved below Subscription Plan
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showRevenueDetails(context, appState),
                    child: _buildMetricWidget(
                      context,
                      title: 'total_revenue'.tr(),
                      value: appState.formatMoney(totalRevenue),
                      icon: Icons.paid,
                      isLoading: appState.isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showActiveUsersDetails(context, appState),
                    child: _buildMetricWidget(
                      context,
                      title: 'active_users'.tr(),
                      value: MetricCard.formatNumber(activeUsers),
                      icon: Icons.group,
                      isLoading: appState.isLoading,
                    ),
                  ),
                ),
              ],
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
                  icon: Icons.devices,
                  label: 'active_sessions'.tr(),
                  onTap: () => Navigator.of(context).pushNamed('/active-sessions'),
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
            const SizedBox(height: 16),
            
            // Task 2: Data Usage Card moved below Quick Action Buttons - load from API
            // Data Usage Card - Aggregated for all active users
            DataUsageCard(
              usedGB: appState.aggregateDataUsage,
              totalGB: 100.0, // Arbitrary total for now as we aggregate multiple plans
              isLoading: appState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _showRevenueDetails(BuildContext context, AppState appState) {
    // Navigate to transaction history screen with API data and enhanced UX
    Navigator.of(context).pushNamed('/transaction-history');
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
                          SnackBar(content: Text('unassign_user_plan_message'.tr(namedArgs: {'name': user.name}))),
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

  Widget _buildMetricWidget(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required bool isLoading,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: colorScheme.primary,
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
