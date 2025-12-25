import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../providers/split/network_provider.dart';

class RouterAssignScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const RouterAssignScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<RouterAssignScreen> createState() => _RouterAssignScreenState();
}

class _RouterAssignScreenState extends State<RouterAssignScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedRouterIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final networkProvider = context.watch<NetworkProvider>();
    final routers = networkProvider.routers.where((router) {
      if (_searchQuery.isEmpty) return true;
      return router.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          router.id.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('assign_routers'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_routers'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: routers.length,
              itemBuilder: (context, index) {
                final router = routers[index];
                final isSelected = _selectedRouterIds.contains(router.id);
                
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.router, color: Colors.grey),
                  ),
                  title: Text(router.name),
                  subtitle: Text('${'router_id'.tr()}: ${router.id}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRouterIds.add(router.id);
                        } else {
                          _selectedRouterIds.remove(router.id);
                        }
                      });
                    },
                    activeColor: colorScheme.primary,
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedRouterIds.remove(router.id);
                      } else {
                        _selectedRouterIds.add(router.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _selectedRouterIds.isEmpty ? null : _saveAssignment,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('save_assignment'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAssignment() async {
    try {
      // Calls NetworkProvider to save assignments to SharedPreferences (Local Storage Only)
      // Note: This feature currently works per-device as there is no backend endpoint for assignment syncing.
      await context.read<NetworkProvider>().assignRoutersToWorker(
        widget.userId, // Using userId which is actually the email/username passed from UsersScreen
        _selectedRouterIds.toList(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'routers_assigned_to'.tr(namedArgs: {
              'count': '${_selectedRouterIds.length}',
              'name': widget.userName
            }),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning routers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
