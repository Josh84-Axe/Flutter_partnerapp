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
    final networkProvider = context.read<NetworkProvider>();
    final userProvider = context.read<UserProvider>();
    
    await Future.wait([
      networkProvider.loadActiveSessions(),
      userProvider.loadAssignedPlans(),
      userProvider.loadPurchasedPlans(),
      userProvider.loadUsers(),
    ]);

    // DEBUG: Inspect data structures
    if (networkProvider.activeSessions.isNotEmpty) {
      print('🔍 DEBUG: First Active Session: ${networkProvider.activeSessions.first}');
    } else {
      print('🔍 DEBUG: No Active Sessions found.');
    }

    if (userProvider.assignedPlans.isNotEmpty) {
      print('🔍 DEBUG: First Assigned Plan: ${userProvider.assignedPlans.first}');
    }

    if (userProvider.purchasedPlans.isNotEmpty) {
      print('🔍 DEBUG: First Purchased Plan: ${userProvider.purchasedPlans.first}');
    }
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
            Tab(text: 'online_purchased'.tr()), // Changed label for clarity
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
          _buildPlanListTab(userProvider, networkProvider, colorScheme, isAssigned: false),
          _buildPlanListTab(userProvider, networkProvider, colorScheme, isAssigned: true),
        ],
      ),
    );
  }

  Widget _buildPlanListTab(
    UserProvider userProvider, 
    NetworkProvider networkProvider, 
    ColorScheme colorScheme, 
    {required bool isAssigned}
  ) {
    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

  Widget _buildPlanListTab(
    UserProvider userProvider, 
    NetworkProvider networkProvider, 
    ColorScheme colorScheme, 
    {required bool isAssigned}
  ) {
    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1. Flatten all active sessions
    // NetworkProvider already flattens the list via SessionRepository
    final allActiveSessions = <Map<String, dynamic>>[];
    for (var session in networkProvider.activeSessions) {
      if (session is Map) {
        allActiveSessions.add(session as Map<String, dynamic>);
      }
    }

    if (allActiveSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('no_active_sessions'.tr()),
          ],
        ),
      );
    }

    // 2. Filter sessions based on tab (Assigned vs Purchased)
    // STRICT FILTERING: Determine if the user's *current active status* implies Assigned or Purchased
    // We do this by finding the MOST RECENT plan transaction across both lists.
    final filteredSessions = allActiveSessions.where((session) {
      final sessionUsername = session['username']?.toString().toLowerCase() ?? '';
      if (sessionUsername.isEmpty) return false;

      // Determine the category of this session
      final bool sessionIsAssigned = _isAssignedUser(sessionUsername, userProvider);
      
      // Match with the current tab
      return sessionIsAssigned == isAssigned;
    }).toList();

    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAssigned ? Icons.assignment_ind_outlined : Icons.shopping_cart_outlined, 
              size: 64, 
              color: colorScheme.outline
            ),
            const SizedBox(height: 16),
            Text(isAssigned ? 'no_assigned_active_users'.tr() : 'no_purchased_active_users'.tr()),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: filteredSessions.length,
        itemBuilder: (context, index) {
          final session = filteredSessions[index];
          final username = session['username']?.toString() ?? '';
          
          // Try to get details from the session's 'active_plan' first
          final activePlan = session['active_plan'];
          String planName = 'Unknown Plan';
          if (activePlan is Map) {
            planName = activePlan['plan_name']?.toString() ?? 'Unknown Plan';
          }

          // Fallback or Enrich details from Provider Lists
          // Find the MOST RECENT plan info for this user to get Name/Phone if missing
          Map<String, dynamic>? userDetails;
          try {
             // Look in both lists to find best user details, favoring the current tab's list
             final currentList = isAssigned ? userProvider.assignedPlans : userProvider.purchasedPlans;
             userDetails = currentList.firstWhere(
               (p) => (p['username']?.toString().toLowerCase() ?? '') == username.toLowerCase()
             );
          } catch (_) {
             // Fallback to other list if not found in current (edge case)
             try {
                final otherList = isAssigned ? userProvider.purchasedPlans : userProvider.assignedPlans;
                userDetails = otherList.firstWhere(
                  (p) => (p['username']?.toString().toLowerCase() ?? '') == username.toLowerCase()
                );
             } catch (_) {}
          }

          String customerName = session['customer_first_name']?.toString() ?? session['customer_name']?.toString() ?? '';
          if (customerName.isEmpty) {
             // Try fetching from matched plan details
             customerName = userDetails?['customer_name']?.toString() 
                 ?? userDetails?['first_name']?.toString() 
                 ?? username;
          }
          
          String phoneNumber = session['customer_phone']?.toString() ?? '';
          if (phoneNumber.isEmpty) {
             phoneNumber = userDetails?['phone_number']?.toString() ?? userDetails?['phone']?.toString() ?? '';
          }

          // Block status
          bool isBlocked = false;
          if (username.isNotEmpty) {
             try {
               final user = userProvider.users.firstWhere((u) => (u.username ?? '').toLowerCase() == username.toLowerCase());
               isBlocked = user.isBlocked ?? false;
             } catch (_) {}
          }

          // Construct a 'plan' object for the card 
          final planData = {
            'username': username,
            'customer_name': customerName,
            'phone_number': phoneNumber,
            'plan_name': planName,
            'is_blocked': isBlocked,
          };

          return _buildUserCard(
            plan: planData,
            activeSession: session,
            colorScheme: colorScheme,
            isAssigned: isAssigned,
            isBlocked: isBlocked,
            customerName: customerName, // Pass explicitly
            phoneNumber: phoneNumber,     // Pass explicitly
          );
        },
      ),
    );
  }

  /// Determines if a user belongs to 'Assigned' category based on most recent activity
  bool _isAssignedUser(String username, UserProvider provider) {
    if (username.isEmpty) return false;
    final normalizedUser = username.toLowerCase();

    // 1. Get latest Purchased Plan date
    DateTime? lastPurchased;
    try {
      final purchased = provider.purchasedPlans.where(
        (p) => (p['username']?.toString().toLowerCase() ?? '') == normalizedUser
      ).toList();
      if (purchased.isNotEmpty) {
        // Sort by purchased_at or created_at
        purchased.sort((a, b) {
           final dateA = DateTime.tryParse(a['purchased_at']?.toString() ?? a['created_at']?.toString() ?? '') ?? DateTime(2000);
           final dateB = DateTime.tryParse(b['purchased_at']?.toString() ?? b['created_at']?.toString() ?? '') ?? DateTime(2000);
           return dateB.compareTo(dateA); // Descending
        });
        lastPurchased = DateTime.tryParse(purchased.first['purchased_at']?.toString() ?? purchased.first['created_at']?.toString() ?? '');
      }
    } catch (_) {}

    // 2. Get latest Assigned Plan date
    DateTime? lastAssigned;
    try {
      final assigned = provider.assignedPlans.where(
        (p) => (p['username']?.toString().toLowerCase() ?? '') == normalizedUser
      ).toList();
      if (assigned.isNotEmpty) {
        assigned.sort((a, b) {
           final dateA = DateTime.tryParse(a['purchased_at']?.toString() ?? a['created_at']?.toString() ?? '') ?? DateTime(2000);
           final dateB = DateTime.tryParse(b['purchased_at']?.toString() ?? b['created_at']?.toString() ?? '') ?? DateTime(2000);
           return dateB.compareTo(dateA); // Descending
        });
        lastAssigned = DateTime.tryParse(assigned.first['purchased_at']?.toString() ?? assigned.first['created_at']?.toString() ?? '');
      }
    } catch (_) {}

    // 3. Compare
    if (lastAssigned == null && lastPurchased == null) return false; // Default
    if (lastAssigned != null && lastPurchased == null) return true;
    if (lastAssigned == null && lastPurchased != null) return false;

    // Both exist: check which is newer
    return lastAssigned!.isAfter(lastPurchased!) || lastAssigned.isAtSameMomentAs(lastPurchased);
  }

  Widget _buildUserCard({
      required Map<String, dynamic> plan, 
      required Map<String, dynamic>? activeSession, 
      required ColorScheme colorScheme,
      required bool isAssigned,
      required bool isBlocked,
      required String customerName,
      required String phoneNumber,
  }) {
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
            // Header: User Info and Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          planName,
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     // Connection Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isOnline 
                            ? Colors.green.withOpacity(0.1) 
                            : (isBlocked ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isOnline ? Colors.green : (isBlocked ? Colors.red : Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'online'.tr() : (isBlocked ? 'blocked'.tr() : 'offline'.tr()),
                            style: TextStyle(
                              fontSize: 10,
                              color: isOnline ? Colors.green : (isBlocked ? Colors.red : Colors.grey),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Access Toggle
                    Row(
                      children: [
                        Text(
                          isBlocked ? 'Access Denied' : 'Access Allowed',
                          style: TextStyle(
                            fontSize: 10,
                            color: isBlocked ? Colors.red : Colors.green,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: !isBlocked, // ON means Access Allowed (Not Blocked)
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.red.withOpacity(0.3),
                            inactiveThumbColor: Colors.red,
                            onChanged: (allowed) {
                               final username = plan['username']?.toString() ?? '';
                               if (username.isNotEmpty) {
                                 // If allowed == false, we want to BLOCK.
                                 // If allowed == true, we want to UNBLOCK.
                                 _handleBlockAction(username, activeSession, shouldBlock: !allowed);
                               }
                            },
                          ),
                        ),
                      ],
                    ),
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

  Future<void> _handleBlockAction(String username, Map<String, dynamic>? session, {required bool shouldBlock}) async {
    // Optimistic Update UI?
    // Network calls
    try {
      if (shouldBlock) {
         // 1. Block User
         await context.read<UserProvider>().toggleUserBlock(username, false); // false means 'not currently blocked', so block it.
         
         // 2. Disconnect if online
         if (session != null) {
            await context.read<NetworkProvider>().disconnectSession(session);
         }
         
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('user_blocked_disconnected'.tr(args: [username]))),
           );
         }
      } else {
         // Unblock
         await context.read<UserProvider>().toggleUserBlock(username, true); // true means 'currently blocked', so unblock it.
         
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('User unblocked')), // Add translation key if needed
           );
         }
      }
      
      // Reload to ensure sync
      await _loadData();
      
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
}
