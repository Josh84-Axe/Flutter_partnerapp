import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/network_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../utils/permissions.dart';
import 'assign_routers_screen.dart';

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
      
      // Strict identifier check: Backend requires the exact username string.
      // If username is null, metadata requests will likely 404.
      final String identifier = (widget.user.username?.isNotEmpty == true) 
          ? widget.user.username! 
          : widget.user.id;
      
      if (kDebugMode) {
        print('--- 👤 Customer Metadata Debug ---');
        print('Identifier used: "$identifier"');
        print('Field source: ${widget.user.username?.isNotEmpty == true ? 'USERNAME' : 'fallback ID'}');
        print('Full User Object: {id: ${widget.user.id}, username: ${widget.user.username}, name: ${widget.user.name}}');
        if (widget.user.username == null || widget.user.username!.isEmpty) {
          print('❌ ERROR: Customer missing username. Metadata endpoints will likely fail.');
        }
        print('----------------------------------');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserDetails,
              child: CustomScrollView(
                slivers: [
                  // Premium Gradient Header
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Animated-like Gradient Background
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                  colorScheme.tertiary.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          // Decorative bubbles for texture
                          Positioned(
                            top: -20,
                            right: -20,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          // Profile Info Over Background
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildHeaderBadge(
                                      isActive: user.isActive,
                                      label: user.isActive ? 'active'.tr() : 'inactive'.tr(),
                                      icon: Icons.check_circle_outline,
                                    ),
                                    if (user.isConnected == true) ...[
                                      const SizedBox(width: 8),
                                      _buildHeaderBadge(
                                        isActive: true,
                                        label: 'connected'.tr(),
                                        icon: Icons.wifi,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadUserDetails,
                      ),
                    ],
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Staff Quick Actions
                          if (Permissions.isWorker(user.role) || Permissions.isManager(user.role)) ...[
                            _buildSectionTitle('staff_management'.tr(), Icons.shield_outlined, Colors.indigo),
                            const SizedBox(height: 12),
                            _buildActionCard(
                              context,
                              title: 'manage_assigned_routers'.tr(),
                              subtitle: 'Assign and monitor specific hardware',
                              icon: Icons.router,
                              color: Colors.indigo,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssignRoutersScreen(worker: user),
                                  ),
                                );
                                if (result == true) _loadUserDetails();
                              },
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Dynamic Performance/Usage Section
                          if (_dataUsage != null) ...[
                            _buildSectionTitle('data_usage'.tr(), Icons.data_usage_rounded, Colors.amber[800]!),
                            const SizedBox(height: 12),
                            _buildUsageCard(context, colorScheme),
                            const SizedBox(height: 24),
                          ],

                          // Subscription Section
                          _buildSectionTitle('active_subscription'.tr(), Icons.stars_rounded, Colors.purple),
                          const SizedBox(height: 12),
                          if (_activePlan != null) 
                            _buildModernPlanCard(_activePlan!)
                          else
                            _buildEmptyStateCard('no_active_plan'.tr(), Icons.info_outline, Colors.grey),
                          
                          const SizedBox(height: 24),

                          // Profile Information
                          _buildSectionTitle('personal_information'.tr(), Icons.person_search_rounded, Colors.blue),
                          const SizedBox(height: 12),
                          _buildModernInfoCard(user, colorScheme),

                          const SizedBox(height: 24),

                          // Transaction History
                          _buildSectionTitle('financial_history'.tr(), Icons.history_rounded, Colors.teal),
                          const SizedBox(height: 12),
                          _buildUnifiedTransactionList(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge({required bool isActive, required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context, ColorScheme colorScheme) {
    final percentage = _calculateUsagePercentage();
    final used = _dataUsage!['total_used'] ?? '0';
    final limit = _dataUsage!['total_limit'] ?? '∞';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          // Circular Gauage
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                  backgroundColor: Colors.amber.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Stats Row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatItem('Consumed', '$used GB', Colors.redAccent),
                const SizedBox(height: 12),
                _buildStatItem('Limit / Allowance', '$limit GB', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.9))),
      ],
    );
  }

  Widget _buildModernPlanCard(Map<String, dynamic> plan) {
    final statusColor = (plan['status']?.toString().toLowerCase() == 'active' || plan['is_active'] == true) 
        ? AppTheme.successGreen 
        : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan['plan_name'] ?? plan['name'] ?? 'Premium Plan',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (plan['status'] ?? 'ACTIVE').toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildModernMetric(Icons.data_usage_rounded, '${plan['data_limit'] ?? 0} GB'),
              const SizedBox(width: 32),
              _buildModernMetric(Icons.calendar_today_rounded, '${plan['validity'] ?? 0} Days'),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.lock_clock_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan['expires_at'] != null 
                    ? 'Expires on ${_formatDate(DateTime.tryParse(plan['expires_at'].toString()) ?? DateTime.now())}'
                    : 'Unlimited Validity',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.purple[300]),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildModernInfoCard(UserModel user, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailTile(Icons.alternate_email_rounded, 'Email', user.email, Colors.blue),
          _buildDetailTile(Icons.phone_iphone_rounded, 'Phone', user.phone ?? 'No Phone', Colors.green),
          _buildDetailTile(Icons.calendar_month_rounded, 'Registered', _formatDate(user.createdAt), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildUnifiedTransactionList() {
    final assigned = _assignedTransactions.map((txn) => Map<String, dynamic>.from(txn)..['_source'] = 'assigned').toList();
    final wallet = _walletTransactions.map((txn) => Map<String, dynamic>.from(txn)..['_source'] = 'wallet').toList();
    final allTxns = [...assigned, ...wallet];
    
    // Sort desc by id/date as a precaution since they were manually merged
    allTxns.sort((a, b) {
       final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
       final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
       return bId.compareTo(aId);
    });

    if (allTxns.isEmpty) return _buildEmptyStateCard('No activities yet', Icons.receipt_long_outlined, Colors.grey);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allTxns.take(5).length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final txn = allTxns[index];
          final isSuccess = txn['status']?.toString().toLowerCase() == 'success';
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.pushNamed(
                context, 
                '/transaction-details',
                arguments: {'id': txn['id'], 'type': txn['_source']}
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withValues(alpha: 0.05),
              child: const Icon(Icons.receipt_rounded, color: Colors.teal, size: 20),
            ),
            title: Text(
              txn['plan_name'] ?? txn['description'] ?? 'Purchase',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              _formatDate(DateTime.tryParse(txn['created_at'] ?? '') ?? DateTime.now()),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${txn['amount_paid'] ?? txn['amount'] ?? 0} FG',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  isSuccess ? 'Success' : 'Pending',
                  style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyStateCard(String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1), style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: color.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  double _calculateUsagePercentage() {
    if (_dataUsage == null) return 0.0;
    final total = double.tryParse(_dataUsage!['total_limit']?.toString() ?? '1') ?? 100.0;
    final used = double.tryParse(_dataUsage!['total_used']?.toString() ?? '0') ?? 0.0;
    if (total == 0 || total < 0.1) return 0.0;
    return (used / total).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
