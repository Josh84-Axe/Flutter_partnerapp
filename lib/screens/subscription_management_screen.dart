import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

  String _getSubscriptionTier(int routerCount) {
    if (routerCount == 1) return 'Basic';
    if (routerCount >= 2 && routerCount <= 4) return 'Standard';
    if (routerCount >= 5) return 'Premium';
    return 'Basic';
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
        title: const Text('Subscription Tiers'),
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
                    color: AppTheme.primaryGreen.withOpacity(0.1),
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
                    color: AppTheme.lightGreen.withOpacity(0.1),
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
                          const Text(
                            'Current Plan',
                            style: TextStyle(
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
                            child: const Text(
                              'Active',
                              style: TextStyle(
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
                        currentTier,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$routerCount ${routerCount == 1 ? 'router' : 'routers'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(currentFee * 100).toStringAsFixed(0)}% transaction fee',
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
                              const SnackBar(
                                content: Text('Plan change feature coming soon'),
                              ),
                            );
                          },
                          child: const Text('Change Plan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Tiers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTierCard(
            context,
            name: 'Basic',
            routers: '1 router',
            fee: '15%',
            isActive: currentTier == 'Basic',
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            context,
            name: 'Standard',
            routers: '2-4 routers',
            fee: '12%',
            isActive: currentTier == 'Standard',
          ),
          const SizedBox(height: 12),
          _buildTierCard(
            context,
            name: 'Premium',
            routers: '5+ routers',
            fee: '10%',
            isActive: currentTier == 'Premium',
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
      color: isActive ? AppTheme.primaryGreen.withOpacity(0.1) : null,
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
                        name,
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
                          child: const Text(
                            'Current',
                            style: TextStyle(
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
                    routers,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$fee transaction fee',
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
                      content: Text('Upgrade to $name tier'),
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
