import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/network_provider.dart';
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
  Map<String, dynamic>? _activePlan;

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
      final networkProvider = context.read<NetworkProvider>();
      // The backend strictly expects 'username' for these specific endpoints.
      // We prioritize widget.user.username as the identifier.
      final identifier = widget.user.username ?? widget.user.id;
      
      if (kDebugMode) {
        print('👤 [UserDetailsScreen] Loading metadata for customer: $identifier (username: ${widget.user.username})');
        if (widget.user.username == null) {
          print('⚠️ [UserDetailsScreen] Warning: customer username is null, backend metadata requests may fail.');
        }
      }
      
      // Load and resolve concurrent calls
      final results = await Future.wait([
        networkProvider.getCustomerDataUsage(identifier).catchError((e) {
          if (kDebugMode) print('⚠️ Usage error: $e');
          return null;
        }),
        networkProvider.getCustomerActivePlan(identifier).catchError((e) {
          if (kDebugMode) print('⚠️ Plan error: $e');
          return null;
        }),
        networkProvider.getCustomerAssignedTransactions(identifier).catchError((e) {
          if (kDebugMode) print('⚠️ Assigned Txn error: $e');
          return [];
        }),
        networkProvider.getCustomerWalletTransactions(identifier).catchError((e) {
          if (kDebugMode) print('⚠️ Wallet Txn error: $e');
          return [];
        }),
      ]);

      if (mounted) {
        setState(() {
          _dataUsage = results[0] as Map<String, dynamic>?;
          _activePlan = results[1] as Map<String, dynamic>?;
          _assignedTransactions = results[2] as List<dynamic>? ?? [];
          _walletTransactions = results[3] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ [UserDetailsScreen] Error loading user details: $e');
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

                  // Active/Upcoming Plan Section
                  if (_activePlan != null) ...[
                    Row(
                      children: [
                        Icon(Icons.stars, color: colorScheme.primary),
                        const SizedBox(width: 8),
                         Text(
                          'active_plan'.tr(), 
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(_activePlan!),
                    const SizedBox(height: 24),
                  ] else ...[
                     Text(
                        'no_active_plan'.tr(),
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
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
                          _buildInfoRow('phone_number'.tr(), user.phone ?? 'not_available_short'.tr()),
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
                      'assigned_transactions'.tr(),
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
                      'wallet_online_transactions'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                         child: _buildTransactionList(_walletTransactions),
                    ),
                  ],
                  
                  if (_assignedTransactions.isEmpty && _walletTransactions.isEmpty)
                     Card(
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(child: Text('no_transactions_found'.tr())),
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

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isActive = plan['is_active'] == true || plan['status']?.toString().toLowerCase() == 'active';
    final isUpcoming = plan['status']?.toString().toLowerCase() == 'upcoming' || plan['status']?.toString().toLowerCase() == 'future';
    final colorScheme = Theme.of(context).colorScheme;
    
    // Status color
    Color statusColor = Colors.grey;
    if (isActive) statusColor = AppTheme.successGreen;
    if (isUpcoming) statusColor = Colors.blue;

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
                    plan['plan_name'] ?? plan['name'] ?? 'unknown_plan'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    (plan['status'] ?? (isActive ? 'active' : 'inactive')).toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Plan details (Usage/Limits)
            Row(
              children: [
                _buildPlanMetric(
                  Icons.data_usage, 
                  '${plan['data_limit'] ?? plan['total_limit'] ?? 0} GB',
                  'allowance'.tr()
                ),
                const SizedBox(width: 24),
                _buildPlanMetric(
                  Icons.timer_outlined, 
                  '${plan['validity'] ?? 0} ${_getTimeUnit(plan)}',
                  'validity'.tr()
                ),
              ],
            ),
            const Divider(height: 24),
            // Expiry/Date info
            Row(
              children: [
                 const Icon(Icons.history, size: 16, color: Colors.grey),
                 const SizedBox(width: 8),
                 Text(
                   plan['expires_at'] != null 
                    ? 'expires_on'.tr(namedArgs: {'date': _formatDate(DateTime.tryParse(plan['expires_at'].toString()) ?? DateTime.now())})
                    : 'no_expiry'.tr(),
                   style: const TextStyle(fontSize: 13, color: Colors.grey),
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanMetric(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  String _getTimeUnit(Map<String, dynamic> plan) {
    // Basic heuristic or check a field
    return 'days';
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
            title: Text(txn['description'] ?? txn['type'] ?? 'transaction'.tr()),
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
