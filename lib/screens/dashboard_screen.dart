import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


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
import '../services/pwa_service.dart';
import 'package:flutter/foundation.dart';

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
    // Force update logic remains the same for initial check
    final bool isForceUpdate = updateInfo['forceUpdate'] == true;
    final String downloadUrl = updateInfo['downloadUrl'];
    
    // Dialog state
    double downloadProgress = 0.0;
    bool isDownloading = false;
    String? errorMessage;
    
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate, // Temporarily false, will be controlled by logic below
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            
            // Function to handle the actual update logic inside the dialog
            Future<void> startUpdate() async {
              setState(() {
                isDownloading = true;
                errorMessage = null;
              });

              try {
                final updateService = UpdateService();
                await updateService.performUpdate(
                  downloadUrl,
                  onProgress: (received, total) {
                    if (total != -1) {
                      setState(() {
                        downloadProgress = received / total;
                      });
                    }
                  },
                );
                // Install triggered automatically by performUpdate
                // We typically don't close the dialog here as the OS installer takes over, 
                // but we can if we want to reset state. 
                // For now, let's keep it open or close it knowing the app might pause.
                 if (mounted) Navigator.pop(dialogContext);

              } catch (e) {
                if (mounted) {
                   setState(() {
                     isDownloading = false;
                     errorMessage = 'update_failed'.tr(namedArgs: {'error': e.toString()});
                     downloadProgress = 0.0;
                   });
                }
              }
            }

            return PopScope(
              // Prevent closing update is forced OR if downloading is in progress
              canPop: !isForceUpdate && !isDownloading,
              onPopInvokedWithResult: (didPop, result) {
                 if (!didPop && isDownloading) {
                   // Optional: Show toast "Please wait for update to finish"
                 }
              },
              child: AlertDialog(
                title: Text(isDownloading ? 'downloading_update'.tr() : 'new_update_available'.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDownloading) ...[
                      Text('new_version_available'.tr(namedArgs: {'version': updateInfo['latestVersion'] ?? ''})),
                      const SizedBox(height: 8),
                      Text('release_notes'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: SingleChildScrollView(
                          child: Text(updateInfo['releaseNotes'] ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
                        ),
                      ),
                    ],
                    
                    if (isDownloading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: downloadProgress),
                      const SizedBox(height: 8),
                      Text('${(downloadProgress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text('do_not_close_app'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],

                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
                actions: [
                  if (!isDownloading && !isForceUpdate)
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text('later'.tr()),
                    ),
                  
                  if (!isDownloading)
                    ElevatedButton(
                      onPressed: startUpdate,
                      child: Text('update_now'.tr()),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // _performUpdate is now integrated into the dialog logic above to share state.
  // Method removed to avoid duplication.

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
              'welcome_back'.tr(namedArgs: {'name': userProvider.currentUser?.name ?? 'valued_partner'.tr()}),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // PWA Install Banner (Web Only)
            // PWA Install Banner (Web Only)
            if (kIsWeb)
              Builder(
                builder: (context) {
                  final pwa = PwaService();
                  if (pwa.isStandalone) {
                    return const SizedBox.shrink();
                  }

                  return StreamBuilder<bool>(
                    stream: pwa.installableStream,
                    initialData: pwa.isInstallable,
                    builder: (context, snapshot) {
                      final bool isInstallable = snapshot.data ?? pwa.isInstallable;
                      final bool showNativePrompt = isInstallable && pwa.isInstallPromptSupported;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Theme.of(context).platform == TargetPlatform.iOS 
                                  ? Icons.apple 
                                  : Icons.install_mobile, 
                                color: Colors.white, 
                                size: 32
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'pwa_generic_title'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'pwa_generic_subtitle'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (showNativePrompt) {
                                    pwa.promptInstall();
                                  } else {
                                    _showManualInstallInstructions(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(showNativePrompt ? 'install'.tr() : 'view_details'.tr()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            
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
              planName: userProvider.subscription?.tier ?? 'free_plan'.tr(),
              renewalDate: userProvider.subscription?.renewalDate,
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
                  icon: Icons.assignment_outlined,
                  label: 'reporting'.tr(),
                  onTap: () => Navigator.pushNamed(context, '/reporting'),
                ),
                QuickActionButton(
                  icon: Icons.history,
                  label: 'billing_history'.tr(),
                  onTap: () => Navigator.pushNamed(context, '/transaction-history'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data Usage Card (Centered with max width)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: DataUsageCard(
                  usedGB: networkProvider.totalAccumulatedGB,
                  totalGB: 200.0,
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

  Future<void> _refreshAll(BuildContext context) async {
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
            content: Text('error_loading_data'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'retry'.tr(),
              textColor: Colors.white,
              onPressed: () => _refreshAll(context),
            ),
          ),
        );
      }
    }
  }

  void _showManualInstallInstructions(BuildContext context) {
    final pwa = PwaService();
    final bool isIOS = pwa.isIOS;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isIOS ? Icons.apple : Icons.install_mobile,
                      size: 32,
                      color: isIOS ? Colors.blue : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      (isIOS ? 'ios_install_title' : 'pwa_generic_title').tr(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              (isIOS ? 'ios_install_subtitle' : 'pwa_generic_subtitle').tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            if (isIOS) ...[
              _buildInstallStep(
                context,
                number: '1',
                text: 'pwa_ios_step_1'.tr(),
                icon: Icons.ios_share,
              ),
              const SizedBox(height: 20),
              _buildInstallStep(
                context,
                number: '2',
                text: 'pwa_ios_step_2'.tr(),
                icon: Icons.add_box_outlined,
              ),
              const SizedBox(height: 20),
              _buildInstallStep(
                context,
                number: '3',
                text: 'pwa_ios_step_3'.tr(),
                icon: Icons.add,
              ),
            ] else ...[
              _buildInstallStep(
                context,
                number: '1',
                text: 'pwa_android_step_1'.tr(),
                icon: Icons.more_vert,
              ),
              const SizedBox(height: 20),
              _buildInstallStep(
                context,
                number: '2',
                text: 'pwa_android_step_2'.tr(),
                icon: Icons.install_mobile,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('ok'.tr()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallStep(
    BuildContext context, {
    required String number,
    required String text,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  if (onTap != null)
                    Text(
                      'tap_to_open'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
