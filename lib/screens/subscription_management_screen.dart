import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/currency_utils.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    await appState.loadSubscription();
    await appState.loadAvailableSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final subscription = appState.subscription;
    final availablePlans = appState.availableSubscriptionPlans;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('subscription_management'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (subscription != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'current_plan'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                subscription.tier,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: subscription.isActive 
                                      ? colorScheme.primaryContainer 
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  subscription.isActive ? 'active'.tr() : 'inactive'.tr(),
                                  style: TextStyle(
                                    color: subscription.isActive 
                                        ? colorScheme.primary 
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            context, 
                            'monthly_fee'.tr(), 
                            CurrencyUtils.formatPrice(subscription.monthlyFee, appState.partnerCountry)
                          ),
                          if (subscription.features.isNotEmpty) ...[
                            ...subscription.features.entries.map((entry) {
                              return _buildFeatureRow(
                                context,
                                entry.key.replaceAll('_', ' ').toUpperCase(),
                                entry.value.toString(),
                              );
                            }),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            '${'renewal_date'.tr()}: ${subscription.renewalDate.day}/${subscription.renewalDate.month}/${subscription.renewalDate.year}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'available_plans'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (availablePlans.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'no_subscription_plans_available'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ...availablePlans.map((plan) {
                    final isCurrentPlan = subscription?.id == plan.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildPlanCard(
                        context,
                        plan,
                        isCurrentPlan: isCurrentPlan,
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, plan, {bool isCurrentPlan = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.read<AppState>();
    
    return Card(
      elevation: isCurrentPlan ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentPlan ? BorderSide(color: colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'current'.tr(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (plan.isPopular && !isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'popular'.tr(),
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${CurrencyUtils.formatPrice(plan.price, appState.partnerCountry)}/${'month'.tr()}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (plan.features.isNotEmpty)
              ...plan.features.entries.map((entry) {
                return _buildPlanFeature(
                  context,
                  '${entry.key.replaceAll('_', ' ')}: ${entry.value}',
                );
              }),
            const SizedBox(height: 16),
            if (!isCurrentPlan)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchasePlan(plan.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('upgrade'.tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanFeature(BuildContext context, String feature) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePlan(String planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_purchase'.tr()),
        content: Text('confirm_purchase_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final appState = context.read<AppState>();
        final success = await appState.purchaseSubscriptionPlan(planId);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('subscription_purchased_successfully'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('subscription_purchase_failed'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_occurred'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
