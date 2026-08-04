import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/split/auth_provider.dart';
import '../screens/shells/shell_strategies.dart';
import '../flavors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    // Check current app variant via compile-time flavor
    final currentVariant = F.name;
    
    final strategy = getStrategy(currentVariant);
    final headerTitle = strategy.getDrawerHeaderTitle();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentUser?.name ?? headerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          ...strategy.getDrawerItems(context),

          const Divider(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

