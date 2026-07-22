import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/family_provider.dart';
import '../providers/split/auth_provider.dart';
import '../models/family_models.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/data_usage_card.dart';
import '../services/pwa_service.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/foundation.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadData();
      if (!context.read<AuthProvider>().isGuestMode) {
        context.read<UserProvider>().loadSubscription();
        context.read<NetworkProvider>().loadAllConfigurations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<FamilyProvider>();
    final userProvider = context.watch<UserProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final firstName = user?.firstName ?? 'Family';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, firstName, colorScheme),
              SliverToBoxAdapter(
                child: _buildQuickActions(context, colorScheme),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildPwaBanner(context, colorScheme),
                      const SizedBox(height: 16),
                      SubscriptionPlanCard(
                        planName: userProvider.subscription?.tier ?? 'Home Basic',
                        renewalDate: userProvider.subscription?.renewalDate,
                        isLoading: userProvider.isLoading || networkProvider.isLoading,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricWidget(
                              context,
                              title: 'Active Devices',
                              value: provider.devices.length.toString(),
                              icon: Icons.devices,
                              isLoading: provider.isLoading,
                              colorScheme: colorScheme,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricWidget(
                              context,
                              title: 'Network Status',
                              value: 'Online',
                              icon: Icons.cloud_done,
                              isLoading: false,
                              colorScheme: colorScheme,
                            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DataUsageCard(
                        usedGB: networkProvider.totalAccumulatedGB,
                        totalGB: 500.0, // Mock home broadband limit
                        isLoading: networkProvider.isLoading,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
              if (provider.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => provider.clearError(),
                            color: colorScheme.error,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                  ),
                ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Family Devices', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (provider.devices.isNotEmpty)
                    Text('${provider.devices.length} Connected', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                ],
              ).animate().fadeIn().slideX(begin: -0.1),
            ),
          ),
          if (provider.isLoading && provider.devices.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.devices.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, colorScheme),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final device = provider.devices[index];
                    return _buildDeviceCard(context, device, provider, colorScheme)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index))
                        .slideY(begin: 0.2, curve: Curves.easeOutQuad);
                  },
                  childCount: provider.devices.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
      ),
      ),
      floatingActionButton: provider.devices.isNotEmpty 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/family-add-device'),
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
          ).animate().scale(delay: 500.ms, curve: Curves.elasticOut)
        : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String firstName, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.tertiary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Good ${DateTime.now().hour < 12 ? "Morning" : DateTime.now().hour < 17 ? "Afternoon" : "Evening"},',
                      style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 16),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
                    const SizedBox(height: 4),
                    Text(
                      firstName,
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 32, fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.security, color: colorScheme.onPrimary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Network is Secure',
                            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
              .animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionCard(
                context, 
                title: 'Add\nDevice', 
                icon: Icons.add_to_home_screen, 
                color: colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, '/family-add-device'),
              ).animate().fadeIn(delay: 100.ms).scale(),
              _buildActionCard(
                context, 
                title: 'Schedules\n& Rules', 
                icon: Icons.access_time_filled, 
                color: colorScheme.tertiary,
                onTap: () => Navigator.pushNamed(context, '/family-schedules'),
              ).animate().fadeIn(delay: 200.ms).scale(),
              _buildActionCard(
                context, 
                title: 'Pause\nInternet', 
                icon: Icons.pause_circle_filled, 
                color: colorScheme.error,
                onTap: () async {
                  final provider = context.read<FamilyProvider>();
                  final currentlyPaused = provider.devices.isNotEmpty && provider.devices.every((d) => d.isPaused);
                  
                  final success = await provider.pauseAllInternet(!currentlyPaused);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success 
                        ? (currentlyPaused ? 'Internet restored for all devices' : 'All devices paused') 
                        : 'Failed to update devices')),
                    );
                  }
                },
              ).animate().fadeIn(delay: 300.ms).scale(),
              _buildActionCard(
                context, 
                title: 'Guest\nWi-Fi', 
                icon: Icons.wifi_lock, 
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/family-network-zones');
                },
              ).animate().fadeIn(delay: 400.ms).scale(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPwaBanner(BuildContext context, ColorScheme colorScheme) {
    if (!kIsWeb) return const SizedBox.shrink();

    return Builder(
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
            if (!isInstallable) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Theme.of(context).platform == TargetPlatform.iOS ? Icons.apple : Icons.install_mobile, 
                    color: Colors.white, 
                    size: 28
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Install App', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Add to home screen for quick access', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (showNativePrompt) {
                        pwa.promptInstall();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(showNativePrompt ? 'Install' : 'Details', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2);
          },
        );
      },
    );
  }

  Widget _buildMetricWidget(BuildContext context, {required String title, required String value, required IconData icon, required bool isLoading, required ColorScheme colorScheme}) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: colorScheme.primary),
            const SizedBox(height: 12),
            if (isLoading)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(width: 60),
                  SizedBox(height: 8),
                  SkeletonText(width: 80, height: 24),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.router_outlined, size: 60, color: colorScheme.primary)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
            ),
            const SizedBox(height: 24),
            Text(
              'No Devices Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text(
              'Your family network is ready. Add your kids\' devices to start managing screen time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/family-add-device'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Device'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ).animate().fadeIn(delay: 500.ms).scale(curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, FamilyDevice device, FamilyProvider provider, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isPaused ? colorScheme.errorContainer : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.smartphone,
                    color: device.isPaused ? colorScheme.error : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        device.macAddress,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: device.isPaused ? colorScheme.errorContainer : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: device.isPaused ? colorScheme.error.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        device.isPaused ? Icons.pause_circle : Icons.check_circle,
                        size: 14,
                        color: device.isPaused ? colorScheme.error : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device.isPaused ? 'Paused' : 'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: device.isPaused ? colorScheme.error : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (device.isPaused && device.pauseUntil != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: colorScheme.error),
                        const SizedBox(width: 4),
                        Text(
                          'Paused until ${DateFormat('MMM d, h:mm a').format(device.pauseUntil!.toLocal())}',
                          style: TextStyle(fontSize: 12, color: colorScheme.error, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'Internet Access',
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                Switch(
                  value: !device.isPaused, // True means internet is ON (not paused)
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green.withValues(alpha: 0.2),
                  inactiveThumbColor: colorScheme.error,
                  inactiveTrackColor: colorScheme.errorContainer,
                  onChanged: (val) {
                    if (!val) { // They switched it off (Pause)
                      _showPauseOptions(context, device, provider);
                    } else { // They switched it on (Unpause)
                      provider.toggleDevicePause(device.id, false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseOptions(BuildContext context, FamilyDevice device, FamilyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'Pause ${device.deviceName}', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: 8),
                _buildPauseOption(context, Icons.timer_10, 'For 10 minutes', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 10);
                }),
                _buildPauseOption(context, Icons.hourglass_bottom, 'For 1 hour', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 60);
                }),
                _buildPauseOption(context, Icons.nightlight_round, 'Until tomorrow', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 12 * 60);
                }),
                _buildPauseOption(context, Icons.pause_circle_filled, 'Indefinitely', () {
                  provider.toggleDevicePause(device.id, true);
                }, isDestructive: true),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseOption(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
