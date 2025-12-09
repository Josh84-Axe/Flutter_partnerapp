import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';


class RouterHealthScreen extends StatefulWidget {
  const RouterHealthScreen({super.key});

  @override
  State<RouterHealthScreen> createState() => _RouterHealthScreenState();
}

class _RouterHealthScreenState extends State<RouterHealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadRouters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appState = context.watch<AppState>();
    final routers = appState.visibleRouters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Health Check'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...routers.map((router) {
            final isOnline = router.status == 'online';
            final hasIssues = router.status == 'issues';
            final isOffline = router.status == 'offline';
            
            Color statusColor = colorScheme.primary;
            Color containerColor = colorScheme.primaryContainer;
            String statusText = 'Online';
            
            if (hasIssues) {
              statusColor = Colors.orange;
              containerColor = Colors.orange.withValues(alpha: 0.2);
              statusText = 'Issues Detected';
            } else if (isOffline) {
              statusColor = Colors.red;
              containerColor = Colors.red.withValues(alpha: 0.2);
              statusText = 'Offline';
            }
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: hasIssues ? BorderSide(color: Colors.orange, width: 1) : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.router,
                            color: statusColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                router.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    statusText,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isOnline || hasIssues) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            hasIssues ? Icons.signal_cellular_alt_1_bar : Icons.signal_cellular_alt,
                            size: 20,
                            color: hasIssues ? Colors.orange : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasIssues ? 'Weak' : 'Strong',
                            style: TextStyle(
                              color: hasIssues ? Colors.orange : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Icon(
                            Icons.devices,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${router.connectedUsers} Devices',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('Run Diagnostics'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('View Report'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
