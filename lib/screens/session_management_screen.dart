import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/split/network_provider.dart';
import '../utils/app_theme.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    await context.read<NetworkProvider>().loadActiveSessions();
  }

  Future<void> _disconnectSession(Map<String, dynamic> session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('disconnect_session'.tr()),
        content: Text('disconnect_session_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('disconnect'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final networkProvider = context.read<NetworkProvider>();
      // Use disconnectSession with just the session ID if available, or session map
      // NetworkProvider.disconnectSession currently takes String sessionId
      final sessionId = session['session_id'] ?? session['id']?.toString();
      if (sessionId == null) {
        throw Exception('Session ID not found');
      }
      
      await networkProvider.disconnectSession(sessionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('session_disconnected_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_disconnecting_session'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final sessions = networkProvider.activeSessions;
    final isLoading = networkProvider.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('active_sessions'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_active_sessions'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'no_active_sessions_desc'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.devices,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            session['username'] ?? 'unknown_user'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${'ip_address'.tr()}: ${session['ip_address'] ?? 'N/A'}'),
                              Text('${'mac_address'.tr()}: ${session['mac_address'] ?? 'N/A'}'),
                              Text('${'connected_since'.tr()}: ${session['start_time'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.power_settings_new),
                            color: Colors.red,
                            onPressed: () => _disconnectSession(session),
                            tooltip: 'disconnect'.tr(),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
