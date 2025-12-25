import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<NetworkProvider>().loadActiveSessions();
    await context.read<UserProvider>().loadAssignedPlans();
    await context.read<UserProvider>().loadPurchasedPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = context.watch<UserProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('active_sessions'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'online_users'.tr()),
            Tab(text: 'assigned_users'.tr()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOnlineUsersTab(userProvider, networkProvider, colorScheme),
          _buildAssignedUsersTab(userProvider, networkProvider, colorScheme),
        ],
      ),
    );
  }

  Widget _buildOnlineUsersTab(UserProvider userProvider, NetworkProvider networkProvider, ColorScheme colorScheme) {
    if (userProvider.isLoading && userProvider.purchasedPlans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProvider.purchasedPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('no_purchased_plans'.tr()),
          ],
        ),
      );
    }

    final plans = userProvider.purchasedPlans;
    
    // Flatten active sessions from all routers AND inject router details
    final allActiveSessions = <Map<String, dynamic>>[];
    for (var router in networkProvider.activeSessions) {
      if (router is Map && router['active_users'] is List) {
        final routerName = router['router_dns_name'] ?? router['name'] ?? 'Unknown';
        final routerIp = router['router_ip'] ?? router['ip_address'] ?? 'N/A';
        
        for (var session in router['active_users']) {
          if (session is Map) {
            allActiveSessions.add({
              ...session as Map<String, dynamic>,
              'router_name': routerName,
              'router_ip': routerIp,
            });
          }
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          final customerName = plan['customer_name']?.toString() ?? '';
          final planUsername = plan['username']?.toString();
          
          // Match logic: 
          // 1. Direct match on 'username' if available in plan
          // 2. Fuzzy match: session username starts with customer_name (case-insensitive)
          Map<String, dynamic>? activeSession;
          
          try {
            activeSession = allActiveSessions.firstWhere((session) {
              final sessionUser = session['username']?.toString().toLowerCase() ?? '';
              
              // Direct ID match
              if (planUsername != null && sessionUser == planUsername.toLowerCase()) {
                return true;
              }
              
              // Fuzzy name match (e.g. 'Win' matches 'win_5c3e...')
              // We check if sessionUser starts with customerName + '_' OR just customerName if exact
              if (customerName.isNotEmpty) {
                final normalizedName = customerName.toLowerCase();
                if (sessionUser == normalizedName) return true;
                if (sessionUser.startsWith('${normalizedName}_')) return true;
                // Fallback: simple startsWith for other patterns
                if (sessionUser.startsWith(normalizedName) && sessionUser.length > normalizedName.length) return true;
              }
              
              return false;
            });
          } catch (e) {
            // No match found
            activeSession = null;
          }
          
          return _buildUserCard(plan, activeSession, colorScheme, isAssigned: false);
        },
      ),
    );
  }

  Widget _buildAssignedUsersTab(UserProvider userProvider, NetworkProvider networkProvider, ColorScheme colorScheme) {
    if (userProvider.isLoading && userProvider.assignedPlans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProvider.assignedPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind_outlined, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('no_assigned_users'.tr()),
          ],
        ),
      );
    }

    final assignedPlans = userProvider.assignedPlans;
    
    // Flatten active sessions from all routers AND inject router details
    final allActiveSessions = <Map<String, dynamic>>[];
    for (var router in networkProvider.activeSessions) {
      if (router is Map && router['active_users'] is List) {
        final routerName = router['router_dns_name'] ?? router['name'] ?? 'Unknown';
        final routerIp = router['router_ip'] ?? router['ip_address'] ?? 'N/A';
        
        for (var session in router['active_users']) {
          if (session is Map) {
            allActiveSessions.add({
              ...session as Map<String, dynamic>,
              'router_name': routerName,
              'router_ip': routerIp,
            });
          }
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: assignedPlans.length,
        itemBuilder: (context, index) {
          final plan = assignedPlans[index];
          final customerName = plan['customer_name']?.toString() ?? '';
          final planUsername = plan['username']?.toString();
          
          // Match logic: 
          // 1. Direct match on 'username' if available in plan
          // 2. Fuzzy match: session username starts with customer_name (case-insensitive)
          Map<String, dynamic>? activeSession;
          
          try {
            activeSession = allActiveSessions.firstWhere((session) {
              final sessionUser = session['username']?.toString().toLowerCase() ?? '';
              
              // Direct ID match
              if (planUsername != null && sessionUser == planUsername.toLowerCase()) {
                return true;
              }
              
              // Fuzzy name match (e.g. 'Win' matches 'win_5c3e...')
              if (customerName.isNotEmpty) {
                final normalizedName = customerName.toLowerCase();
                if (sessionUser == normalizedName) return true;
                if (sessionUser.startsWith('${normalizedName}_')) return true;
                if (sessionUser.startsWith(normalizedName) && sessionUser.length > normalizedName.length) return true;
              }
              
              return false;
            });
          } catch (e) {
            activeSession = null;
          }
          
          return _buildUserCard(plan, activeSession, colorScheme, isAssigned: true);
        },
      ),
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> plan, 
      Map<String, dynamic>? activeSession, 
      ColorScheme colorScheme,
      {required bool isAssigned}
  ) {
    final username = plan['customer_name']?.toString() ?? 'Unknown User';
    final planName = plan['plan_name']?.toString() ?? 'Unknown Plan';
    final isOnline = activeSession != null;
    
    // Extract session details if online
    final ipAddress = activeSession?['ip_address'] ?? activeSession?['ip'] ?? 'N/A';
    final uptime = activeSession?['uptime'] ?? 'N/A';
    final bytesIn = activeSession?['bytes_in'] ?? activeSession?['bytes-in'] ?? 0;
    final bytesOut = activeSession?['bytes_out'] ?? activeSession?['bytes-out'] ?? 0;
    final routerName = activeSession?['router_dns_name'] ?? activeSession?['router_name'] ?? 'Unknown Router';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User and Connection Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        planName,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Label and Disconnect Toggle
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green.withOpacity(0.1) : colorScheme.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isOnline ? Colors.green : colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'online'.tr() : 'offline'.tr(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isOnline ? Colors.green : colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOnline) ...[
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: true, 
                          onChanged: (value) {
                             // Pass false for shouldBlock since it's just a disconnect
                             // Also need to handle session correctly - session is activeSession
                             if (!value) _toggleUserBlock(activeSession!, false); 
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            // Session Details (only if online)
            if (isOnline) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildInfoItem('ip_address'.tr(), ipAddress)),
                  Expanded(child: _buildInfoItem('uptime'.tr(), uptime)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('download'.tr(), _formatBytes(bytesIn))),
                  Expanded(child: _buildInfoItem('upload'.tr(), _formatBytes(bytesOut))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.router, size: 14, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    routerName,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';
    int b = int.tryParse(bytes.toString()) ?? 0;
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _handleSessionAction(Map<String, dynamic> session, {required bool block}) async {
    final username = session['username'] ?? 'User';
    
    if (block) {
      // Show confirmation before blocking
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('block_user'.tr()),
          content: Text('block_user_confirmation'.tr(args: [username])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('block'.tr(), style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;
    }

    try {
      if (block) {
        // Actually block the user using UserProvider - pass false as currentlyBlocked to trigger block
        await context.read<UserProvider>().toggleUserBlock(username, false);
      }

      // Use disconnect endpoint
      await context.read<NetworkProvider>().disconnectSession(session['session_id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(block 
              ? 'user_blocked_disconnected'.tr(args: [username]) 
              : 'user_disconnected'.tr(args: [username])),
          ),
        );
        // Reload sessions to reflect changes
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error'.tr(args: [e.toString()])),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Legacy method name kept or updated in caller
  Future<void> _toggleUserBlock(Map<String, dynamic> session, bool shouldBlock) => 
      _handleSessionAction(session, block: shouldBlock);
}
