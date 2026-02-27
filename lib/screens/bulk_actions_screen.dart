import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/network_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../utils/app_theme.dart';

class BulkActionsScreen extends StatefulWidget {
  const BulkActionsScreen({super.key});

  @override
  State<BulkActionsScreen> createState() => _BulkActionsScreenState();
}

class _BulkActionsScreenState extends State<BulkActionsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final networkProvider = context.watch<NetworkProvider>();

    final users = userProvider.users.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedUserIds.isEmpty
              ? 'bulk_actions'.tr()
              : 'selected_count'.tr(namedArgs: {'count': _selectedUserIds.length.toString()}),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedUserIds.clear();
                });
              },
              child: Text(
                'clear'.tr(),
                style: const TextStyle(color: AppTheme.pureWhite),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'search_users'.tr(),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = _selectedUserIds.contains(user.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Theme.of(context).cardTheme.color,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUserIds.add(user.id);
                        } else {
                          _selectedUserIds.remove(user.id);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          if (_selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showAssignPlanDialog(context, networkProvider);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('assign_plan'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: Text('block_selected_users'.tr()),
                                content: Text(
                                  'block_selected_confirm'.tr(namedArgs: {'count': _selectedUserIds.length.toString()}),
                                ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(
                                    'block'.tr(),
                                    style: const TextStyle(color: AppTheme.errorRed),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'users_blocked_success'.tr(namedArgs: {'count': _selectedUserIds.length.toString()}),
                                ),
                              ),
                            );
                            setState(() {
                              _selectedUserIds.clear();
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('block_selected'.tr()),
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

  void _showAssignPlanDialog(BuildContext context, NetworkProvider networkProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('assign_plan'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: networkProvider.plans.map((plan) {
              return ListTile(
                title: Text(plan.name),
                subtitle: Text('${plan.price} ${Provider.of<UserProvider>(context, listen: false).currencyCode}'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'plan_assigned_bulk_success'.tr(namedArgs: {
                          'planName': plan.name,
                          'count': _selectedUserIds.length.toString(),
                        }),
                      ),
                    ),
                  );
                  setState(() {
                    _selectedUserIds.clear();
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }
}
