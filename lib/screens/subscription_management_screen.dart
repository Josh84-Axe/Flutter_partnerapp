import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

  String _getSubscriptionTier(int routerCount) {
    if (routerCount == 1) return 'basic_tier';
    if (routerCount >= 2 && routerCount <= 4) return 'standard_tier';
    if (routerCount >= 5) return 'premium_tier';
    return 'basic_tier';
  }

  double _getSubscriptionFee(int routerCount) {
    if (routerCount == 1) return 0.15;
    if (routerCount >= 2 && routerCount <= 4) return 0.12;
    if (routerCount >= 5) return 0.10;
    return 0.15;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final routerCount = appState.currentUser?.numberOfRouters ?? 1;
    final currentTier = _getSubscriptionTier(routerCount);
    final currentFee = _getSubscriptionFee(routerCount);

    return Scaffold(
      appBar: AppBar(
        title: Text('subscription_tiers'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'current_plan'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'active'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentTier.tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$routerCount ${routerCount == 1 ? 'router_singular'.tr() : 'router_plural'.tr()}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'transaction_fee_percent'.tr(namedArgs: {'percent': (currentFee * 100).toStringAsFixed(0)}),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('plan_change_coming_soon'.tr()),
                              ),
                            );
                          },
                          child: Text('change_plan'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'available_tiers'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            context,
            name: 'basic_tier',
            routers: 'tier_1_router',
            fee: '15%',
            isActive: currentTier == 'basic_tier',
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            context,
            name: 'standard_tier',
            routers: 'tier_2_4_routers',
            fee: '12%',
            isActive: currentTier == 'standard_tier',
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            context,
            name: 'premium_tier',
            routers: 'tier_5_plus_routers',
            fee: '10%',
            isActive: currentTier == 'premium_tier',
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String name,
    required String routers,
    required String fee,
    required bool isActive,
  }) {
    return Card(
      color: isActive ? AppTheme.primaryGreen.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'current'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routers.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'transaction_fee'.tr(namedArgs: {'fee': fee}),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isActive)
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('upgrade_to_tier'.tr(namedArgs: {'tier': name.tr()})),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                style: IconButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
