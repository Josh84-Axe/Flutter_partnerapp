import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/campus_provider.dart';
import '../providers/split/auth_provider.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/data_usage_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/pwa_service.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/foundation.dart';

class CampusDashboardScreen extends StatefulWidget {
  const CampusDashboardScreen({super.key});

  @override
  State<CampusDashboardScreen> createState() => _CampusDashboardScreenState();
}

class _CampusDashboardScreenState extends State<CampusDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampusProvider>().loadData();
      if (!context.read<AuthProvider>().isGuestMode) {
        context.read<UserProvider>().loadSubscription();
        context.read<NetworkProvider>().loadAllConfigurations();
      }
    });
  }

  void _showBuyPassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BuyPassDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<CampusProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final firstName = user?.firstName ?? provider.profile?.fullName.split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, firstName, provider, colorScheme),
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
                  if (provider.profile != null)
                    SubscriptionPlanCard(
                      planName: provider.profile!.currentPolicy.replaceAll('TIKNET_POLICY_', '').replaceAll('_', ' '),
                      renewalDate: userProvider.subscription?.renewalDate, // Map to actual pass expiry later if available
                      isLoading: provider.isLoading,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  if (provider.profile != null)
                    DataUsageCard(
                      usedGB: provider.profile!.dataConsumedMb / 1024,
                      totalGB: (provider.profile!.dataConsumedMb + provider.profile!.remainingDataMb) / 1024,
                      isLoading: provider.isLoading,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricWidget(
                          context,
                          title: 'Network Speed',
                          value: provider.profile?.isFastpathActive == true ? 'Fastpath' : 'Standard',
                          icon: Icons.bolt,
                          isLoading: provider.isLoading,
                          colorScheme: colorScheme,
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricWidget(
                          context,
                          title: 'Dorm Connection',
                          value: 'Stable',
                          icon: Icons.wifi,
                          isLoading: provider.isLoading,
                          colorScheme: colorScheme,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),
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
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBuyPassDialog(context),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Top Up Data'),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String firstName, CampusProvider provider, ColorScheme colorScheme) {
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
                    Colors.indigo,
                    Colors.purple,
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
                      'Welcome to Campus,',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
                    const SizedBox(height: 4),
                    Text(
                      firstName,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
                    if (provider.profile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${provider.profile!.department} | ID: ${provider.profile!.studentId}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.schedule, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/campus-schedules');
          },
          tooltip: 'Network Schedule',
        ),
      ],
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
                title: 'Buy\nPass', 
                icon: Icons.add_shopping_cart, 
                color: Colors.indigo,
                onTap: () => _showBuyPassDialog(context),
              ).animate().fadeIn(delay: 100.ms).scale(),
              _buildActionCard(
                context, 
                title: 'Library\nWi-Fi', 
                icon: Icons.local_library, 
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/campus-map');
                },
              ).animate().fadeIn(delay: 200.ms).scale(),
              _buildActionCard(
                context, 
                title: 'Schedules', 
                icon: Icons.access_time_filled, 
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/campus-schedules'),
              ).animate().fadeIn(delay: 300.ms).scale(),
              _buildActionCard(
                context, 
                title: 'IT Help', 
                icon: Icons.support_agent, 
                color: Colors.teal,
                onTap: () {
                  Navigator.pushNamed(context, '/campus-support');
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
                  colors: [Colors.indigo, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.3),
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
                      foregroundColor: Colors.indigo,
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
            Icon(icon, size: 28, color: Colors.indigo),
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
}

class BuyPassDialog extends StatefulWidget {
  const BuyPassDialog({super.key});

  @override
  State<BuyPassDialog> createState() => _BuyPassDialogState();
}

class _BuyPassDialogState extends State<BuyPassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'mobile_money';
  int _selectedPassId = 98; // Default mock pass ID
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final success = await context.read<CampusProvider>().buyPass(
        _selectedPassId,
        _paymentMethod,
        _phoneController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pass purchase successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<CampusProvider>().error ?? 'Purchase failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buy Extra Data Pass'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedPassId,
              decoration: const InputDecoration(labelText: 'Select Pass'),
              items: const [
                DropdownMenuItem(value: 98, child: Text('5GB Weekly Pass - \$5')),
                DropdownMenuItem(value: 99, child: Text('20GB Monthly Pass - \$15')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedPassId = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (for Mobile Money)',
                prefixText: '+233 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (_paymentMethod == 'mobile_money' && (value == null || value.isEmpty)) {
                  return 'Phone number required for Mobile Money';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Purchase'),
        ),
      ],
    );
  }
}
