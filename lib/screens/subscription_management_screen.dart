import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/split/user_provider.dart';
import '../providers/split/billing_provider.dart';
import '../utils/currency_utils.dart';
import '../models/subscription_model.dart';
import 'payment_gateway_screen.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  bool _isLoading = false;
  String _selectedDuration = 'monthly';

  final List<Map<String, String>> _durations = [
    {'id': 'monthly', 'label': 'monthly'},
    {'id': 'quarterly', 'label': 'quarterly'},
    {'id': 'yearly', 'label': 'yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userProvider = context.read<UserProvider>();
      await Future.wait([
        userProvider.loadSubscription(),
        userProvider.loadAvailableSubscriptionPlans(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final billingProvider = context.watch<BillingProvider>();
    final subscription = userProvider.subscription;
    final availablePlans = userProvider.availableSubscriptionPlans;
    final filteredPlans = availablePlans.where((p) => p.duration == _selectedDuration).toList();
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
      body: _isLoading || userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Current Subscription Section
                  if (subscription != null) ...[
                    Text(
                      'current_plan'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
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
                                    subscription.tier,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: subscription.isActive 
                                        ? Colors.green.shade100 
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    subscription.isActive ? 'active'.tr() : 'inactive'.tr(),
                                    style: TextStyle(
                                      color: subscription.isActive 
                                          ? Colors.green.shade900 
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              Icons.payments_outlined,
                              'monthly_fee'.tr(),
                              CurrencyUtils.formatPrice(subscription.monthlyFee, userProvider.partnerCountry, currencyCode: null), // Subscription model doesn't store currency yet, fallback to country
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.calendar_today_outlined,
                              'renewal_date'.tr(),
                              DateFormat('MMM d, yyyy').format(subscription.renewalDate),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Available Plans Section
                  Text(
                    'available_plans'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration Toggle
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _durations.map((d) {
                          final isSelected = _selectedDuration == d['id'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDuration = d['id']!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ] : null,
                              ),
                              child: Text(
                                d['label']!.tr(),
                                style: TextStyle(
                                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (filteredPlans.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'no_subscription_plans_available'.tr(),
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredPlans.map((plan) {
                      final isCurrentPlan = subscription?.id == plan.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: isCurrentPlan ? 4 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isCurrentPlan 
                                ? BorderSide(color: colorScheme.primary, width: 2) 
                                : BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: isCurrentPlan ? LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer.withOpacity(0.3),
                                  colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ) : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plan.name,
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isCurrentPlan ? colorScheme.primary : null,
                                              ),
                                            ),
                                            if (plan.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                plan.description,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isCurrentPlan)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'current'.tr(),
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        plan.priceDisplay ?? CurrencyUtils.formatPrice(plan.price, userProvider.partnerCountry, currencyCode: plan.currency),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '/ ${plan.duration.tr()}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (plan.features.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    ...plan.features.take(4).map((feature) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, 
                                              color: colorScheme.primary.withOpacity(0.7), 
                                              size: 18
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                feature,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  const SizedBox(height: 24),
                                  if (!isCurrentPlan)
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () => _purchasePlan(plan.id, plan.name, plan.price, plan.currency),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Text(
                                          subscription != null ? 'upgrade_to_plan'.tr() : 'subscribe'.tr(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: null,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          'your_current_plan'.tr(),
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _purchasePlan(String planId, String planName, double amount, String? currencyCode) async {
    final userProvider = context.read<UserProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_purchase'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('confirm_purchase_message'.tr()),
            const SizedBox(height: 16),
            Text(
              planName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatPrice(amount, userProvider.partnerCountry, currencyCode: currencyCode),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('proceed_to_payment'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = false);
    
    try {
      // Get payment details for Paystack popup
      final paymentDetails = userProvider.getPaymentDetails(
        planId: planId,
        planName: planName,
        amount: amount,
      );
      
      // Override currency if provided by plan
      if (currencyCode != null) {
        paymentDetails['currency'] = currencyCode;
      }
      
      
      // Open Paystack inline popup
      final paymentResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentGatewayScreen(
            email: paymentDetails['email'],
            amount: paymentDetails['amount'],
            planId: paymentDetails['planId'],
            planName: paymentDetails['planName'],
            currency: paymentDetails['currency'],
            userData: paymentDetails['userData'],
          ),
        ),
      );
      
      if (!mounted) return;
      
      // Process payment result
      if (paymentResult != null && paymentResult['success'] == true) {
        final paymentReference = paymentResult['reference'];
        
        if (paymentReference == null) {
          throw Exception('No payment reference received');
        }
        
        setState(() => _isLoading = true);
        
        // Purchase subscription with payment reference
        final success = await userProvider.purchaseSubscriptionPlan(
          planId,
          paymentReference,
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('subscription_purchased_successfully'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            // Reload data to show new subscription
            await _loadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('subscription_purchase_failed'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Payment cancelled or failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResult?['message'] ?? 'payment_cancelled'.tr()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_occurred'.tr()}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
