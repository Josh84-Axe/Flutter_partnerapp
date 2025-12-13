import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dataUsage;
  List<dynamic> _assignedTransactions = [];
  List<dynamic> _walletTransactions = [];
  List<dynamic> _assignedPlans = [];
  List<dynamic> _purchasedPlans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetails();
    });
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final appState = context.read<AppState>();
      final identifier = widget.user.username ?? widget.user.phone ?? widget.user.id;
      
      // Load data usage
      final dataUsage = await appState.getCustomerDataUsage(identifier);
      
      // Load split transactions
      final assignedTransactions = await appState.getCustomerAssignedTransactions(identifier);
      final walletTransactions = await appState.getCustomerWalletTransactions(identifier);
      
      // Load plans
      final assignedPlans = await appState.getCustomerAssignedPlans(widget.user.id);
      final purchasedPlans = await appState.getCustomerPurchasedPlans(widget.user.id);

      if (mounted) {
        setState(() {
          _dataUsage = dataUsage;
          _assignedTransactions = assignedTransactions;
          _walletTransactions = walletTransactions;
          
          // Filter plans: Only Active (is_active=true) or Future? 
          // User requirement: "Active or upcoming plan should only appear"
          // We assume 'is_active' covers active. For upcoming, check start_date?
          // For now, filtering by is_active or is_assigned (if that implies active)
          // Actually, let's filter by checking if it's NOT expired physically or is explicitly active.
          
          _assignedPlans = assignedPlans.where((p) {
             final isActive = p['is_active'] == true;
             // Check expiry if available
             if (p['expires_at'] != null) {
                final expiry = DateTime.tryParse(p['expires_at']);
                if (expiry != null && expiry.isAfter(DateTime.now())) return true;
             }
             return isActive;
          }).toList();

          _purchasedPlans = purchasedPlans.where((p) {
             final isActive = p['is_active'] == true;
              if (p['expires_at'] != null) {
                final expiry = DateTime.tryParse(p['expires_at']);
                if (expiry != null && expiry.isAfter(DateTime.now())) return true;
             }
             return isActive;
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('user_details'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserDetails,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                   // Header Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                         // Status Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatusBadge(
                              context,
                              isActive: user.isActive,
                              label: user.isActive ? 'active'.tr() : 'inactive'.tr(),
                              color: user.isActive ? colorScheme.primary : Colors.grey,
                            ),
                            if (user.isBlocked == true) ...[
                                const SizedBox(width: 8),
                                _buildStatusBadge(
                                  context,
                                  isActive: true,
                                  label: 'blocked'.tr(),
                                  color: AppTheme.errorRed,
                                  icon: Icons.block,
                                ),
                            ] else if (user.isActive && (user.isConnected == true)) ...[
                                const SizedBox(width: 8),
                                _buildStatusBadge(
                                  context,
                                  isActive: true,
                                  label: 'connected'.tr(),
                                  color: AppTheme.successGreen,
                                  icon: Icons.wifi,
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Data Usage Card
                  if (_dataUsage != null) ...[
                    Text(
                      'data_usage'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('total_used'.tr(), style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_dataUsage!['total_used'] ?? 0} GB',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('remaining'.tr(), style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_dataUsage!['remaining'] ?? 0} GB',
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                             const SizedBox(height: 12),
                             LinearProgressIndicator(
                               value: _calculateUsagePercentage(),
                               backgroundColor: colorScheme.surfaceContainerHighest,
                               borderRadius: BorderRadius.circular(4),
                             ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Purchased Plans Section (Online/Gateway)
                  if (_purchasedPlans.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: colorScheme.primary),
                        const SizedBox(width: 8),
                         Text(
                          'Purchased Plans (Online)', 
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._purchasedPlans.map((plan) => _buildPlanCard(plan, isAssigned: false)),
                    const SizedBox(height: 24),
                  ],

                  // Assigned Plans Section (Partner)
                  if (_assignedPlans.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.assignment_ind, color: colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'assigned_plans'.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._assignedPlans.map((plan) => _buildPlanCard(plan, isAssigned: true)),
                    const SizedBox(height: 24),
                  ],

                  // Personal Info Section
                   Text(
                      'personal_information'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('full_name'.tr(), user.name),
                          const Divider(),
                          _buildInfoRow('phone_number'.tr(), user.phone ?? 'N/A'),
                          const Divider(),
                          _buildInfoRow('email_address'.tr(), user.email),
                          const Divider(),
                          _buildInfoRow('registration_date'.tr(), _formatDate(user.createdAt)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transactions Section
                  // Assigned Transactions
                  if (_assignedTransactions.isNotEmpty) ...[
                    Text(
                      'Assigned Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                         child: _buildTransactionList(_assignedTransactions),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Wallet Transactions
                  if (_walletTransactions.isNotEmpty) ...[
                    Text(
                      'Wallet/Online Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                         child: _buildTransactionList(_walletTransactions),
                    ),
                  ],
                  
                  if (_assignedTransactions.isEmpty && _walletTransactions.isEmpty)
                     const Card(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text('No transactions found')),
                        ),
                     ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, {required bool isActive, required String label, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           if (icon != null) ...[
             Icon(icon, size: 14, color: color),
             const SizedBox(width: 4),
           ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateUsagePercentage() {
    if (_dataUsage == null) return 0.0;
    final total = double.tryParse(_dataUsage!['total_limit']?.toString() ?? '1') ?? 1.0;
    final used = double.tryParse(_dataUsage!['total_used']?.toString() ?? '0') ?? 0.0;
    
    if (total == 0) return 0.0;
    return (used / total).clamp(0.0, 1.0);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan, {required bool isAssigned}) {
    final isActive = plan['is_active'] == true;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan['plan_name'] ?? 'Unknown Plan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.successGreen.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppTheme.successGreen : Colors.grey,
                    ),
                  ),
                  child: Text(
                    isActive ? 'active'.tr() : 'inactive'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.successGreen : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Router Info
            if (plan['routers'] is List && (plan['routers'] as List).isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.router, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    (plan['routers'][0]['name'] ?? 'Unknown Router').toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            // Dates
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  isAssigned 
                      ? (plan['formatted_assigned_at'] ?? plan['formatted_purchased_at'] ?? 'N/A')
                      : (plan['formatted_purchased_at'] ?? 'N/A'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
             // Price if available
             if (plan['price'] != null) ...[
                const SizedBox(height: 4),
                 Text(
                  '${plan['currency_symbol'] ?? ''}${plan['price']}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: colorScheme.primary
                  ),
                 ),
             ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
     final colorScheme = Theme.of(context).colorScheme;
     return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.take(5).length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final txn = transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(Icons.receipt, size: 20, color: colorScheme.onSecondaryContainer),
            ),
            title: Text(txn['description'] ?? txn['type'] ?? 'Transaction'),
            subtitle: Text(_formatDate(DateTime.tryParse(txn['created_at'] ?? '') ?? DateTime.now())),
            trailing: Text(
              '${txn['amount_paid'] ?? txn['amount'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
