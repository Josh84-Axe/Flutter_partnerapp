import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadRouters();
    });
  }

  void _showBlockDialog(String routerId, String routerName, bool isBlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocked ? 'Unblock Device' : 'Block Device'),
        content: Text(
          isBlocked
              ? 'Unblock $routerName and restore connectivity?'
              : 'Block $routerName and prevent connections?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isBlocked) {
                context.read<AppState>().unblockDevice(routerId);
              } else {
                context.read<AppState>().blockDevice(routerId);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBlocked ? 'Device unblocked' : 'Device blocked',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? AppTheme.deepGreen : Colors.red,
            ),
            child: Text(isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadRouters(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.routers.length,
              itemBuilder: (context, index) {
                final router = appState.routers[index];
                final isOnline = router.status == 'online';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isOnline
                          ? AppTheme.deepGreen.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Icon(
                        Icons.router,
                        color: isOnline ? AppTheme.deepGreen : Colors.red,
                      ),
                    ),
                    title: Text(router.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(router.macAddress),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.deepGreen.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            router.status.toUpperCase(),
                            style: TextStyle(
                              color: isOnline ? AppTheme.deepGreen : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Connected Users',
                              '${router.connectedUsers}',
                              Icons.people,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Data Usage',
                              '${router.dataUsageGB.toStringAsFixed(1)} GB',
                              Icons.data_usage,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Uptime',
                              '${router.uptimeHours} hours',
                              Icons.access_time,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Last Seen',
                              _formatDateTime(router.lastSeen),
                              Icons.visibility,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showBlockDialog(
                                      router.id,
                                      router.name,
                                      !isOnline,
                                    ),
                                    icon: Icon(
                                      isOnline
                                          ? Icons.block
                                          : Icons.check_circle,
                                    ),
                                    label: Text(isOnline ? 'Block' : 'Unblock'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOnline
                                          ? Colors.red
                                          : AppTheme.deepGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppTheme.textLight)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
