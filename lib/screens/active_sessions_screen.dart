import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';

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
    await context.read<AppState>().loadActiveSessions();
    await context.read<AppState>().loadAssignedPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
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
          _buildOnlineUsersTab(appState, colorScheme),
          _buildAssignedUsersTab(appState, colorScheme),
        ],
      ),
    );
  }

  Widget _buildOnlineUsersTab(AppState appState, ColorScheme colorScheme) {
    if (appState.isLoading && appState.activeSessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.activeSessions.isEmpty) {
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

    final sessions = appState.activeSessions;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(session, colorScheme, isAssignedTab: false);
        },
      ),
    );
  }

  Widget _buildAssignedUsersTab(AppState appState, ColorScheme colorScheme) {
    if (appState.isLoading && appState.assignedPlans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.assignedPlans.isEmpty) {
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

    // Match active sessions to assigned plans
    final assignedPlans = appState.assignedPlans;
    final activeSessions = appState.activeSessions;
    
    // Create a map of active sessions for quick lookup by username
    final activeSessionMap = {
      for (var s in activeSessions) s['username']?.toString().toLowerCase(): s
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: assignedPlans.length,
        itemBuilder: (context, index) {
          final plan = assignedPlans[index];
          final username = plan['username']?.toString().toLowerCase();
          final activeSession = activeSessionMap[username];
          
          return _buildAssignedUserCard(plan, activeSession, colorScheme);
        },
      ),
    );
  }

  Widget _buildAssignedUserCard(
    Map<String, dynamic> plan, 
    Map<String, dynamic>? activeSession, 
    ColorScheme colorScheme
  ) {
    final username = plan['username'] ?? 'Unknown';
    final planName = plan['plan_name'] ?? 'Unknown Plan';
    final isOnline = activeSession != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOnline) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem('IP Address', activeSession!['ip_address'] ?? 'N/A'),
                  _buildInfoItem('Uptime', activeSession['uptime'] ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem('Download', _formatBytes(activeSession['bytes_in'])),
                  _buildInfoItem('Upload', _formatBytes(activeSession['bytes_out'])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Block User',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Switch(
                    value: false, // TODO: Track blocked state from backend
                    onChanged: (value) => _toggleUserBlock(activeSession, value),
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, ColorScheme colorScheme, {required bool isAssignedTab}) {
    final username = session['username'] ?? 'Unknown';
    final ipAddress = session['ip_address'] ?? 'N/A';
    final macAddress = session['mac_address'] ?? 'N/A';
    final uptime = session['uptime'] ?? 'N/A';
    final bytesIn = session['bytes_in'] ?? 0;
    final bytesOut = session['bytes_out'] ?? 0;
    final routerName = session['router_name'] ?? 'Unknown Router';
    final routerIp = session['router_ip'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with username and disconnect button
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.router, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            routerName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: false, // TODO: Track blocked state from backend
                  onChanged: (value) => _toggleUserBlock(session, value),
                  activeColor: Colors.red,
                ),
              ],
            ),
            const Divider(),
            // Session details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('IP Address', ipAddress),
                _buildInfoItem('MAC', macAddress),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Uptime', uptime),
                _buildInfoItem('Router IP', routerIp),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Download', _formatBytes(bytesIn)),
                _buildInfoItem('Upload', _formatBytes(bytesOut)),
              ],
            ),
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

  Future<void> _toggleUserBlock(Map<String, dynamic> session, bool shouldBlock) async {
    final username = session['username'] ?? 'User';
    
    if (shouldBlock) {
      // Show confirmation before blocking
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Block User'),
          content: Text('Block $username? They will be disconnected and prevented from reconnecting until unblocked.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;
    }

    try {
      // Use disconnect endpoint to block/unblock user
      final success = await context.read<AppState>().disconnectSession(session);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shouldBlock 
              ? '$username has been blocked and disconnected' 
              : '$username has been unblocked'),
          ),
        );
        // Reload sessions to reflect changes
        await _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${shouldBlock ? 'block' : 'unblock'} user'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
