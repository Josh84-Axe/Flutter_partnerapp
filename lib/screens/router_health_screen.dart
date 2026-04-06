import 'package:flutter/material.dart';
import 'router_resources_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../providers/split/network_provider.dart';


class RouterHealthScreen extends StatefulWidget {
  const RouterHealthScreen({super.key});

  @override
  State<RouterHealthScreen> createState() => _RouterHealthScreenState();
}

class _RouterHealthScreenState extends State<RouterHealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NetworkProvider>();
      await provider.loadRouters();
      if (mounted) {
        provider.checkAllRoutersHealth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final networkProvider = context.watch<NetworkProvider>();
    final routers = networkProvider.visibleRouters;

    return Scaffold(
      appBar: AppBar(
        title: Text('router_health_check'.tr()),
        actions: [
          if (networkProvider.isCheckingHealth)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => networkProvider.checkAllRoutersHealth(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: networkProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : routers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.router_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_routers_found'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'add_routers_to_monitor'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ...routers.map((router) {
                      final isAlive = networkProvider.isRouterAlive(router.slug);
                      final deviceCount = networkProvider.getRouterActiveSessionsCount(router.ipAddress ?? router.name);
                      
                      Color statusColor = isAlive ? Colors.green : Colors.red;
                      Color containerColor = statusColor.withValues(alpha: 0.1);
                      String statusText = isAlive ? 'online'.tr() : 'offline'.tr();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                                            fontWeight: FontWeight.bold,
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
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.signal_cellular_alt,
                                    size: 20,
                                    color: isAlive ? Colors.green : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isAlive ? 'strong'.tr() : 'unavailable'.tr(),
                                    style: TextStyle(
                                      color: isAlive ? Colors.green : Colors.grey[600],
                                      fontWeight: isAlive ? FontWeight.w500 : FontWeight.normal,
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
                                    '$deviceCount ${'devices'.tr()}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                        child: Text('run_diagnostics'.tr()),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(

                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: colorScheme.primary,
                                          side: BorderSide(color: Colors.grey[400]!),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                        child: Text('view_report'.tr()),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RouterResourcesScreen(router: router.toJson()),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
