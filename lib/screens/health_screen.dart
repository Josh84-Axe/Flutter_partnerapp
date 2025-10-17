import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/router_model.dart';
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

  String _getSignalStrength(RouterModel router) {
    if (router.status == 'offline') return 'Offline';
    final uptime = router.uptimeHours;
    if (uptime > 100) return 'Strong';
    if (uptime > 50) return 'Good';
    return 'Weak';
  }

  bool _hasIssues(RouterModel router) {
    return router.status == 'offline' || router.uptimeHours < 24;
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
          FilledButton(
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
            style: FilledButton.styleFrom(
              backgroundColor: isBlocked ? AppTheme.primaryGreen : Colors.red,
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
        title: const Text('Routers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadRouters(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appState.routers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.router, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No routers found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: appState.routers.length,
                  itemBuilder: (context, index) {
                    final router = appState.routers[index];
                    final isOnline = router.status == 'online';
                    final signalStrength = _getSignalStrength(router);
                    final hasIssues = _hasIssues(router);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/router-details',
                            arguments: router.id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? AppTheme.primaryGreen.withOpacity(0.1)
                                          : AppTheme.errorRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isOnline ? Icons.wifi : Icons.wifi_off,
                                      color: isOnline ? AppTheme.primaryGreen : AppTheme.errorRed,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          router.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.signal_cellular_alt,
                                              size: 14,
                                              color: signalStrength == 'Strong'
                                                  ? AppTheme.successGreen
                                                  : signalStrength == 'Good'
                                                      ? AppTheme.warningAmber
                                                      : AppTheme.errorRed,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              signalStrength,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textLight,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.people, size: 14, color: AppTheme.textLight),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${router.connectedUsers} devices',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showRouterMenu(context, router);
                                    },
                                  ),
                                ],
                              ),
                              if (hasIssues) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningAmber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.warningAmber.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppTheme.warningAmber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Issues Detected',
                                          style: TextStyle(
                                            color: AppTheme.warningAmber,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                            '/router-details',
                                            arguments: router.id,
                                          );
                                        },
                                        child: const Text('View'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Divider(height: 1, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQuickStat(
                                    'Data',
                                    '${router.dataUsageGB.toStringAsFixed(1)} GB',
                                    Icons.cloud_download,
                                  ),
                                  _buildQuickStat(
                                    'Uptime',
                                    '${router.uptimeHours}h',
                                    Icons.access_time,
                                  ),
                                  _buildQuickStat(
                                    'Status',
                                    router.status.toUpperCase(),
                                    isOnline ? Icons.check_circle : Icons.cancel,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  void _showRouterMenu(BuildContext context, router) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(
                  '/router-details',
                  arguments: router.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: AppTheme.warningAmber),
              title: const Text('Restart Router'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Router restart initiated')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                router.status == 'online' ? Icons.block : Icons.check_circle,
                color: router.status == 'online' ? AppTheme.errorRed : AppTheme.successGreen,
              ),
              title: Text(router.status == 'online' ? 'Block Router' : 'Unblock Router'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(
                  router.id,
                  router.name,
                  router.status != 'online',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppTheme.primaryGreen),
              title: const Text('Configure'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
