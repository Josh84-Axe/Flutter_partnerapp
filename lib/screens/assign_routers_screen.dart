import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/split/network_provider.dart';
import '../models/worker_model.dart';

class AssignRoutersScreen extends StatefulWidget {
  final WorkerModel worker;

  const AssignRoutersScreen({
    super.key,
    required this.worker,
  });

  @override
  State<AssignRoutersScreen> createState() => _AssignRoutersScreenState();
}

class _AssignRoutersScreenState extends State<AssignRoutersScreen> {
  late List<String> _selectedRouterIds;
  String _searchQuery = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load current assignments from NetworkProvider
    final networkProvider = context.read<NetworkProvider>();
    _selectedRouterIds = List.from(networkProvider.getAssignedRouters(widget.worker.username));
  }

  void _toggleRouter(String routerId) {
    setState(() {
      if (_selectedRouterIds.contains(routerId)) {
        _selectedRouterIds.remove(routerId);
      } else {
        _selectedRouterIds.add(routerId);
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveAssignments() async {
    final networkProvider = context.read<NetworkProvider>();
    
    try {
      await networkProvider.assignRoutersToWorker(widget.worker.username, _selectedRouterIds);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('router_assignment_saved'.tr()),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate changes were saved
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

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final allRouters = networkProvider.routers;
    final colorScheme = Theme.of(context).colorScheme;

    // Filter routers based on search query
    final filteredRouters = allRouters.where((router) {
      if (_searchQuery.isEmpty) return true;
      return router.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (router.ipAddress?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
             router.slug.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('assign_routers'.tr()),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveAssignments,
              child: Text(
                'save'.tr(),
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Worker Info Card
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    widget.worker.fullName.isNotEmpty 
                        ? widget.worker.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.worker.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.worker.email,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedRouterIds.length} ${_selectedRouterIds.length == 1 ? 'router'.tr() : 'routers'.tr()}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_routers'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Router List
          Expanded(
            child: filteredRouters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.router_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'no_routers_available'.tr()
                              : 'no_routers_found'.tr(),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRouters.length,
                    itemBuilder: (context, index) {
                      final router = filteredRouters[index];
                      final isSelected = _selectedRouterIds.contains(router.id);
                      final isOnline = router.status.toLowerCase() == 'online';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: isSelected ? 2 : 0,
                        color: isSelected 
                            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : null,
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) => _toggleRouter(router.id),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  router.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
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
                                      router.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOnline ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (router.ipAddress != null)
                                Text(
                                  'IP: ${router.ipAddress}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                '${router.connectedUsers} ${'users'.tr()} • ${router.dataUsageGB.toStringAsFixed(1)} GB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Action Bar
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saveAssignments,
                      child: Text('save_assignments'.tr()),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
