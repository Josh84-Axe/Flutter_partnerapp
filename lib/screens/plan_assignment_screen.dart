import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../providers/split/billing_provider.dart';
import '../utils/app_theme.dart';
import '../utils/currency_utils.dart';

class PlanAssignmentScreen extends StatefulWidget {
  const PlanAssignmentScreen({super.key});

  @override
  State<PlanAssignmentScreen> createState() => _PlanAssignmentScreenState();
}

class _PlanAssignmentScreenState extends State<PlanAssignmentScreen> {
  String? _selectedUser;
  String? _selectedPlan;
  bool _isLoading = false;

  Future<void> _assignPlan() async {
    if (_selectedUser == null || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_user_and_plan'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final networkProvider = context.read<NetworkProvider>();
      final userProvider = context.read<UserProvider>();
      
      // Logic to find the router ID associated with the plan
      String? routerId;
      
      // 1. Find the plan object
      final selectedPlanObj = networkProvider.plans.firstWhere((p) => p.id.toString() == _selectedPlan, orElse: () => networkProvider.plans.first);
      print('🔍 [PlanAssignment] Selected Plan: ${selectedPlanObj.name} (ID: ${selectedPlanObj.id})');
      print('🔍 [PlanAssignment] Plan Profile ID: ${selectedPlanObj.profileId}');
      
      // 2. Get profile ID
      if (selectedPlanObj.profileId != null) {
        // 3. Find URL/Profile
        try {
          final profile = networkProvider.hotspotProfiles.firstWhere(
            (p) => int.tryParse(p.id) == selectedPlanObj.profileId || p.id == selectedPlanObj.profileId.toString(),
            orElse: () {
              print('❌ [PlanAssignment] Profile not found for ID: ${selectedPlanObj.profileId}');
              throw Exception('Profile not found');
            }
          );
          
          print('✅ [PlanAssignment] Found Profile: ${profile.name} (ID: ${profile.id})');
          print('🔍 [PlanAssignment] Profile Router Details: ${profile.routerDetails.length}');
          print('🔍 [PlanAssignment] Profile Router IDs: ${profile.routerIds.length}');

          if (profile.routerDetails.isNotEmpty) {
             // Prefer to find first router? Or just take the first one if list exists?
             // Assuming one router per profile for now or picking first valid ID
             final router = profile.routerDetails.firstWhere(
                 (r) => r.id.isNotEmpty, 
                 orElse: () => profile.routerDetails.first
             );
             routerId = router.id;
             print('✅ [PlanAssignment] Resolved Router ID from Details: $routerId');
          } else if (profile.routerIds.isNotEmpty) {
             // Fallback to routerIds if details are missing
             routerId = profile.routerIds.first;
             print('✅ [PlanAssignment] Resolved Router ID from IDs list: $routerId');
          } else {
             print('⚠️ [PlanAssignment] No router info found in profile');
          }
        } catch (e) {
           print('Error resolving router from profile: $e');
        }
      } else {
        print('⚠️ [PlanAssignment] Selected plan has no profile ID');
      }

      await userProvider.assignPlan(_selectedUser!, _selectedPlan!, routerId: routerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('plan_assigned_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_assigning_plan'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final billingProvider = context.watch<BillingProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('assign_plan'.tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'assign_plan_to_customer'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'select_customer_and_plan'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textLight,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  DropdownButtonFormField<String>(
                    value: _selectedUser,
                    decoration: InputDecoration(
                      labelText: 'customer'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    hint: Text('select_customer'.tr()),
                    items: userProvider.users.isEmpty
                        ? [
                            DropdownMenuItem(
                              value: null,
                              child: Text('no_customers_available'.tr()),
                            )
                          ]
                        : userProvider.users.map((user) {
                            return DropdownMenuItem(
                              value: user.id,
                              child: Text('${user.name} (${user.email})'),
                            );
                          }).toList(),
                    onChanged: userProvider.users.isEmpty
                        ? null
                        : (value) => setState(() => _selectedUser = value),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedPlan,
                    decoration: InputDecoration(
                      labelText: 'internet_plan'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.wifi_outlined),
                    ),
                    hint: Text('select_plan'.tr()),
                    items: networkProvider.plans.isEmpty
                        ? [
                            DropdownMenuItem(
                              value: null,
                              child: Text('no_plans_available'.tr()),
                            )
                          ]
                        : networkProvider.plans.map((plan) {
                            final partnerCountry = userProvider.partnerCountry ?? 'TG';
                            final currencySymbol = CurrencyUtils.getCurrencySymbol(partnerCountry);
                            
                            return DropdownMenuItem(
                              value: plan.id.toString(),
                              child: Text(
                                '${plan.name} - ${plan.price} ${userProvider.currencyCode}',
                              ),
                            );
                          }).toList(),
                    onChanged: networkProvider.plans.isEmpty
                        ? null
                        : (value) => setState(() => _selectedPlan = value),
                  ),
                  if (_selectedPlan != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'plan_details'.tr(),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                           const SizedBox(height: 12),
                          ...networkProvider.plans
                              .where((p) => p.id.toString() == _selectedPlan)
                              .map((plan) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('plan_name'.tr(), plan.name),
                                _buildDetailRow('price'.tr(), '${plan.price} ${userProvider.currencyCode}'),
                                _buildDetailRow('data_limit'.tr(), plan.dataLimit != null ? '${plan.dataLimit} GB' : 'Unlimited'),
                                _buildDetailRow('validity'.tr(), plan.formattedValidity),
                                _buildDetailRow('devices_allowed'.tr(), plan.sharedUsersLabel),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _assignPlan,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('assign_plan'.tr()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
