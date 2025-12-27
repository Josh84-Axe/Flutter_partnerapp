import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';


import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../providers/split/billing_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/quick_action_button.dart';
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
      _refreshAll(context);
    });
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateService();
    final updateInfo = await updateService.checkUpdate();

    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

// ... unchanged code ...



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
    final userProvider = context.watch<UserProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final billingProvider = context.watch<BillingProvider>();
    
    final totalRevenue = billingProvider.totalRevenue;
    
    final activeUsers = userProvider.users.where((u) => u.isActive).length;

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
              if (userProvider.localUnreadCount > 0)
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
                      '${userProvider.localUnreadCount}',
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
            onPressed: () => _refreshAll(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(context),
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
              'welcome_back'.tr(namedArgs: {'name': userProvider.currentUser?.name ?? 'Joe'}),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Guest mode banner
            if (userProvider.isGuestMode)
              GuestModeBanner(
                onRegister: () {
                  Navigator.of(context).pushReplacementNamed('/register');
                },
              ),
            
            const SizedBox(height: 8),
            
            // Subscription Plan Card - load from API
            SubscriptionPlanCard(
              planName: userProvider.subscription?.tier ?? 'Free Plan',
              renewalDate: userProvider.subscription?.renewalDate ?? DateTime.now().add(const Duration(days: 30)),
              isLoading: userProvider.isLoading || networkProvider.isLoading || billingProvider.isLoading,
            ),
            const SizedBox(height: 16),
            
            // Row 1: Revenue and Active Users
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showRevenueDetails(context),
                    child: _buildMetricWidget(
                      context,
                      title: 'total_revenue'.tr(),
                      value: billingProvider.formatMoney(totalRevenue),
                      icon: Icons.paid,
                      isLoading: billingProvider.isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showActiveUsersDetails(context, userProvider),
                    child: _buildMetricWidget(
                      context,
                      title: 'active_users'.tr(),
                      value: MetricCard.formatNumber(activeUsers),
                      icon: Icons.group,
                      isLoading: userProvider.isLoading,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
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
            const SizedBox(height: 24),

            // Data Usage Card (Centered with max width)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: DataUsageCard(
                  usedGB: networkProvider.aggregateActiveDataUsage,
                  totalGB: networkProvider.aggregateTotalDataLimit,
                  isLoading: networkProvider.isLoading,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRevenueDetails(BuildContext context) {
    // Navigate to transaction history screen with API data and enhanced UX
    Navigator.of(context).pushNamed('/transaction-history');
  }

  void _showActiveUsersDetails(BuildContext context, UserProvider userProvider) {
    final activeUsers = userProvider.users.where((u) => u.isActive).toList();
    
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

    final networkProvider = context.read<NetworkProvider>();
    final userProvider = context.read<UserProvider>();
    final billingProvider = context.read<BillingProvider>();

    try {
      await Future.wait([
        // Network
        networkProvider.loadAllConfigurations(),
        networkProvider.loadHotspotProfiles(),
        networkProvider.loadActiveSessions(),
        networkProvider.loadPlans(),

        // User
        userProvider.loadUsers(),
        userProvider.loadWorkers(),
        userProvider.loadRoles(),
        userProvider.loadSubscription(),

        // Billing
        billingProvider.loadAllWalletBalances(),
        billingProvider.loadTransactions(),
        billingProvider.loadPaymentMethods(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _refreshAll(context),
            ),
          ),
        );
      }
    }
  }
}
